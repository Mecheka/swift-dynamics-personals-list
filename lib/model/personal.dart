import 'package:hive/hive.dart';

part 'personal.g.dart';

@HiveType(typeId: 1)
class Personals extends HiveObject {
  @HiveField(0)
  String image;
  @HiveField(1)
  String firstName;
  @HiveField(2)
  String lastName;
  @HiveField(3)
  List<String> phones;
  @HiveField(4)
  List<String> email;
  @HiveField(5)
  String birthday;
  @HiveField(6)
  String gender;

  Personals(this.firstName,
      {this.email, this.image, this.lastName, this.phones, this.birthday,this.gender});
}
