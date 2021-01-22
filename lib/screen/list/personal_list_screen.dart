import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:personal_list/model/personal.dart';
import 'package:personal_list/screen/detail/personal_detail_screen.dart';
import 'package:personal_list/utill/debouncer.dart';

class PersonalListScreen extends StatefulWidget {
  @override
  _PersonalListScreenState createState() => _PersonalListScreenState();
}

class _PersonalListScreenState extends State<PersonalListScreen> {
  final _debounce = Debouncer(milliseconds: 500);
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personal list'),
      ),
      body: ValueListenableBuilder<Box<Personals>>(
        valueListenable: Hive.box<Personals>('personals').listenable(),
        builder: (context, box, _) {
          List<Personals> list;
          if (_search.isEmpty) {
            list = box.values.toList().cast<Personals>();
            list.sort((a, b) {
              return a.firstName.compareTo(b.firstName);
            });
          } else {
            list = box.values
                .where((e) => e.firstName.contains(_search))
                .toList()
                .cast<Personals>();
            list.sort((a, b) {
              return a.firstName.compareTo(b.firstName);
            });
          }

          return Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(hintText: 'Search'),
                  onChanged: (value) {
                    _debounce.run(() {
                      setState(() {
                        _search = value;
                      });
                    });
                  },
                ),
              ),
              Expanded(
                child: list.isNotEmpty
                    ? ListView.separated(
                        itemCount: list.length,
                        itemBuilder: (_, index) {
                          Uint8List image;
                          if (list[index].image != null &&
                              list[index].image.isNotEmpty) {
                            image = base64Decode(list[index].image);
                          }
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => PersonalDetailScreen(
                                            personalId: list[index].key,
                                          )));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Row(
                                children: [
                                  image == null
                                      ? CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: AssetImage(
                                              'assets/img/profile_placeholder.png'),
                                          radius: 50 / 2,
                                        )
                                      : CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: MemoryImage(image),
                                          radius: 50 / 2,
                                        ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Text(
                                      "${list[index].firstName} ${list[index].lastName}"),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, index) {
                          return Divider();
                        },
                      )
                    : Center(
                        child: Text('Empty'),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'create');
        },
        child: Icon(Icons.create),
      ),
    );
  }
}
