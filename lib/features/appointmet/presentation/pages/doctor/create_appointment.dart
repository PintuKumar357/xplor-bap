import 'dart:convert'; // For encoding data into JSON
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For formatting dates
import 'package:http/http.dart' as http;
import 'package:xplor/features/wallet/presentation/widgets/date_picker_widget.dart';
import 'package:xplor/utils/app_colors.dart';
import 'package:xplor/utils/app_dimensions.dart';
import 'package:xplor/utils/common_top_header.dart';
import 'package:xplor/utils/extensions/padding.dart';
import 'package:xplor/utils/extensions/string_to_string.dart';
import 'package:xplor/utils/widgets/build_button.dart';
import 'package:xplor/utils/widgets/custom_text_form_fields.dart';

import '../../../../multi_lang/domain/mappers/profile/profile_keys.dart';
import '../../../../on_boarding/domain/entities/user_data_entity.dart';
import '../../../../../utils/widgets/app_background_widget.dart'; // For HTTP requests

/// A screen widget to edit user profile details.
class CreateAppointment extends StatefulWidget {
  /// The user data entity containing profile details.
  final UserDataEntity? userData;

  /// Constructor for SeekerEditProfile.
  const CreateAppointment({super.key, required this.userData});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  DateTime? _selectedDate;

  String _appointmentDetails = ''; // To show confirmation after submission

  // Function to pick a date

  String generateRandomString(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();

    // Generate a random string by selecting characters from the 'characters' string
    return List.generate(length, (index) => characters[random.nextInt(characters.length)]).join();
  }


  // Function to send appointment data to the API
  Future<void> _submitAppointment(BuildContext context) async {
        if ( _selectedDate == null) {
      print('Please fill in all the details.');
      return;
    }

    print(' all the details.');

    // Prepare the data to send in the request body
    final appointmentData = {
      "abhaId": widget.userData?.kyc?.provider.id,
      "patientName": widget.userData?.kyc?.firstName,
      "link":
          "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${widget.userData?.kyc?.firstName}-TeleConsultation-${generateRandomString(10)}",
      "appointmentDate": DateFormat('yyyy-MM-dd').format(_selectedDate!),
      "mobile": widget.userData?.phoneNumber,
      "email": widget.userData?.kyc?.email,
      "prescription": _prescriptionController.text,
      "doctorOsid": widget.doctor.id,
      "status": "new",
      "walletId": widget.userData?.wallet
    };


    try {
      // Send the data as a POST request
      final response = await http.post(
        Uri.parse('https://testfr.dpgongcp.com/registry/api/v1/Appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(appointmentData),
      );
      if (response.statusCode == 200) {
        setState(() {
          _appointmentDetails = 'Appointment successfully booked!';
        });

        // Optionally, reset the form after submission
        _linkController.clear();
        _prescriptionController.clear();
        Navigator.of(context).pop();
        setState(() {
          _selectedDate = null;
        });
      } else {
        setState(() {
          _appointmentDetails =
              'Failed to book appointment. Please try again later.';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _appointmentDetails = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.userData?.kyc?.firstName);
    print(widget.userData?.phoneNumber);
    print(widget.userData?.kyc?.email);
    return Scaffold(
      body: AppBackgroundDecoration(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Column(
              children: [
                CommonTopHeader(
                  title: ProfileKeys.createAppointment.stringToString,
                  isTitleOnly: false,
                  dividerColor: AppColors.checkBoxDisableColor,
                  onBackButtonPressed: () => Navigator.of(context).pop(),
                ),
                _buildProfileBody(),
                ButtonWidget(
                  onPressed: () => _submitAppointment(context),
                  title: ProfileKeys.saveChanges.stringToString,
                  isValid: true,
                ).symmetricPadding(horizontal: AppDimensions.medium),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileBody() {
    return Column(children: [
      // Name input field, read-only.
      DropdownButtonFormField(
        onChanged: (value) => {},
        items: [DropdownMenuItem<String>(
          value: "value",
          child: Text("h1"),
        ), DropdownMenuItem<String>(
          value: "value2",
          child: Text("h2"),
        )],
        decoration: InputDecoration(
          labelText: "Select Hospital",
        ),
      ),
      DropdownButtonFormField(
        onChanged: (value) => {},
        items: [DropdownMenuItem<String>(
          value: "value",
          child: Text("d1"),
        ), DropdownMenuItem<String>(
          value: "value2",
          child: Text("d2"),
        )],
        decoration: InputDecoration(
          labelText: "Select Doctor",
        ),
      ),
      DatePickerWidget(
          onDateTimeChanged: (DateTime date) {
            setState(() {
              _selectedDate = date;
            });
          },
          selectedDate: DateTime.now().add(const Duration(minutes: 5)),
          minimumDate: DateTime.now(),
          mode: CupertinoDatePickerMode.dateAndTime,
          showActionButtons: false,
          onOkPressed: () {}),
      AppDimensions.small.verticalSpace, // Add vertical space.
    ]).paddingAll(padding: AppDimensions.medium); // Add padding to the form.
  }
}
