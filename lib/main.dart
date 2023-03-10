import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  FirebaseFirestore.instance;

  runApp(App());
}

//find ./lib -exec perl -pi -e 's/{기존}/{치환}/g' {} \;
//grep -R 'surveykit_example' ./lib

//flutter build web --no-sound-null-safety
//firebase init
//   build/web -> y -> n
//flutterfire configure
//flutter build web --no-sound-null-safety
//firebase deploy --only hosting

//git init
//git remote add origin https://github.com/kang86h/Dissonance_survey_2.git
//git branch -M main