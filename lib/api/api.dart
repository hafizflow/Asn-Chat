import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:we_chat/models/chat_user.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firebase database
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // to return current user
  static User get user => auth.currentUser!;

  // for storing self information
  static late ChatUser me;

  // for checking user exists or not
  static Future<bool> userExists() async {
    return (await fireStore.collection("users").doc(user.uid).get()).exists;
  }

  static Future<void> getSelfInfo() async {
    await fireStore.collection("users").doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        log("My Data: ${user.data()}");
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        image: user.photoURL.toString(),
        about: "Hey, I am using Asn Chat",
        name: user.displayName.toString(),
        createdAt: time,
        id: user.uid,
        lastActive: time,
        isOnline: false,
        pushToken: '',
        email: user.email.toString());

    return await fireStore
        .collection("users")
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return fireStore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

// for updating user information
  static Future<void> updateUserInfo() async {
    await fireStore.collection("users").doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }
}
