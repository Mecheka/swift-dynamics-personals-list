import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:personal_list/model/personal.dart';
import 'package:personal_list/screen/create/create_todo_type.dart';
import 'package:path_provider/path_provider.dart';

class CreatePersonalScreen extends StatefulWidget {
  final ScreenState mode;
  final Personals personals;

  CreatePersonalScreen.create()
      : mode = ScreenState.Create,
        personals = null;

  CreatePersonalScreen.edit(this.personals) : mode = ScreenState.Edit;

  @override
  _CreatePersonalScreenState createState() => _CreatePersonalScreenState();
}

class _CreatePersonalScreenState extends State<CreatePersonalScreen> {
  Uint8List _image;
  final ImagePicker _picker = ImagePicker();
  final List<CreateTodoListType> _phoneList = [AddItem()];
  final GlobalKey<AnimatedListState> _phoneKey = GlobalKey();
  final List<CreateTodoListType> _emailList = [AddItem()];
  final GlobalKey<AnimatedListState> _emailKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDayController = TextEditingController();
  String _genderSelect = 'Men';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.mode == ScreenState.Edit) {
      _nameController.text = widget.personals.firstName;
      _lastNameController.text = widget.personals.lastName;
      _birthDayController.text = widget.personals.birthday;
      _genderSelect = widget.personals.gender;
      _phoneList.insertAll(
          0, widget.personals.phones.map((e) => ContentItem(text: e)));
      _emailList.insertAll(
          0, widget.personals.email.map((e) => ContentItem(text: e)));
      if (widget.personals.image != null) {
        _image = base64Decode(widget.personals.image);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _birthDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create personal'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: _image == null
                            ? InkWell(
                                onTap: () {
                                  _getImage();
                                },
                                child: CircleAvatar(
                                  backgroundImage: AssetImage(
                                      'assets/img/profile_placeholder.png'),
                                  radius: 130 / 2,
                                  backgroundColor: Colors.transparent,
                                ),
                              )
                            : InkWell(
                                onTap: () {
                                  _getImage();
                                },
                                child: CircleAvatar(
                                  backgroundImage: MemoryImage(_image),
                                  radius: 130 / 2,
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _nameController,
                                maxLines: 1,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Name empty';
                                  }

                                  return null;
                                },
                                decoration:
                                    InputDecoration(hintText: 'First name'),
                              ),
                              TextFormField(
                                controller: _lastNameController,
                                maxLines: 1,
                                decoration:
                                    InputDecoration(hintText: 'Last name'),
                              ),
                              DateTimeField(
                                controller: _birthDayController,
                                format: DateFormat('dd/MM/yyyy'),
                                decoration:
                                    InputDecoration(hintText: 'Birth day'),
                                onShowPicker: (_, currentValue) {
                                  return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1940),
                                    lastDate: DateTime.now(),
                                    initialDate: DateTime.now(),
                                  );
                                },
                              ),
                              DropdownButtonFormField(
                                value: _genderSelect,
                                hint: Text('Gender'),
                                items: [
                                  DropdownMenuItem(
                                    child: Text('Men'),
                                    value: 'Men',
                                  ),
                                  DropdownMenuItem(
                                    child: Text('Femen'),
                                    value: 'Femen',
                                  )
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _genderSelect = value;
                                  });
                                },
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Card(
                        child: AnimatedList(
                          key: _phoneKey,
                          physics: BouncingScrollPhysics(),
                          initialItemCount: _phoneList.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (_, index, animation) {
                            return SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: animation,
                              child: _filterPhoneWidget(index),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Card(
                        child: AnimatedList(
                          key: _emailKey,
                          physics: BouncingScrollPhysics(),
                          initialItemCount: _emailList.length,
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          itemBuilder: (_, index, animation) {
                            return SizeTransition(
                              axis: Axis.vertical,
                              sizeFactor: animation,
                              child: _filterEmailWidget(index),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: RaisedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    final emails = _emailList
                        .where((e) => e is ContentItem)
                        .map((e) => (e as ContentItem).controller.text)
                        .toList();
                    final phones = _phoneList
                        .where((e) => e is ContentItem)
                        .map((e) => (e as ContentItem).controller.text)
                        .toList();

                    String base64;
                    if (_image != null) {
                      List<int> imageBytes = _image;
                      base64 = base64Encode(imageBytes);
                    }

                    if (widget.mode == ScreenState.Edit) {
                      await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title:
                                  Text('Do you want to edit the information?'),
                              actions: [
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    widget.personals.firstName =
                                        _nameController.text;
                                    widget.personals.lastName =
                                        _lastNameController.text;
                                    widget.personals.phones = phones;
                                    widget.personals.email = emails;
                                    widget.personals.birthday =
                                        _birthDayController.text;
                                    widget.personals.gender = _genderSelect;
                                    widget.personals.image = base64 ?? '';
                                    widget.personals.save();
                                    //* Pop dialog
                                    Navigator.pop(context);
                                    //* Pop screen
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            );
                          });
                    } else {
                      final personal = Personals(_nameController.text,
                          email: emails,
                          lastName: _lastNameController.text,
                          phones: phones,
                          birthday: _birthDayController.text,
                          gender: _genderSelect,
                          image: base64 ?? '');

                      await Hive.box<Personals>('personals').add(personal);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Save'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _filterPhoneWidget(int index) {
    final model = _phoneList[index];
    if (model is AddItem) {
      return _buildAddPhone();
    } else {
      return Row(
        children: [
          InkWell(
            onTap: () {
              _phoneKey.currentState.removeItem(index, (context, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: Row(
                    children: [
                      Icon(
                        Icons.indeterminate_check_box,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 60,
                          child: TextFormField(
                            controller: (model as ContentItem).controller,
                            decoration: InputDecoration(hintText: 'Phone'),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }, duration: const Duration(milliseconds: 500));

              _phoneList.removeAt(index);
            },
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.only(top: 5, end: 5, bottom: 5),
              child: Icon(
                Icons.indeterminate_check_box,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: SizedBox(
              height: 60,
              child: TextFormField(
                keyboardType: TextInputType.phone,
                maxLength: 10,
                maxLines: 1,
                controller: (model as ContentItem).controller,
                decoration: InputDecoration(hintText: 'Phone'),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget _buildAddPhone() {
    return InkWell(
      onTap: () {
        if (_phoneList.where((e) => e is ContentItem).isEmpty) {
          _phoneKey.currentState
              .insertItem(0, duration: const Duration(milliseconds: 500));
          _phoneList.insert(0, ContentItem());
        } else {
          _phoneKey.currentState.insertItem(_phoneList.length - 1,
              duration: const Duration(milliseconds: 500));
          _phoneList.insert(1, ContentItem());
        }
      },
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Icon(
              Icons.add_circle,
              color: Colors.green,
            ),
            const SizedBox(
              width: 16,
            ),
            Text('Phone')
          ],
        ),
      ),
    );
  }

  Widget _filterEmailWidget(int index) {
    final model = _emailList[index];
    if (model is AddItem) {
      return _buildAddEmail();
    } else {
      return Row(
        children: [
          InkWell(
            onTap: () {
              _emailKey.currentState.removeItem(index, (context, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axis: Axis.vertical,
                  child: Row(
                    children: [
                      Icon(
                        Icons.indeterminate_check_box,
                        color: Colors.red,
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: (model as ContentItem).controller,
                            decoration: InputDecoration(hintText: 'Email'),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }, duration: const Duration(milliseconds: 500));
              _emailList.removeAt(index);
            },
            child: Padding(
              padding:
                  const EdgeInsetsDirectional.only(top: 5, end: 5, bottom: 5),
              child: Icon(
                Icons.indeterminate_check_box,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(
            width: 11,
          ),
          Expanded(
            child: SizedBox(
              height: 40,
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                maxLines: 1,
                controller: (model as ContentItem).controller,
                decoration: InputDecoration(hintText: 'Email'),
              ),
            ),
          )
        ],
      );
    }
  }

  Widget _buildAddEmail() {
    return InkWell(
      onTap: () {
        if (_emailList.where((e) => e is ContentItem).isEmpty) {
          _emailKey.currentState
              .insertItem(0, duration: const Duration(milliseconds: 500));
          _emailList.insert(0, ContentItem());
        } else {
          _emailKey.currentState.insertItem(_emailList.length - 1,
              duration: const Duration(milliseconds: 500));
          _emailList.insert(1, ContentItem());
        }
      },
      child: SizedBox(
        height: 40,
        child: Row(
          children: [
            Icon(
              Icons.add_circle,
              color: Colors.green,
            ),
            const SizedBox(
              width: 16,
            ),
            Text('Email')
          ],
        ),
      ),
    );
  }

  _getImage() async {
    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Choose your profile picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () async {
                  await pickImage(source: ImageSource.camera);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Take Photo'),
                ),
              ),
              InkWell(
                onTap: () async {
                  await pickImage(source: ImageSource.gallery);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Choose from Gallery'),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Cancel'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Future pickImage({@required ImageSource source}) async {
    final filePicker = await _picker.getImage(source: source);
    setState(() {
      _image = File(filePicker.path).readAsBytesSync();
    });
  }
}

enum ScreenState { Create, Edit }
