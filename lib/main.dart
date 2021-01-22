import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_list/model/personal.dart';
import 'package:personal_list/screen/create/create_personal_screen.dart';
import 'package:personal_list/screen/list/personal_list_screen.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PersonalsAdapter());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
          future: Hive.openBox<Personals>('personals'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return PersonalListScreen();
            }

            return Container();
          }),
      routes: {'create': (context) => CreatePersonalScreen.create()},
    );
  }
}
