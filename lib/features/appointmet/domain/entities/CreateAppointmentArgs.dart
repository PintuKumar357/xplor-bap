
import 'package:xplor/features/appointmet/presentation/pages/doctor/doctor.dart';
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';

class CreateAppointmentArgs {
  Doctor doctor;

  CreateAppointmentArgs(this.doctor);
  get doctorPhoto =>doctor.imageUrl;
}