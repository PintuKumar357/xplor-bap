import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xplor/const/local_storage/shared_preferences_helper.dart';

import 'package:xplor/core/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/features/appointmet/presentation/pages/doctor/doctor.dart';
import 'package:xplor/features/multi_lang/domain/mappers/profile/profile_keys.dart';
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';
import 'package:xplor/features/profile/presentation/bloc/seeker_profile_bloc/seeker_profile_bloc.dart';

import 'package:xplor/utils/app_colors.dart';
import 'package:xplor/utils/common_top_header.dart';
import '../../../domain/entities/CreateAppointmentArgs.dart';

class Beneficiary {
  final String name;
  final String relationship;
  final int age;
  final String abhaId;

  Beneficiary({
    required this.name,
    required this.relationship,
    required this.age,
    required this.abhaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'age': age,
      'abhaId': abhaId,
    };
  }

  factory Beneficiary.fromMap(Map<String, dynamic> map) {
    return Beneficiary(
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      age: map['age'] ?? 0,
      abhaId: map['abhaId'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Beneficiary.fromJson(String jsonStr) =>
      Beneficiary.fromMap(json.decode(jsonStr));
}

class CreateAppointment extends StatefulWidget {
  final Doctor doctor;

  const CreateAppointment({super.key, required this.doctor});

  @override
  State<CreateAppointment> createState() => _CreateAppointmentState();
}

class _CreateAppointmentState extends State<CreateAppointment> {
  DateTime selectedDate = DateTime.now();
  String selectedTimeSlot = '';
  final Set<String> disabledSlots = {};
  List<Beneficiary> _beneficiaries = [];
  Beneficiary? _selectedBeneficiary;
  bool isLoading = false;

  // Cache time slots
  List<String> _morningSlots = [];
  List<String> _eveningSlots = [];

  @override
  void initState() {
    super.initState();
    context.read<SeekerProfileBloc>().add(const ProfileUserDataEvent());
    _updateTimeSlots();

  }


  Future<void> _loadBeneficiaries(UserDataEntity userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');

      Beneficiary defaultBeneficiary = Beneficiary(
        name: userData.kyc?.firstName ?? "Default Name",
        relationship: "self",
        age: 30,
        abhaId: userData.kyc?.provider?.id ?? "default-abha-id",
      );

      setState(() {
        _selectedBeneficiary ??= defaultBeneficiary;
        _beneficiaries = [defaultBeneficiary] +
            (beneficiariesJson != null
                ? beneficiariesJson
                .map((jsonStr) => Beneficiary.fromJson(jsonStr))
                .toList()
                : []);
      });
    } catch (e) {
      debugPrint("Error loading beneficiaries: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading beneficiaries. Please try again.')),
      );
    }
  }

  void _updateTimeSlots() {
    TimeOfDay now = TimeOfDay.now();
    TimeOfDay morningStart = TimeOfDay(hour: 9, minute: 0);
    TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
    TimeOfDay eveningStart = TimeOfDay(hour: 11, minute: 0);
    TimeOfDay eveningEnd = TimeOfDay(hour: 24, minute: 0);

    setState(() {
      _morningSlots = [];
      _eveningSlots = [];
      disabledSlots.clear();
      selectedTimeSlot = '';

      bool isToday = selectedDate.year == DateTime.now().year &&
          selectedDate.month == DateTime.now().month &&
          selectedDate.day == DateTime.now().day;

      if (isToday) {
        if (now.hour < morningEnd.hour ||
            (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
          _morningSlots = _generateTimeSlots(
              now.hour >= morningStart.hour ? now : morningStart, morningEnd);
        }
        if (now.hour < eveningEnd.hour ||
            (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
          _eveningSlots = _generateTimeSlots(
              now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
        }
      } else {
        _morningSlots = _generateTimeSlots(morningStart, morningEnd);
        _eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
      }

      if (_morningSlots.isNotEmpty) _disableRandomSlots(_morningSlots);
      if (_eveningSlots.isNotEmpty) _disableRandomSlots(_eveningSlots);
    });
  }

  List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
    List<String> timeSlots = [];
    DateTime baseDate = DateTime.now();

    DateTime currentSlot = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      endTime.hour,
      endTime.minute,
    );

    while (currentSlot.isBefore(endDateTime)) {
      timeSlots.add(DateFormat.jm().format(currentSlot));
      currentSlot = currentSlot.add(Duration(minutes: 30));
    }

    return timeSlots;
  }

  String convertTo24HourFormat(String time12Hour) {
    try {
      final format12 = DateFormat("h:mm a");
      final dateTime = format12.parse(time12Hour);
      final format24 = DateFormat("HH:mm");
      return format24.format(dateTime);
    } catch (e) {
      debugPrint("Error converting time format: $e");
      return time12Hour;
    }
  }

  void _disableRandomSlots(List<String> slots) {
    if (slots.length <= 2) return;

    final random = Random();
    List<String> availableSlots = List.from(slots);
    availableSlots.remove(selectedTimeSlot);

    for (int i = 0; i < 2; i++) {
      if (availableSlots.isEmpty) break;
      int index = random.nextInt(availableSlots.length);
      disabledSlots.add(availableSlots[index]);
      availableSlots.removeAt(index);
    }
  }

  Future<void> _submitAppointment( UserDataEntity userData) async {
    if (_selectedBeneficiary == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a beneficiary')),
      );
      return;
    }

    if (selectedTimeSlot.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String selectedTime = convertTo24HourFormat(selectedTimeSlot);

      String timeFmt = selectedTime.replaceAll(":", "-");
      String appointment = "$formattedDate-$timeFmt";
      String appointmentDate = "$formattedDate $selectedTime";

      final appointmentData = {
        "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
        "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
        "link":
        "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
        "appointmentDate": appointmentDate,
        "mobile": userData?.phoneNumber,
        "email": userData?.kyc?.email,
        "prescription": "",
        "doctorOsid": widget.doctor.id,
        "status": "new",
        "walletId": userData?.wallet
      };

      final response = await http.post(
        Uri.parse(
            '${domain}/registry/api/v1/Appointment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(appointmentData),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Appointment successfully booked!')),
        );
      } else {
        throw Exception('Failed to book appointment');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 30)),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Color(0xFF1581BF),
                onPrimary: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
        _updateTimeSlots();
      }
    } catch (e) {
      debugPrint("Error selecting date: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting date. Please try again.')),
      );
    }
  }

  void _showBeneficiariesPopup(UserDataEntity userData) {
    Beneficiary defaultBeneficiary = Beneficiary(
      name: userData.kyc?.firstName ?? "Unknown Name",
      relationship: "self",
      age: 30,
      abhaId: userData.kyc?.provider?.id ?? "Unknown ABHA ID",
    );

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Beneficiary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              if (_beneficiaries.isEmpty)
                ListTile(
                  title: Text(defaultBeneficiary.name),
                  subtitle: Text(defaultBeneficiary.relationship),
                  leading: Radio<Beneficiary>(
                    value: defaultBeneficiary,
                    groupValue: _selectedBeneficiary,
                    onChanged: (value) {
                      setState(() => _selectedBeneficiary = value);
                      Navigator.pop(context);
                    },
                  ),
                  onTap: () {
                    setState(() => _selectedBeneficiary = defaultBeneficiary);
                    Navigator.pop(context);
                  },
                )
              else
                Expanded(
                  child:
                  ListView.builder(
                    itemCount: _beneficiaries.length,
                    itemBuilder: (context, index) {
                      final beneficiary = _beneficiaries[index];
                      return ListTile(
                        title: Text(
                          beneficiary.name.isNotEmpty
                              ? '${beneficiary.name[0].toUpperCase()}${beneficiary.name.substring(1)}'
                              : 'No Name', // Fallback if name is empty
                        ),
                        subtitle: Text(beneficiary.relationship),
                        leading: Radio<Beneficiary>(
                          value: beneficiary,
                          groupValue: _selectedBeneficiary,
                          onChanged: (value) {
                            setState(() => _selectedBeneficiary = value);
                            Navigator.pop(context);
                          },
                        ),
                        onTap: () {
                          setState(() => _selectedBeneficiary = beneficiary);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: CommonTopHeader(
            title: 'Book Appointment',
            isTitleOnly: false,
            dividerColor: Colors.grey,
            onBackButtonPressed: () => Navigator.of(context).pop(),
          ),
        ),
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loader
            : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<SeekerProfileBloc, SeekerProfileState>(
                builder: (context, state) {
                  if (state.profileState == ProfileState.done) {
                    if (state.userData != null) {
                      _loadBeneficiaries(state.userData!);
                    }

                    // Render the view
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.0),
                        Center(
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Image.network(
                                    widget.doctor.imageUrl,
                                    height: 200,
                                    fit: BoxFit.fill,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                .expectedTotalBytes != null
                                                ? loadingProgress
                                                .cumulativeBytesLoaded /
                                                (loadingProgress
                                                    .expectedTotalBytes ??
                                                    1)
                                                : null,
                                          ),
                                        );
                                      }
                                    },
                                    errorBuilder: (BuildContext context,
                                        Object error, StackTrace? stackTrace) {
                                      return Center(
                                          child: Text('Failed to load image'));
                                    },
                                  ),
                                ))),
                        SizedBox(height: 16.0),
                        Container(
                          width: double.infinity, // Makes the card fill the parent width
                          child: Card(
                            color: Colors.white,
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            margin: EdgeInsets.all(0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Doctor Name: ${widget.doctor.name}",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Specialty: ${widget.doctor.specialty}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Hospital: ${widget.doctor.hospital}",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Card(
                          color: Colors.white,
                          elevation: 4,
                          // Adds a shadow effect
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Rounded corners
                          ),
                          margin: EdgeInsets.all(0),
                          // Adds space around the card
                          child: ListTile(
                            title: Text("Select Date"),
                            subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                            trailing: Icon(Icons.calendar_today),
                            onTap: () => _selectDate(context),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        // Morning Slots
                        Text("Select Morning Slot",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _morningSlots.isNotEmpty
                            ? Wrap(
                          spacing: 8.0,
                          children: _morningSlots.map((String time) {
                            return ChoiceChip(
                              label: Text(time,
                                  style: TextStyle(color: Colors.white)),
                              selected: selectedTimeSlot == time,
                              onSelected: disabledSlots.contains(time)
                                  ? null
                                  : (bool selected) {
                                setState(() {
                                  selectedTimeSlot = time;
                                });
                              },
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.blue,
                              disabledColor: Colors.grey[500],
                            );
                          }).toList(),
                        )
                            : Text("No morning slots available"),
                        SizedBox(height: 16.0),
                        // Evening Slots
                        Text("Select Evening Slot",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        _eveningSlots.isNotEmpty
                            ? Wrap(
                          spacing: 8.0,
                          children: _eveningSlots.map((String time) {
                            return ChoiceChip(
                              label: Text(time,
                                  style: TextStyle(color: Colors.white)),
                              selected: selectedTimeSlot == time,
                              onSelected: disabledSlots.contains(time)
                                  ? null
                                  : (bool selected) {
                                setState(() {
                                  selectedTimeSlot = time;
                                });
                              },
                              selectedColor: Colors.blue,
                              backgroundColor: Colors.blue,
                              disabledColor: Colors.grey[500],
                            );
                          }).toList(),
                        )
                            : Text("No evening slots available"),
                        SizedBox(height: 16.0),
                        Text(
                          "Select Beneficiary",
                          style: TextStyle(
                            fontSize: 14.0, // Adjust font size as needed
                            fontWeight: FontWeight.bold, // Makes the text bold
                          ),
                        ),
                        SizedBox(height: 2.0),
                        // Select Beneficiary Button
                        ElevatedButton(
                          onPressed: () {
                            if (state.userData != null)
                              _showBeneficiariesPopup(state.userData!); // Show beneficiary selection popup
                          },
                          child: Text(
                            _selectedBeneficiary == null
                                ? 'Select Beneficiary'
                                : '${_selectedBeneficiary!.name[0].toUpperCase()}${_selectedBeneficiary!.name.substring(1)} (${_selectedBeneficiary!.relationship})',
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            minimumSize: Size(double.infinity, 50),
                            elevation: 5,
                            // Add shadow depth
                            shadowColor: Colors.grey.withOpacity(0.5),
                            // Shadow color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () => {
                            if (state.userData != null)
                              _submitAppointment( state.userData!)
                          },
                          child: Text('Book Appointment',
                              style: TextStyle(color: Color(0xFF1581BF))), // Black text
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                                color: Color(0xFF1581BF), width: 2), // Blue border
                            backgroundColor: Colors.white, // No background color
                            minimumSize: Size(double.infinity, 50),
                          ).copyWith(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                // No rounded corners
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Render a placeholder or loading view
                    return Center(child: CircularProgressIndicator());
                  }
                })));
  }


}