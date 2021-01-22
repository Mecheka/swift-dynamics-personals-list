import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_list/model/personal.dart';
import 'package:personal_list/screen/create/create_personal_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalDetailScreen extends StatefulWidget {
  final dynamic personalId;

  PersonalDetailScreen({@required this.personalId});

  @override
  _PersonalDetailScreenState createState() => _PersonalDetailScreenState();
}

class _PersonalDetailScreenState extends State<PersonalDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal info'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<Box<Personals>>(
                valueListenable: Hive.box<Personals>('personals').listenable(),
                builder: (_, box, child) {
                  final personals = box.get(widget.personalId);

                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child: personals.image.isEmpty
                              ? CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/img/profile_placeholder.png'),
                                  radius: 130 / 2,
                                  backgroundColor: Colors.transparent,
                                )
                              : CircleAvatar(
                                  backgroundImage: MemoryImage(
                                      base64Decode(personals.image)),
                                  radius: 130 / 2,
                                  backgroundColor: Colors.transparent,
                                ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Center(
                          child: Text(
                            '${personals.firstName} ${personals.lastName}',
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ..._buildBirthDay(personals.birthday),
                        ..._buildGender(personals.gender),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildPhoenList(personals.phones),
                        const SizedBox(
                          height: 16,
                        ),
                        _buildEmailList(personals.email)
                      ],
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RaisedButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (_) {
                            return AlertDialog(
                              title: Text('Do you want to delete'),
                              actions: [
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    //* Pop dialog
                                    Navigator.pop(context);
                                    //* Pop screen
                                    Navigator.pop(context);
                                    Future.delayed(const Duration(seconds: 1),
                                        () async {
                                      await Hive.box<Personals>('personals')
                                          .delete(widget.personalId);
                                    });
                                  },
                                )
                              ],
                            );
                          });
                    },
                    child: Text('Delete'),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  RaisedButton(
                    child: Text('Edit'),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => CreatePersonalScreen.edit(
                                  Hive.box<Personals>('personals')
                                      .get(widget.personalId))));
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPhoenList(List<String> phones) {
    if (phones.isNotEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Mobile'),
              ListView.separated(
                itemCount: phones.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () async {
                      final url = 'tel:${phones[index]}';
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                    child: SizedBox(
                      height: 40,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(phones[index])),
                    ),
                  );
                },
                separatorBuilder: (_, index) {
                  return Divider();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  Widget _buildEmailList(List<String> email) {
    if (email.isNotEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Email'),
              ListView.separated(
                itemCount: email.length,
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                itemBuilder: (_, index) {
                  return InkWell(
                    onTap: () async {
                      final url =
                          'mailto:${email[index]}?subject=Title&body=Body';
                      if (await canLaunch(url)) {
                        await launch(url);
                      }
                    },
                    child: SizedBox(
                      height: 40,
                      child: Container(
                          alignment: Alignment.centerLeft,
                          child: Text(email[index])),
                    ),
                  );
                },
                separatorBuilder: (_, index) {
                  return Divider();
                },
              ),
            ],
          ),
        ),
      );
    }

    return Container();
  }

  List<Widget> _buildBirthDay(String birthDay) {
    if (birthDay != null && birthDay.isNotEmpty) {
      return [
        const SizedBox(
          height: 16,
        ),
        Card(
          child: Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Birth day'),
                const SizedBox(
                  height: 8,
                ),
                Text(birthDay)
              ],
            ),
          ),
        ),
      ];
    }

    return [];
  }

  List<Widget> _buildGender(String gender) {
    if (gender != null && gender.isNotEmpty) {
      return [
        const SizedBox(
          height: 16,
        ),
        Card(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Gender'),
                const SizedBox(
                  height: 8,
                ),
                Text(gender)
              ],
            ),
          ),
        ),
      ];
    }

    return [];
  }
}
