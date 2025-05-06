
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';

class Doctor {
  final String name;
  final String specialty;
  final String hospital;
  final String imageUrl;
  final String id;

  Doctor({
    required this.name,
    required this.specialty,
    required this.hospital,
    required this.imageUrl,
    required this.id,
  });
}

class Appointment {
  final Doctor doctor;
  final UserDataEntity userDataEntity;

  Appointment({required this.doctor, required this.userDataEntity});
}