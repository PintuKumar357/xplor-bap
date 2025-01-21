// // // import 'dart:convert'; // For encoding data into JSON
// // // import 'dart:math';    // For generating random numbers
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart'; // For formatting dates
// // // import 'package:http/http.dart' as http;
// // // import 'package:shared_preferences/shared_preferences.dart';
// // //
// // // import 'package:xplor/utils/app_colors.dart';
// // // import 'package:xplor/utils/common_top_header.dart';
// // // import '../../../domain/entities/CreateAppointmentArgs.dart';
// // //
// // // class Beneficiary {
// // //   final String name;
// // //   final String relationship;
// // //   final int age;
// // //   final String abhaId;
// // //
// // //   Beneficiary({
// // //     required this.name,
// // //     required this.relationship,
// // //     required this.age,
// // //     required this.abhaId,
// // //   });
// // //
// // //   Map<String, dynamic> toMap() {
// // //     return {
// // //       'name': name,
// // //       'relationship': relationship,
// // //       'age': age,
// // //       'abhaId': abhaId,
// // //     };
// // //   }
// // //
// // //   factory Beneficiary.fromMap(Map<String, dynamic> map) {
// // //     return Beneficiary(
// // //       name: map['name'] ?? '',
// // //       relationship: map['relationship'] ?? '',
// // //       age: map['age'] ?? 0,
// // //       abhaId: map['abhaId'] ?? '',
// // //     );
// // //   }
// // //
// // //   String toJson() => json.encode(toMap());
// // //
// // //   factory Beneficiary.fromJson(String jsonStr) =>
// // //       Beneficiary.fromMap(json.decode(jsonStr));
// // // }
// // //
// // // class CreateAppointment extends StatefulWidget {
// // //   final CreateAppointmentArgs? createAppointmentArgs;
// // //
// // //   const CreateAppointment({super.key, required this.createAppointmentArgs});
// // //
// // //   @override
// // //   State<CreateAppointment> createState() => _CreateAppointmentState();
// // // }
// // //
// // // class _CreateAppointmentState extends State<CreateAppointment> {
// // //   DateTime selectedDate = DateTime.now();
// // //   String consultationType = '';
// // //   String selectedTimeSlot = '';
// // //   Set<String> disabledSlots = Set<String>();
// // //   List<Beneficiary> _beneficiaries = [];
// // //   Beneficiary? _selectedBeneficiary;
// // //   bool isLoading = false; // Track loading state
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadBeneficiaries();
// // //   }
// // //
// // //   Future<void> _loadBeneficiaries() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');
// // //
// // //     if (beneficiariesJson != null) {
// // //       setState(() {
// // //         _beneficiaries = beneficiariesJson
// // //             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
// // //             .toList();
// // //       });
// // //     }
// // //   }
// // //
// // //   List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
// // //     List<String> timeSlots = [];
// // //     TimeOfDay currentTime = startTime;
// // //
// // //     while (currentTime.hour < endTime.hour ||
// // //         (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
// // //       timeSlots.add(currentTime.format(context));
// // //       int newMinute = currentTime.minute + 30;
// // //       int newHour = currentTime.hour;
// // //
// // //       if (newMinute >= 60) {
// // //         newMinute -= 60;
// // //         newHour += 1;
// // //       }
// // //
// // //       currentTime = TimeOfDay(hour: newHour, minute: newMinute);
// // //     }
// // //     return timeSlots;
// // //   }
// // //
// // //   String convertTo24HourFormat(String time12Hour) {
// // //     try {
// // //       final format12 = DateFormat("h:mm a");
// // //       final dateTime = format12.parse(time12Hour);
// // //
// // //       final format24 = DateFormat("HH:mm");
// // //       return format24.format(dateTime);
// // //     } catch (e) {
// // //       return time12Hour;
// // //     }
// // //   }
// // //
// // //   Future<void> _submitAppointment(BuildContext context) async {
// // //     // Validate if all fields are selected
// // //     if (_selectedBeneficiary == null) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Please select a beneficiary')),
// // //       );
// // //       return;
// // //     }
// // //
// // //     if (selectedTimeSlot.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Please select a time slot')),
// // //       );
// // //       return;
// // //     }
// // //
// // //     setState(() {
// // //       isLoading = true; // Show loader
// // //     });
// // //
// // //     var userData = widget.createAppointmentArgs?.userDataEntity;
// // //     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
// // //     String selectedTime = convertTo24HourFormat(selectedTimeSlot);
// // //
// // //     String timeFmt = selectedTime.replaceAll(":", "-");
// // //     String appointment = "$formattedDate-$timeFmt";
// // //     String appointmentDate = "$formattedDate $selectedTime";
// // //
// // //     final appointmentData = {
// // //       "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
// // //       "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
// // //       "link": "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
// // //       "appointmentDate": appointmentDate,
// // //       "mobile": userData?.phoneNumber,
// // //       "email": userData?.kyc?.email,
// // //       "prescription": "",
// // //       "doctorOsid": widget.createAppointmentArgs?.doctorOsid,
// // //       "status": "new",
// // //       "walletId": userData?.wallet
// // //     };
// // //
// // //     try {
// // //       final response = await http.post(
// // //         Uri.parse('https://testspar.dpgongcp.com/registry/api/v1/Appointment'),
// // //         headers: {'Content-Type': 'application/json'},
// // //         body: json.encode(appointmentData),
// // //       );
// // //
// // //       setState(() {
// // //         isLoading = false;  // Hide loader
// // //       });
// // //
// // //       if (response.statusCode == 200) {
// // //         // Redirect to the home page after a successful appointment booking
// // //         Navigator.of(context).pop();  // Close the current screen
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Appointment successfully booked!')),
// // //         );
// // //
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Failed to book appointment. Please try again.')),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       setState(() {
// // //         isLoading = false;  // Hide loader on error
// // //       });
// // //
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Error occurred: $e')),
// // //       );
// // //     }
// // //   }
// // //
// // //   void _disableRandomSlots(List<String> slots) {
// // //     List<String> availableSlots = slots.where((slot) => slot != selectedTimeSlot).toList();
// // //
// // //     if (availableSlots.length > 2) {
// // //       final random = Random();
// // //       int index1 = random.nextInt(availableSlots.length);
// // //       int index2 = random.nextInt(availableSlots.length);
// // //
// // //       // Ensure different indices and not zero
// // //       while (index2 == index1 || index1 == 0 || index2 == 0) {
// // //         index2 = random.nextInt(availableSlots.length);
// // //       }
// // //
// // //       setState(() {
// // //         disabledSlots.add(availableSlots[index1]);
// // //         disabledSlots.add(availableSlots[index2]);
// // //       });
// // //     }
// // //   }
// // //
// // //   Future<void> _selectDate(BuildContext context) async {
// // //     final DateTime? picked = await showDatePicker(
// // //       context: context,
// // //       initialDate: selectedDate,
// // //       firstDate: DateTime.now(),
// // //       lastDate: DateTime(2030),
// // //     );
// // //     if (picked != null && picked != selectedDate)
// // //       setState(() {
// // //         selectedDate = picked;
// // //       });
// // //   }
// // //   void _showBeneficiariesPopup() {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.only(
// // //           topLeft: Radius.circular(10),  // Top left corner radius
// // //           topRight: Radius.circular(10), // Top right corner radius
// // //         ),
// // //       ),
// // //       backgroundColor: Colors.transparent,  // Set background color to transparent to allow rounded corners to show
// // //       builder: (BuildContext context) {
// // //         return ClipRRect(
// // //           borderRadius: BorderRadius.only(
// // //             topLeft: Radius.circular(10),  // Top left corner radius
// // //             topRight: Radius.circular(10), // Top right corner radius
// // //           ),
// // //           child: Container(
// // //             color: Colors.white,  // Set background color to white
// // //             padding: EdgeInsets.all(16.0),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text("Select Beneficiary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //                 SizedBox(height: 16.0),
// // //                 _beneficiaries.isEmpty
// // //                     ? Text("No beneficiaries added")
// // //                     : Expanded(
// // //                   child: ListView.builder(
// // //                     itemCount: _beneficiaries.length,
// // //                     itemBuilder: (context, index) {
// // //                       final beneficiary = _beneficiaries[index];
// // //                       return ListTile(
// // //                         title: Text(beneficiary.name),
// // //                         subtitle: Text(beneficiary.relationship),
// // //                         leading: Radio<Beneficiary>(
// // //                           value: beneficiary,
// // //                           groupValue: _selectedBeneficiary,
// // //                           onChanged: (Beneficiary? value) {
// // //                             setState(() {
// // //                               _selectedBeneficiary = value;
// // //                             });
// // //                             Navigator.of(context).pop();  // Close the modal after selection
// // //                           },
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     TimeOfDay now = TimeOfDay.now();
// // //     TimeOfDay morningStart = TimeOfDay(hour: 9, minute: 0);
// // //     TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
// // //     TimeOfDay eveningStart = TimeOfDay(hour: 11, minute: 0);
// // //     TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);
// // //
// // //     List<String> morningSlots = [];
// // //     List<String> eveningSlots = [];
// // //
// // //     if (selectedDate.day == DateTime.now().day) {
// // //       if (now.hour < morningEnd.hour || (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
// // //         morningSlots = _generateTimeSlots(now.hour >= morningStart.hour ? now : morningStart, morningEnd);
// // //       }
// // //       if (now.hour < eveningEnd.hour || (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
// // //         eveningSlots = _generateTimeSlots(now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
// // //       }
// // //     } else {
// // //       morningSlots = _generateTimeSlots(morningStart, morningEnd);
// // //       eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
// // //     }
// // //
// // //     _disableRandomSlots(morningSlots);
// // //     _disableRandomSlots(eveningSlots);
// // //
// // //     return Scaffold(
// // //       appBar: PreferredSize(
// // //         preferredSize: Size.fromHeight(100),
// // //         child: CommonTopHeader(
// // //           title: 'Book Appointment',
// // //           isTitleOnly: false,
// // //           dividerColor: Colors.grey,
// // //           onBackButtonPressed: () => Navigator.of(context).pop(),
// // //         ),
// // //       ),
// // //       backgroundColor: Colors.white,
// // //       body: isLoading
// // //           ? Center(child: CircularProgressIndicator()) // Show loader
// // //           : SingleChildScrollView(
// // //         padding: const EdgeInsets.all(16.0),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             SizedBox(height: 16.0),
// // //
// // //             ListTile(
// // //               title: Text("Select Date"),
// // //               subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
// // //               trailing: Icon(Icons.calendar_today),
// // //               onTap: () => _selectDate(context),
// // //             ),
// // //             SizedBox(height: 16.0),
// // //
// // //             // Morning Slots
// // //             Text("Select Morning Slot", style: TextStyle(fontWeight: FontWeight.bold)),
// // //             morningSlots.isNotEmpty
// // //                 ? Wrap(
// // //               spacing: 8.0,
// // //               children: morningSlots.map((String time) {
// // //                 return ChoiceChip(
// // //                   label: Text(time, style: TextStyle(color: Colors.white)),
// // //                   selected: selectedTimeSlot == time,
// // //                   onSelected: disabledSlots.contains(time)
// // //                       ? null
// // //                       : (bool selected) {
// // //                     setState(() {
// // //                       selectedTimeSlot = time;
// // //                     });
// // //                   },
// // //                   selectedColor: Colors.blue,
// // //                   backgroundColor: Colors.blue,
// // //                   disabledColor: Colors.grey,
// // //                 );
// // //               }).toList(),
// // //             )
// // //                 : Text("No morning slots available"),
// // //             SizedBox(height: 16.0),
// // //
// // //             // Evening Slots
// // //             Text("Select Evening Slot", style: TextStyle(fontWeight: FontWeight.bold)),
// // //             eveningSlots.isNotEmpty
// // //                 ? Wrap(
// // //               spacing: 8.0,
// // //               children: eveningSlots.map((String time) {
// // //                 return ChoiceChip(
// // //                   label: Text(time, style: TextStyle(color: Colors.white)),
// // //                   selected: selectedTimeSlot == time,
// // //                   onSelected: disabledSlots.contains(time)
// // //                       ? null
// // //                       : (bool selected) {
// // //                     setState(() {
// // //                       selectedTimeSlot = time;
// // //                     });
// // //                   },
// // //                   selectedColor: Colors.blue,
// // //                   backgroundColor: Colors.blue,
// // //                   disabledColor: Colors.grey,
// // //                 );
// // //               }).toList(),
// // //             )
// // //                 : Text("No evening slots available"),
// // //             SizedBox(height: 16.0),
// // //
// // //             // Select Beneficiary Button
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 _showBeneficiariesPopup();  // Show beneficiary selection popup
// // //               },
// // //               child: Text(_selectedBeneficiary == null
// // //                   ? 'Select Beneficiary'
// // //                   : _selectedBeneficiary!.name),
// // //               style: ElevatedButton.styleFrom(
// // //                 foregroundColor: Colors.white,
// // //                 backgroundColor: Colors.blue,
// // //                 minimumSize: Size(double.infinity, 50),
// // //               ).copyWith(
// // //                 shape: MaterialStateProperty.all(
// // //                   RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(5),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             SizedBox(height: 16.0),
// // //             ElevatedButton(
// // //               onPressed: () => _submitAppointment(context),
// // //               child: Text('Book Appointment', style: TextStyle(color:Color(
// // //                   0xFF1581BF))), // Black text
// // //               style: ElevatedButton.styleFrom(
// // //                 side: BorderSide(color: Color(
// // //                     0xFF1581BF), width: 2), // Blue border
// // //                 backgroundColor: Colors.white, // No background color
// // //                 minimumSize: Size(double.infinity, 50),
// // //
// // //               ).copyWith(
// // //                 shape: MaterialStateProperty.all(
// // //                   RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(5), // No rounded corners
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             // Book Appointment Button
// // //             // ElevatedButton(
// // //             //   onPressed: () => _submitAppointment(context),
// // //             //   child: Text('Book Appointment'),
// // //             //   style: ElevatedButton.styleFrom(
// // //             //     foregroundColor: Colors.white,
// // //             //     backgroundColor: Colors.green,
// // //             //     minimumSize: Size(double.infinity, 50),
// // //             //   ),
// // //             // ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // //
// // //
// // import 'dart:convert'; // For encoding data into JSON
// // import 'dart:math';    // For generating random numbers
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart'; // For formatting dates
// // import 'package:http/http.dart' as http;
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // import 'package:xplor/utils/app_colors.dart';
// // import 'package:xplor/utils/common_top_header.dart';
// // import '../../../domain/entities/CreateAppointmentArgs.dart';
// //
// // class Beneficiary {
// //   final String name;
// //   final String relationship;
// //   final int age;
// //   final String abhaId;
// //
// //   Beneficiary({
// //     required this.name,
// //     required this.relationship,
// //     required this.age,
// //     required this.abhaId,
// //   });
// //
// //   Map<String, dynamic> toMap() {
// //     return {
// //       'name': name,
// //       'relationship': relationship,
// //       'age': age,
// //       'abhaId': abhaId,
// //     };
// //   }
// //
// //   factory Beneficiary.fromMap(Map<String, dynamic> map) {
// //     return Beneficiary(
// //       name: map['name'] ?? '',
// //       relationship: map['relationship'] ?? '',
// //       age: map['age'] ?? 0,
// //       abhaId: map['abhaId'] ?? '',
// //     );
// //   }
// //
// //   String toJson() => json.encode(toMap());
// //
// //   factory Beneficiary.fromJson(String jsonStr) =>
// //       Beneficiary.fromMap(json.decode(jsonStr));
// // }
// //
// // class CreateAppointment extends StatefulWidget {
// //   final CreateAppointmentArgs? createAppointmentArgs;
// //
// //   const CreateAppointment({super.key, required this.createAppointmentArgs});
// //
// //   @override
// //   State<CreateAppointment> createState() => _CreateAppointmentState();
// // }
// //
// // class _CreateAppointmentState extends State<CreateAppointment> {
// //   DateTime selectedDate = DateTime.now();
// //   String consultationType = '';
// //   String selectedTimeSlot = '';
// //   Set<String> disabledSlots = Set<String>();
// //   List<Beneficiary> _beneficiaries = [];
// //   Beneficiary? _selectedBeneficiary;
// //   bool isLoading = false; // Track loading state
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadBeneficiaries();
// //   }
// //
// //   Future<void> _loadBeneficiaries() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');
// //
// //     if (beneficiariesJson != null) {
// //       setState(() {
// //         _beneficiaries = beneficiariesJson
// //             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
// //             .toList();
// //       });
// //     }
// //   }
// //
// //   List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
// //     List<String> timeSlots = [];
// //     TimeOfDay currentTime = startTime;
// //
// //     while (currentTime.hour < endTime.hour ||
// //         (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
// //       timeSlots.add(currentTime.format(context));
// //       int newMinute = currentTime.minute + 30;
// //       int newHour = currentTime.hour;
// //
// //       if (newMinute >= 60) {
// //         newMinute -= 60;
// //         newHour += 1;
// //       }
// //
// //       currentTime = TimeOfDay(hour: newHour, minute: newMinute);
// //     }
// //     return timeSlots;
// //   }
// //
// //   String convertTo24HourFormat(String time12Hour) {
// //     try {
// //       final format12 = DateFormat("h:mm a");
// //       final dateTime = format12.parse(time12Hour);
// //
// //       final format24 = DateFormat("HH:mm");
// //       return format24.format(dateTime);
// //     } catch (e) {
// //       return time12Hour;
// //     }
// //   }
// //
// //   Future<void> _submitAppointment(BuildContext context) async {
// //     // Validate if all fields are selected
// //     if (_selectedBeneficiary == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Please select a beneficiary')),
// //       );
// //       return;
// //     }
// //
// //     if (selectedTimeSlot.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Please select a time slot')),
// //       );
// //       return;
// //     }
// //
// //     setState(() {
// //       isLoading = true; // Show loader
// //     });
// //
// //     var userData = widget.createAppointmentArgs?.userDataEntity;
// //     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
// //     String selectedTime = convertTo24HourFormat(selectedTimeSlot);
// //
// //     String timeFmt = selectedTime.replaceAll(":", "-");
// //     String appointment = "$formattedDate-$timeFmt";
// //     String appointmentDate = "$formattedDate $selectedTime";
// //
// //     final appointmentData = {
// //       "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
// //       "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
// //       "link": "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
// //       "appointmentDate": appointmentDate,
// //       "mobile": userData?.phoneNumber,
// //       "email": userData?.kyc?.email,
// //       "prescription": "",
// //       "doctorOsid": widget.createAppointmentArgs?.doctorOsid,
// //       "status": "new",
// //       "walletId": userData?.wallet
// //     };
// //
// //     try {
// //       final response = await http.post(
// //         Uri.parse('https://testspar.dpgongcp.com/registry/api/v1/Appointment'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: json.encode(appointmentData),
// //       );
// //
// //       setState(() {
// //         isLoading = false;  // Hide loader
// //       });
// //
// //       if (response.statusCode == 200) {
// //         // Redirect to the home page after a successful appointment booking
// //         Navigator.of(context).pop();  // Close the current screen
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Appointment successfully booked!')),
// //         );
// //
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Failed to book appointment. Please try again.')),
// //         );
// //       }
// //     } catch (e) {
// //       setState(() {
// //         isLoading = false;  // Hide loader on error
// //       });
// //
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error occurred: $e')),
// //       );
// //     }
// //   }
// //
// //   void _disableRandomSlots(List<String> slots) {
// //     List<String> availableSlots = slots.where((slot) => slot != selectedTimeSlot).toList();
// //
// //     if (availableSlots.length > 2) {
// //       final random = Random();
// //       int index1 = random.nextInt(availableSlots.length);
// //       int index2 = random.nextInt(availableSlots.length);
// //
// //       // Ensure different indices and not zero
// //       while (index2 == index1 || index1 == 0 || index2 == 0) {
// //         index2 = random.nextInt(availableSlots.length);
// //       }
// //
// //       setState(() {
// //         disabledSlots.add(availableSlots[index1]);
// //         disabledSlots.add(availableSlots[index2]);
// //       });
// //     }
// //   }
// //
// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: selectedDate,
// //       firstDate: DateTime.now(),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null && picked != selectedDate)
// //       setState(() {
// //         selectedDate = picked;
// //       });
// //   }
// //
// //   void _showBeneficiariesPopup() {
// //     showModalBottomSheet(
// //       context: context,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.only(
// //           topLeft: Radius.circular(10),  // Top left corner radius
// //           topRight: Radius.circular(10), // Top right corner radius
// //         ),
// //       ),
// //       backgroundColor: Colors.transparent,  // Set background color to transparent to allow rounded corners to show
// //       builder: (BuildContext context) {
// //         return ClipRRect(
// //           borderRadius: BorderRadius.only(
// //             topLeft: Radius.circular(10),  // Top left corner radius
// //             topRight: Radius.circular(10), // Top right corner radius
// //           ),
// //           child: Container(
// //             color: Colors.white,  // Set background color to white
// //             padding: EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text("Select Beneficiary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //                 SizedBox(height: 16.0),
// //                 _beneficiaries.isEmpty
// //                     ? Text("No beneficiaries added")
// //                     : Expanded(
// //                   child: ListView.builder(
// //                     itemCount: _beneficiaries.length,
// //                     itemBuilder: (context, index) {
// //                       final beneficiary = _beneficiaries[index];
// //                       return ListTile(
// //                         title: Text(beneficiary.name),
// //                         subtitle: Text(beneficiary.relationship),
// //                         leading: Radio<Beneficiary>(
// //                           value: beneficiary,
// //                           groupValue: _selectedBeneficiary,
// //                           onChanged: (Beneficiary? value) {
// //                             setState(() {
// //                               _selectedBeneficiary = value;
// //                             });
// //                             Navigator.of(context).pop();  // Close the modal after selection
// //                           },
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     TimeOfDay now = TimeOfDay.now();
// //     TimeOfDay morningStart = TimeOfDay(hour: 9, minute: 0);
// //     TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
// //     TimeOfDay eveningStart = TimeOfDay(hour: 11, minute: 0);
// //     TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);
// //
// //     List<String> morningSlots = [];
// //     List<String> eveningSlots = [];
// //
// //     if (selectedDate.day == DateTime.now().day) {
// //       if (now.hour < morningEnd.hour || (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
// //         morningSlots = _generateTimeSlots(now.hour >= morningStart.hour ? now : morningStart, morningEnd);
// //       }
// //       if (now.hour < eveningEnd.hour || (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
// //         eveningSlots = _generateTimeSlots(now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
// //       }
// //     } else {
// //       morningSlots = _generateTimeSlots(morningStart, morningEnd);
// //       eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
// //     }
// //
// //     _disableRandomSlots(morningSlots);
// //     _disableRandomSlots(eveningSlots);
// //
// //     return Scaffold(
// //       appBar: PreferredSize(
// //         preferredSize: Size.fromHeight(100),
// //         child: CommonTopHeader(
// //           title: 'Book Appointment',
// //           isTitleOnly: false,
// //           dividerColor: Colors.grey,
// //           onBackButtonPressed: () => Navigator.of(context).pop(),
// //         ),
// //       ),
// //       backgroundColor: Colors.white,
// //       body: isLoading
// //           ? Center(child: CircularProgressIndicator()) // Show loader
// //           : SingleChildScrollView(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             SizedBox(height: 16.0),
// //
// //             ListTile(
// //               title: Text("Select Date"),
// //               subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
// //               trailing: Icon(Icons.calendar_today),
// //               onTap: () => _selectDate(context),
// //             ),
// //             SizedBox(height: 16.0),
// //
// //             // Morning Slots
// //             Text("Select Morning Slot", style: TextStyle(fontWeight: FontWeight.bold)),
// //             morningSlots.isNotEmpty
// //                 ? Wrap(
// //               spacing: 8.0,
// //               children: morningSlots.map((String time) {
// //                 return ChoiceChip(
// //                   label: Text(time, style: TextStyle(color: Colors.white)),
// //                   selected: selectedTimeSlot == time,
// //                   onSelected: disabledSlots.contains(time)
// //                       ? null
// //                       : (bool selected) {
// //                     setState(() {
// //                       selectedTimeSlot = time;
// //                     });
// //                   },
// //                   selectedColor: Colors.blue,
// //                   backgroundColor: Colors.blue,
// //                   disabledColor: Colors.grey,
// //                 );
// //               }).toList(),
// //             )
// //                 : Text("No morning slots available"),
// //             SizedBox(height: 16.0),
// //
// //             // Evening Slots
// //             Text("Select Evening Slot", style: TextStyle(fontWeight: FontWeight.bold)),
// //             eveningSlots.isNotEmpty
// //                 ? Wrap(
// //               spacing: 8.0,
// //               children: eveningSlots.map((String time) {
// //                 return ChoiceChip(
// //                   label: Text(time, style: TextStyle(color: Colors.white)),
// //                   selected: selectedTimeSlot == time,
// //                   onSelected: disabledSlots.contains(time)
// //                       ? null
// //                       : (bool selected) {
// //                     setState(() {
// //                       selectedTimeSlot = time;
// //                     });
// //                   },
// //                   selectedColor: Colors.blue,
// //                   backgroundColor: Colors.blue,
// //                   disabledColor: Colors.grey,
// //                 );
// //               }).toList(),
// //             )
// //                 : Text("No evening slots available"),
// //             SizedBox(height: 16.0),
// //
// //             // Select Beneficiary Button
// //             ElevatedButton(
// //               onPressed: () {
// //                 _showBeneficiariesPopup();  // Show beneficiary selection popup
// //               },
// //               child: Text(_selectedBeneficiary == null
// //                   ? 'Select Beneficiary'
// //                   : _selectedBeneficiary!.name),
// //               style: ElevatedButton.styleFrom(
// //                 foregroundColor: Colors.white,
// //                 backgroundColor: Colors.blue,
// //                 minimumSize: Size(double.infinity, 50),
// //               ).copyWith(
// //                 shape: MaterialStateProperty.all(
// //                   RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(5),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 16.0),
// //             ElevatedButton(
// //               onPressed: () => _submitAppointment(context),
// //               child: Text('Book Appointment', style: TextStyle(color: Color(0xFF1581BF))), // Black text
// //               style: ElevatedButton.styleFrom(
// //                 side: BorderSide(color: Color(0xFF1581BF), width: 2), // Blue border
// //                 backgroundColor: Colors.white, // No background color
// //                 minimumSize: Size(double.infinity, 50),
// //               ).copyWith(
// //                 shape: MaterialStateProperty.all(
// //                   RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(5), // No rounded corners
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
//
//
// ////
//
//
//
//
//
//
// import 'dart:convert'; // For encoding data into JSON
// import 'dart:math';    // For generating random numbers
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting dates
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:xplor/utils/app_colors.dart';
// import 'package:xplor/utils/common_top_header.dart';
// import '../../../domain/entities/CreateAppointmentArgs.dart';
//
// class Beneficiary {
//   final String name;
//   final String relationship;
//   final int age;
//   final String abhaId;
//
//   Beneficiary({
//     required this.name,
//     required this.relationship,
//     required this.age,
//     required this.abhaId,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'relationship': relationship,
//       'age': age,
//       'abhaId': abhaId,
//     };
//   }
//
//   factory Beneficiary.fromMap(Map<String, dynamic> map) {
//     return Beneficiary(
//       name: map['name'] ?? '',
//       relationship: map['relationship'] ?? '',
//       age: map['age'] ?? 0,
//       abhaId: map['abhaId'] ?? '',
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory Beneficiary.fromJson(String jsonStr) =>
//       Beneficiary.fromMap(json.decode(jsonStr));
// }
//
// class CreateAppointment extends StatefulWidget {
//   final CreateAppointmentArgs? createAppointmentArgs;
//
//   const CreateAppointment({super.key, required this.createAppointmentArgs});
//
//   @override
//   State<CreateAppointment> createState() => _CreateAppointmentState();
// }
//
// class _CreateAppointmentState extends State<CreateAppointment> {
//   DateTime selectedDate = DateTime.now();
//   String consultationType = '';
//   String selectedTimeSlot = '';
//   Set<String> disabledSlots = Set<String>();
//   List<Beneficiary> _beneficiaries = [];
//   Beneficiary? _selectedBeneficiary;
//   bool isLoading = false; // Track loading state
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBeneficiaries();
//   }
//
//   Future<void> _loadBeneficiaries() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');
//
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//     if (userData != null) {
//       Beneficiary defaultBeneficiary = Beneficiary(
//         name: userData.kyc?.firstName ?? "Default Name",
//         relationship: "self",
//         age: 30,
//         abhaId: userData.kyc?.provider?.id ?? "default-abha-id",
//       );
//       setState(() {
//         _selectedBeneficiary = defaultBeneficiary;
//         _beneficiaries = [defaultBeneficiary] + (beneficiariesJson != null
//             ? beneficiariesJson
//             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
//             .toList()
//             : []);
//       });
//     } else {
//       setState(() {
//         _beneficiaries = beneficiariesJson != null
//             ? beneficiariesJson
//             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
//             .toList()
//             : [];
//       });
//     }
//   }
//
//   List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
//     List<String> timeSlots = [];
//     TimeOfDay currentTime = startTime;
//
//     while (currentTime.hour < endTime.hour ||
//         (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
//       timeSlots.add(currentTime.format(context));
//       int newMinute = currentTime.minute + 30;
//       int newHour = currentTime.hour;
//
//       if (newMinute >= 60) {
//         newMinute -= 60;
//         newHour += 1;
//       }
//
//       currentTime = TimeOfDay(hour: newHour, minute: newMinute);
//     }
//     return timeSlots;
//   }
//
//   String convertTo24HourFormat(String time12Hour) {
//     try {
//       final format12 = DateFormat("h:mm a");
//       final dateTime = format12.parse(time12Hour);
//
//       final format24 = DateFormat("HH:mm");
//       return format24.format(dateTime);
//     } catch (e) {
//       return time12Hour;
//     }
//   }
//
//   Future<void> _submitAppointment(BuildContext context) async {
//     // Validate if all fields are selected
//     if (_selectedBeneficiary == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a beneficiary')),
//       );
//       return;
//     }
//
//     if (selectedTimeSlot.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a time slot')),
//       );
//       return;
//     }
//
//     setState(() {
//       isLoading = true; // Show loader
//     });
//
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     String selectedTime = convertTo24HourFormat(selectedTimeSlot);
//
//     String timeFmt = selectedTime.replaceAll(":", "-");
//     String appointment = "$formattedDate-$timeFmt";
//     String appointmentDate = "$formattedDate $selectedTime";
//
//     final appointmentData = {
//       "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
//       "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
//       "link": "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
//       "appointmentDate": appointmentDate,
//       "mobile": userData?.phoneNumber,
//       "email": userData?.kyc?.email,
//       "prescription": "",
//       "doctorOsid": widget.createAppointmentArgs?.doctorOsid,
//       "status": "new",
//       "walletId": userData?.wallet
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse('https://testspar.dpgongcp.com/registry/api/v1/Appointment'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(appointmentData),
//       );
//
//       setState(() {
//         isLoading = false;  // Hide loader
//       });
//
//       if (response.statusCode == 200) {
//         // Redirect to the home page after a successful appointment booking
//         Navigator.of(context).pop();  // Close the current screen
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Appointment successfully booked!')),
//         );
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to book appointment. Please try again.')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;  // Hide loader on error
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error occurred: $e')),
//       );
//     }
//   }
//
//   void _disableRandomSlots(List<String> slots) {
//     List<String> availableSlots = slots.where((slot) => slot != selectedTimeSlot).toList();
//
//     if (availableSlots.length > 2) {
//       final random = Random();
//       int index1 = random.nextInt(availableSlots.length);
//       int index2 = random.nextInt(availableSlots.length);
//
//       // Ensure different indices and not zero
//       while (index2 == index1 || index1 == 0 || index2 == 0) {
//         index2 = random.nextInt(availableSlots.length);
//       }
//
//       setState(() {
//         disabledSlots.add(availableSlots[index1]);
//         disabledSlots.add(availableSlots[index2]);
//       });
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null && picked != selectedDate)
//       setState(() {
//         selectedDate = picked;
//       });
//   }
//
//   void _showBeneficiariesPopup() {
//     // Don't automatically select the default beneficiary
//     Beneficiary? defaultBeneficiary;
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//
//     // Create a default beneficiary if no beneficiaries are available
//     if (_beneficiaries.isEmpty && userData != null) {
//       defaultBeneficiary = Beneficiary(
//         name: userData.kyc?.firstName ?? "Unknown Name",
//         relationship: "self", // Default to 'self'
//         age: 30, // Add a default age (you may replace this if you have age data)
//         abhaId: userData.kyc?.provider.id ?? "Unknown ABHA ID",
//       );
//     }
//
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10), // Top left corner radius
//           topRight: Radius.circular(10), // Top right corner radius
//         ),
//       ),
//       backgroundColor: Colors.transparent, // Set background color to transparent
//       builder: (BuildContext context) {
//         return ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10), // Top left corner radius
//             topRight: Radius.circular(10), // Top right corner radius
//           ),
//           child: Container(
//             color: Colors.white, // Set background color to white
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Select Beneficiary",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16.0),
//                 // If no beneficiaries, show default without pre-selecting
//                 if (_beneficiaries.isEmpty)
//                   ListTile(
//                     title: Text(defaultBeneficiary?.name ?? "No name available"),
//                     subtitle: Text(defaultBeneficiary?.relationship ?? "No relationship"),
//                     leading: Radio<Beneficiary>(
//                       value: defaultBeneficiary!,
//                       groupValue: null,  // Don't automatically select
//                       onChanged: (Beneficiary? value) {
//                         setState(() {
//                           _selectedBeneficiary = value;
//                         });
//                         Navigator.of(context).pop();  // Close the modal after selection
//                       },
//                     ),
//                   ),
//                 // If beneficiaries are available, show them
//                 if (_beneficiaries.isNotEmpty)
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: _beneficiaries.length,
//                       itemBuilder: (context, index) {
//                         final beneficiary = _beneficiaries[index];
//                         return ListTile(
//                           title: Text(beneficiary.name),
//                           subtitle: Text(beneficiary.relationship),
//                           leading: Radio<Beneficiary>(
//                             value: beneficiary,
//                             groupValue: _selectedBeneficiary,
//                             onChanged: (Beneficiary? value) {
//                               setState(() {
//                                 _selectedBeneficiary = value;
//                               });
//                               Navigator.of(context).pop();  // Close the modal after selection
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // void _showBeneficiariesPopup() {
//   //   // Check if there are no beneficiaries
//   //   Beneficiary? defaultBeneficiary;
//   //   var userData = widget.createAppointmentArgs?.userDataEntity;
//   //
//   //   // Create a default beneficiary if no beneficiaries are available
//   //   if (_beneficiaries.isEmpty && userData != null) {
//   //     defaultBeneficiary = Beneficiary(
//   //       name: userData.kyc?.firstName ?? "Unknown Name",
//   //       relationship: "self", // Default to 'self'
//   //       age: 30, // Add a default age (you may replace this if you have age data)
//   //       abhaId: userData.kyc?.provider.id ?? "Unknown ABHA ID",
//   //     );
//   //     _selectedBeneficiary = defaultBeneficiary; // Automatically select the default beneficiary
//   //   }
//   //
//   //   showModalBottomSheet(
//   //     context: context,
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.only(
//   //         topLeft: Radius.circular(10), // Top left corner radius
//   //         topRight: Radius.circular(10), // Top right corner radius
//   //       ),
//   //     ),
//   //     backgroundColor: Colors.transparent, // Set background color to transparent
//   //     builder: (BuildContext context) {
//   //       return ClipRRect(
//   //         borderRadius: BorderRadius.only(
//   //           topLeft: Radius.circular(10), // Top left corner radius
//   //           topRight: Radius.circular(10), // Top right corner radius
//   //         ),
//   //         child: Container(
//   //           color: Colors.white, // Set background color to white
//   //           padding: EdgeInsets.all(16.0),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 "Select Beneficiary",
//   //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //               ),
//   //               SizedBox(height: 16.0),
//   //               // If no beneficiaries, show default
//   //               if (_beneficiaries.isEmpty)
//   //                 ListTile(
//   //                   title: Text(defaultBeneficiary?.name ?? "No name available"),
//   //                   subtitle: Text(defaultBeneficiary?.relationship ?? "No relationship"),
//   //                   leading: Radio<Beneficiary>(
//   //                     value: defaultBeneficiary!,
//   //                     groupValue: _selectedBeneficiary,
//   //                     onChanged: (Beneficiary? value) {
//   //                       setState(() {
//   //                         _selectedBeneficiary = value;
//   //                       });
//   //                       Navigator.of(context).pop();  // Close the modal after selection
//   //                     },
//   //                   ),
//   //                 ),
//   //               // If beneficiaries are available, show them
//   //               if (_beneficiaries.isNotEmpty)
//   //                 Expanded(
//   //                   child: ListView.builder(
//   //                     itemCount: _beneficiaries.length,
//   //                     itemBuilder: (context, index) {
//   //                       final beneficiary = _beneficiaries[index];
//   //                       return ListTile(
//   //                         title: Text(beneficiary.name),
//   //                         subtitle: Text(beneficiary.relationship),
//   //                         leading: Radio<Beneficiary>(
//   //                           value: beneficiary,
//   //                           groupValue: _selectedBeneficiary,
//   //                           onChanged: (Beneficiary? value) {
//   //                             setState(() {
//   //                               _selectedBeneficiary = value;
//   //                             });
//   //                             Navigator.of(context).pop();  // Close the modal after selection
//   //                           },
//   //                         ),
//   //                       );
//   //                     },
//   //                   ),
//   //                 ),
//   //             ],
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     TimeOfDay now = TimeOfDay.now();
//     TimeOfDay morningStart = TimeOfDay(hour: 9, minute: 0);
//     TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
//     TimeOfDay eveningStart = TimeOfDay(hour: 11, minute: 0);
//     TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);
//
//     List<String> morningSlots = [];
//     List<String> eveningSlots = [];
//
//     if (selectedDate.day == DateTime.now().day) {
//       if (now.hour < morningEnd.hour || (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
//         morningSlots = _generateTimeSlots(now.hour >= morningStart.hour ? now : morningStart, morningEnd);
//       }
//       if (now.hour < eveningEnd.hour || (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
//         eveningSlots = _generateTimeSlots(now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
//       }
//     } else {
//       morningSlots = _generateTimeSlots(morningStart, morningEnd);
//       eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
//     }
//
//     _disableRandomSlots(morningSlots);
//     _disableRandomSlots(eveningSlots);
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100),
//         child: CommonTopHeader(
//           title: 'Book Appointment',
//           isTitleOnly: false,
//           dividerColor: Colors.grey,
//           onBackButtonPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator()) // Show loader
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 16.0),
//             ListTile(
//               title: Text("Select Date"),
//               subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () => _selectDate(context),
//             ),
//             SizedBox(height: 16.0),
//
//             // Morning Slots
//             Text("Select Morning Slot", style: TextStyle(fontWeight: FontWeight.bold)),
//             morningSlots.isNotEmpty
//                 ? Wrap(
//               spacing: 8.0,
//               children: morningSlots.map((String time) {
//                 return ChoiceChip(
//                   label: Text(time, style: TextStyle(color: Colors.white)),
//                   selected: selectedTimeSlot == time,
//                   onSelected: disabledSlots.contains(time)
//                       ? null
//                       : (bool selected) {
//                     setState(() {
//                       selectedTimeSlot = time;
//                     });
//                   },
//                   selectedColor: Colors.blue,
//                   backgroundColor: Colors.blue,
//                   disabledColor: Colors.grey,
//                 );
//               }).toList(),
//             )
//                 : Text("No morning slots available"),
//             SizedBox(height: 16.0),
//
//             // Evening Slots
//             Text("Select Evening Slot", style: TextStyle(fontWeight: FontWeight.bold)),
//             eveningSlots.isNotEmpty
//                 ? Wrap(
//               spacing: 8.0,
//               children: eveningSlots.map((String time) {
//                 return ChoiceChip(
//                   label: Text(time, style: TextStyle(color: Colors.white)),
//                   selected: selectedTimeSlot == time,
//                   onSelected: disabledSlots.contains(time)
//                       ? null
//                       : (bool selected) {
//                     setState(() {
//                       selectedTimeSlot = time;
//                     });
//                   },
//                   selectedColor: Colors.blue,
//                   backgroundColor: Colors.blue,
//                   disabledColor: Colors.grey,
//                 );
//               }).toList(),
//             )
//                 : Text("No evening slots available"),
//             SizedBox(height: 16.0),
//
//             // Select Beneficiary Button
//             ElevatedButton(
//               onPressed: () {
//                 _showBeneficiariesPopup();  // Show beneficiary selection popup
//               },
//               child: Text(_selectedBeneficiary == null
//                   ? 'Select Beneficiary'
//                   : _selectedBeneficiary!.name),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Colors.blue,
//                 minimumSize: Size(double.infinity, 50),
//               ).copyWith(
//                 shape: MaterialStateProperty.all(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () => _submitAppointment(context),
//               child: Text('Book Appointment', style: TextStyle(color:Color(
//                   0xFF1581BF))), // Black text
//               style: ElevatedButton.styleFrom(
//                 side: BorderSide(color: Color(
//                     0xFF1581BF), width: 2), // Blue border
//                 backgroundColor: Colors.white, // No background color
//                 minimumSize: Size(double.infinity, 50),
//
//               ).copyWith(
//                 shape: MaterialStateProperty.all(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5), // No rounded corners
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//





// import 'dart:convert'; // For encoding data into JSON
// import 'dart:math';    // For generating random numbers
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // For formatting dates
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:xplor/utils/app_colors.dart';
// import 'package:xplor/utils/common_top_header.dart';
// import '../../../domain/entities/CreateAppointmentArgs.dart';
//
// class Beneficiary {
//   final String name;
//   final String relationship;
//   final int age;
//   final String abhaId;
//
//   Beneficiary({
//     required this.name,
//     required this.relationship,
//     required this.age,
//     required this.abhaId,
//   });
//
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'relationship': relationship,
//       'age': age,
//       'abhaId': abhaId,
//     };
//   }
//
//   factory Beneficiary.fromMap(Map<String, dynamic> map) {
//     return Beneficiary(
//       name: map['name'] ?? '',
//       relationship: map['relationship'] ?? '',
//       age: map['age'] ?? 0,
//       abhaId: map['abhaId'] ?? '',
//     );
//   }
//
//   String toJson() => json.encode(toMap());
//
//   factory Beneficiary.fromJson(String jsonStr) =>
//       Beneficiary.fromMap(json.decode(jsonStr));
// }
//
// class CreateAppointment extends StatefulWidget {
//   final CreateAppointmentArgs? createAppointmentArgs;
//
//   const CreateAppointment({super.key, required this.createAppointmentArgs});
//
//   @override
//   State<CreateAppointment> createState() => _CreateAppointmentState();
// }
//
// class _CreateAppointmentState extends State<CreateAppointment> {
//   DateTime selectedDate = DateTime.now();
//   String consultationType = '';
//   String selectedTimeSlot = '';
//   Set<String> disabledSlots = Set<String>();
//   List<Beneficiary> _beneficiaries = [];
//   Beneficiary? _selectedBeneficiary;
//   bool isLoading = false; // Track loading state
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBeneficiaries();
//   }
//
//   Future<void> _loadBeneficiaries() async {
//     final prefs = await SharedPreferences.getInstance();
//     List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');
//
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//     if (userData != null) {
//       // Add the default beneficiary with the relationship "self"
//       Beneficiary defaultBeneficiary = Beneficiary(
//         name: userData.kyc?.firstName ?? "Default Name",
//         relationship: "self", // Set relationship as self
//         age: 30, // You can set a default age or fetch it if available
//         abhaId: userData.kyc?.provider?.id ?? "default-abha-id", // Default ABHA ID
//       );
//       setState(() {
//         _selectedBeneficiary = defaultBeneficiary;
//         _beneficiaries = [defaultBeneficiary] + (beneficiariesJson != null
//             ? beneficiariesJson
//             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
//             .toList()
//             : []);
//       });
//     } else {
//       setState(() {
//         _beneficiaries = beneficiariesJson != null
//             ? beneficiariesJson
//             .map((jsonStr) => Beneficiary.fromJson(jsonStr))
//             .toList()
//             : [];
//       });
//     }
//   }
//
//   List<String> _generateTimeSlots(TimeOfDay startTime, TimeOfDay endTime) {
//     List<String> timeSlots = [];
//     TimeOfDay currentTime = startTime;
//
//     while (currentTime.hour < endTime.hour ||
//         (currentTime.hour == endTime.hour && currentTime.minute < endTime.minute)) {
//       timeSlots.add(currentTime.format(context));
//       int newMinute = currentTime.minute + 30;
//       int newHour = currentTime.hour;
//
//       if (newMinute >= 60) {
//         newMinute -= 60;
//         newHour += 1;
//       }
//
//       currentTime = TimeOfDay(hour: newHour, minute: newMinute);
//     }
//     return timeSlots;
//   }
//
//   String convertTo24HourFormat(String time12Hour) {
//     try {
//       final format12 = DateFormat("h:mm a");
//       final dateTime = format12.parse(time12Hour);
//
//       final format24 = DateFormat("HH:mm");
//       return format24.format(dateTime);
//     } catch (e) {
//       return time12Hour;
//     }
//   }
//
//   Future<void> _submitAppointment(BuildContext context) async {
//     // Validate if all fields are selected
//     if (_selectedBeneficiary == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a beneficiary')),
//       );
//       return;
//     }
//
//     if (selectedTimeSlot.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a time slot')),
//       );
//       return;
//     }
//
//     setState(() {
//       isLoading = true; // Show loader
//     });
//
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//     String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
//     String selectedTime = convertTo24HourFormat(selectedTimeSlot);
//
//     String timeFmt = selectedTime.replaceAll(":", "-");
//     String appointment = "$formattedDate-$timeFmt";
//     String appointmentDate = "$formattedDate $selectedTime";
//
//     final appointmentData = {
//       "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
//       "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
//       "link": "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
//       "appointmentDate": appointmentDate,
//       "mobile": userData?.phoneNumber,
//       "email": userData?.kyc?.email,
//       "prescription": "",
//       "doctorOsid": widget.createAppointmentArgs?.doctorOsid,
//       "status": "new",
//       "walletId": userData?.wallet
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse('https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/Appointment'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(appointmentData),
//       );
//
//       setState(() {
//         isLoading = false;  // Hide loader
//       });
//
//       if (response.statusCode == 200) {
//         // Redirect to the home page after a successful appointment booking
//         Navigator.of(context).pop();  // Close the current screen
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Appointment successfully booked!')),
//         );
//
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to book appointment. Please try again.')),
//         );
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;  // Hide loader on error
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error occurred: $e')),
//       );
//     }
//   }
//
//   void _disableRandomSlots(List<String> slots) {
//     List<String> availableSlots = slots.where((slot) => slot != selectedTimeSlot).toList();
//
//     if (availableSlots.length > 2) {
//       final random = Random();
//       int index1 = random.nextInt(availableSlots.length);
//       int index2 = random.nextInt(availableSlots.length);
//
//       // Ensure different indices and not zero
//       while (index2 == index1 || index1 == 0 || index2 == 0) {
//         index2 = random.nextInt(availableSlots.length);
//       }
//
//       setState(() {
//         disabledSlots.add(availableSlots[index1]);
//         disabledSlots.add(availableSlots[index2]);
//       });
//     }
//   }
//   //
//   // Future<void> _selectDate(BuildContext context) async {
//   //   final DateTime? picked = await showDatePicker(
//   //     context: context,
//   //     initialDate: selectedDate,
//   //     firstDate: DateTime.now(),
//   //     lastDate: DateTime(2030),
//   //   );
//   //
//   //   // if (picked != null && picked != selectedDate)
//   //     setState(() {
//   //       selectedDate = picked!;
//   //     });
//   // }
//
//   Future<void> _selectDate(BuildContext context) async {
//     try {
//       final DateTime? picked = await showDatePicker(
//         context: context,
//         initialDate: selectedDate,
//         firstDate: DateTime.now(),
//         lastDate: DateTime(2030),
//         builder: (BuildContext context, Widget? child) {
//           // Optional: Customize the dialog theme
//           return Theme(
//             data: Theme.of(context).copyWith(
//               colorScheme: ColorScheme.light(
//                 primary: Colors.blue, // Header background color
//                 onPrimary: Colors.white, // Header text color
//                 onSurface: Colors.black, // Body text color
//               ),
//             ),
//             child: child!,
//           );
//         },
//       );
//
//       if (picked != null && picked != selectedDate) {
//         setState(() {
//           selectedDate = picked; // Update state only if a new date is picked
//         });
//       }
//     } catch (e) {
//       // Handle any potential errors
//       debugPrint("Error selecting date: $e");
//     }
//   }
//
//
//   void _showBeneficiariesPopup() {
//     // Ensure that beneficiary selection does not trigger unnecessary re-renders
//     Beneficiary? defaultBeneficiary;
//     var userData = widget.createAppointmentArgs?.userDataEntity;
//
//     if (_beneficiaries.isEmpty && userData != null) {
//       defaultBeneficiary = Beneficiary(
//         name: userData.kyc?.firstName ?? "Unknown Name",
//         relationship: "self",
//         age: 30,
//         abhaId: userData.kyc?.provider.id ?? "Unknown ABHA ID",
//       );
//       _selectedBeneficiary = defaultBeneficiary;
//     }
//
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(10),
//           topRight: Radius.circular(10),
//         ),
//       ),
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return ClipRRect(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(10),
//             topRight: Radius.circular(10),
//           ),
//           child: Container(
//             color: Colors.white,
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Select Beneficiary",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 SizedBox(height: 16.0),
//                 if (_beneficiaries.isEmpty)
//                   ListTile(
//                     title: Text(defaultBeneficiary?.name ?? "No name available"),
//                     subtitle: Text(defaultBeneficiary?.relationship ?? "No relationship"),
//                     leading: Radio<Beneficiary>(
//                       value: defaultBeneficiary!,
//                       groupValue: _selectedBeneficiary,
//                       onChanged: (Beneficiary? value) {
//                         setState(() {
//                           _selectedBeneficiary = value;
//                         });
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                   ),
//                 if (_beneficiaries.isNotEmpty)
//                   Expanded(
//                     child: ListView.builder(
//                       itemCount: _beneficiaries.length,
//                       itemBuilder: (context, index) {
//                         final beneficiary = _beneficiaries[index];
//                         return ListTile(
//                           title: Text(beneficiary.name),
//                           subtitle: Text(beneficiary.relationship),
//                           leading: Radio<Beneficiary>(
//                             value: beneficiary,
//                             groupValue: _selectedBeneficiary,
//                             onChanged: (Beneficiary? value) {
//                               setState(() {
//                                 _selectedBeneficiary = value;
//                               });
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//   // void _showBeneficiariesPopup() {
//   //   // Check if there are no beneficiaries
//   //   Beneficiary? defaultBeneficiary;
//   //   var userData = widget.createAppointmentArgs?.userDataEntity;
//   //
//   //   // Create a default beneficiary if no beneficiaries are available
//   //   if (_beneficiaries.isEmpty && userData != null) {
//   //     defaultBeneficiary = Beneficiary(
//   //       name: userData.kyc?.firstName ?? "Unknown Name",
//   //       relationship: "self", // Default to 'self'
//   //       age: 30, // Add a default age (you may replace this if you have age data)
//   //       abhaId: userData.kyc?.provider.id ?? "Unknown ABHA ID",
//   //     );
//   //     _selectedBeneficiary = defaultBeneficiary; // Automatically select the default beneficiary
//   //   }
//   //
//   //   showModalBottomSheet(
//   //     context: context,
//   //     shape: RoundedRectangleBorder(
//   //       borderRadius: BorderRadius.only(
//   //         topLeft: Radius.circular(10), // Top left corner radius
//   //         topRight: Radius.circular(10), // Top right corner radius
//   //       ),
//   //     ),
//   //     backgroundColor: Colors.transparent, // Set background color to transparent
//   //     builder: (BuildContext context) {
//   //       return ClipRRect(
//   //         borderRadius: BorderRadius.only(
//   //           topLeft: Radius.circular(10), // Top left corner radius
//   //           topRight: Radius.circular(10), // Top right corner radius
//   //         ),
//   //         child: Container(
//   //           color: Colors.white, // Set background color to white
//   //           padding: EdgeInsets.all(16.0),
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 "Select Beneficiary",
//   //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //               ),
//   //               SizedBox(height: 16.0),
//   //               // If no beneficiaries, show default
//   //               if (_beneficiaries.isEmpty)
//   //                 ListTile(
//   //                   title: Text(defaultBeneficiary?.name ?? "No name available"),
//   //                   subtitle: Text(defaultBeneficiary?.relationship ?? "No relationship"),
//   //                   leading: Radio<Beneficiary>(
//   //                     value: defaultBeneficiary!,
//   //                     groupValue: _selectedBeneficiary,
//   //                     onChanged: (Beneficiary? value) {
//   //                       setState(() {
//   //                         _selectedBeneficiary = value;
//   //                       });
//   //                       Navigator.of(context).pop();  // Close the modal after selection
//   //                     },
//   //                   ),
//   //                 ),
//   //               // If beneficiaries are available, show them
//   //               if (_beneficiaries.isNotEmpty)
//   //                 Expanded(
//   //                   child: ListView.builder(
//   //                     itemCount: _beneficiaries.length,
//   //                     itemBuilder: (context, index) {
//   //                       final beneficiary = _beneficiaries[index];
//   //                       return ListTile(
//   //                         title: Text(beneficiary.name),
//   //                         subtitle: Text(beneficiary.relationship),
//   //                         leading: Radio<Beneficiary>(
//   //                           value: beneficiary,
//   //                           groupValue: _selectedBeneficiary,
//   //                           onChanged: (Beneficiary? value) {
//   //                             setState(() {
//   //                               _selectedBeneficiary = value;
//   //                             });
//   //                             Navigator.of(context).pop();  // Close the modal after selection
//   //                           },
//   //                         ),
//   //                       );
//   //                     },
//   //                   ),
//   //                 ),
//   //             ],
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     TimeOfDay now = TimeOfDay.now();
//     TimeOfDay morningStart = TimeOfDay(hour: 9, minute: 0);
//     TimeOfDay morningEnd = TimeOfDay(hour: 11, minute: 0);
//     TimeOfDay eveningStart = TimeOfDay(hour: 11, minute: 0);
//     TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);
//
//     List<String> morningSlots = [];
//     List<String> eveningSlots = [];
//
//     if (selectedDate.day == DateTime.now().day) {
//       if (now.hour < morningEnd.hour || (now.hour == morningEnd.hour && now.minute < morningEnd.minute)) {
//         morningSlots = _generateTimeSlots(now.hour >= morningStart.hour ? now : morningStart, morningEnd);
//       }
//       if (now.hour < eveningEnd.hour || (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
//         eveningSlots = _generateTimeSlots(now.hour >= eveningStart.hour ? now : eveningStart, eveningEnd);
//       }
//     } else {
//       morningSlots = _generateTimeSlots(morningStart, morningEnd);
//       eveningSlots = _generateTimeSlots(eveningStart, eveningEnd);
//     }
//
//     _disableRandomSlots(morningSlots);
//     _disableRandomSlots(eveningSlots);
//
//     return Scaffold(
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100),
//         child: CommonTopHeader(
//           title: 'Book Appointment',
//           isTitleOnly: false,
//           dividerColor: Colors.grey,
//           onBackButtonPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: isLoading
//           ? Center(child: CircularProgressIndicator()) // Show loader
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 16.0),
//             ListTile(
//               title: Text("Select Date"),
//               subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
//               trailing: Icon(Icons.calendar_today),
//               onTap: () => _selectDate(context),
//             ),
//             SizedBox(height: 16.0),
//
//             // Morning Slots
//             Text("Select Morning Slot", style: TextStyle(fontWeight: FontWeight.bold)),
//             morningSlots.isNotEmpty
//                 ? Wrap(
//               spacing: 8.0,
//               children: morningSlots.map((String time) {
//                 return ChoiceChip(
//                   label: Text(time, style: TextStyle(color: Colors.white)),
//                   selected: selectedTimeSlot == time,
//                   onSelected: disabledSlots.contains(time)
//                       ? null
//                       : (bool selected) {
//                     setState(() {
//                       selectedTimeSlot = time;
//                     });
//                   },
//                   selectedColor: Colors.blue,
//                   backgroundColor: Colors.blue,
//                   disabledColor: Colors.grey,
//                 );
//               }).toList(),
//             )
//                 : Text("No morning slots available"),
//             SizedBox(height: 16.0),
//
//             // Evening Slots
//             Text("Select Evening Slot", style: TextStyle(fontWeight: FontWeight.bold)),
//             eveningSlots.isNotEmpty
//                 ? Wrap(
//               spacing: 8.0,
//               children: eveningSlots.map((String time) {
//                 return ChoiceChip(
//                   label: Text(time, style: TextStyle(color: Colors.white)),
//                   selected: selectedTimeSlot == time,
//                   onSelected: disabledSlots.contains(time)
//                       ? null
//                       : (bool selected) {
//                     setState(() {
//                       selectedTimeSlot = time;
//                     });
//                   },
//                   selectedColor: Colors.blue,
//                   backgroundColor: Colors.blue,
//                   disabledColor: Colors.grey,
//                 );
//               }).toList(),
//             )
//                 : Text("No evening slots available"),
//             SizedBox(height: 16.0),
//
//             // Select Beneficiary Button
//             ElevatedButton(
//               onPressed: () {
//                 _showBeneficiariesPopup();  // Show beneficiary selection popup
//               },
//               child: Text(_selectedBeneficiary == null
//                   ? 'Select Beneficiary'
//                   : _selectedBeneficiary!.name),
//               style: ElevatedButton.styleFrom(
//                 foregroundColor: Colors.white,
//                 backgroundColor: Colors.blue,
//                 minimumSize: Size(double.infinity, 50),
//               ).copyWith(
//                 shape: WidgetStateProperty.all(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(height: 16.0),
//             ElevatedButton(
//               onPressed: () => _submitAppointment(context),
//               child: Text('Book Appointment', style: TextStyle(color:Color(
//                   0xFF1581BF))), // Black text
//               style: ElevatedButton.styleFrom(
//                 side: BorderSide(color: Color(
//                     0xFF1581BF), width: 2), // Blue border
//                 backgroundColor: Colors.white, // No background color
//                 minimumSize: Size(double.infinity, 50),
//
//               ).copyWith(
//                 shape: WidgetStateProperty.all(
//                   RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(5), // No rounded corners
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  final CreateAppointmentArgs? createAppointmentArgs;

  const CreateAppointment({super.key, required this.createAppointmentArgs});

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
    _loadBeneficiaries();
    _updateTimeSlots();
  }

  Future<void> _loadBeneficiaries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');

      var userData = widget.createAppointmentArgs?.userDataEntity;
      if (userData != null) {
        Beneficiary defaultBeneficiary = Beneficiary(
          name: userData.kyc?.firstName ?? "Default Name",
          relationship: "self",
          age: 30,
          abhaId: userData.kyc?.provider?.id ?? "default-abha-id",
        );
        setState(() {
          _selectedBeneficiary = defaultBeneficiary;
          _beneficiaries = [defaultBeneficiary] + (beneficiariesJson != null
              ? beneficiariesJson
              .map((jsonStr) => Beneficiary.fromJson(jsonStr))
              .toList()
              : []);
        });
      } else {
        setState(() {
          _beneficiaries = beneficiariesJson != null
              ? beneficiariesJson
              .map((jsonStr) => Beneficiary.fromJson(jsonStr))
              .toList()
              : [];
        });
      }
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
    TimeOfDay eveningEnd = TimeOfDay(hour: 21, minute: 0);

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
              now.hour >= morningStart.hour ? now : morningStart,
              morningEnd
          );
        }
        if (now.hour < eveningEnd.hour ||
            (now.hour == eveningEnd.hour && now.minute < eveningEnd.minute)) {
          _eveningSlots = _generateTimeSlots(
              now.hour >= eveningStart.hour ? now : eveningStart,
              eveningEnd
          );
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

  Future<void> _submitAppointment(BuildContext context) async {
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
      var userData = widget.createAppointmentArgs?.userDataEntity;
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
      String selectedTime = convertTo24HourFormat(selectedTimeSlot);

      String timeFmt = selectedTime.replaceAll(":", "-");
      String appointment = "$formattedDate-$timeFmt";
      String appointmentDate = "$formattedDate $selectedTime";

      final appointmentData = {
        "abhaId": _selectedBeneficiary?.abhaId ?? userData?.kyc?.provider.id,
        "patientName": _selectedBeneficiary?.name ?? userData?.kyc?.firstName,
        "link": "https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/${_selectedBeneficiary?.name ?? userData?.kyc?.firstName}-TeleConsultation-${appointment}",
        "appointmentDate": appointmentDate,
        "mobile": userData?.phoneNumber,
        "email": userData?.kyc?.email,
        "prescription": "",
        "doctorOsid": widget.createAppointmentArgs?.doctorOsid,
        "status": "new",
        "walletId": userData?.wallet
      };

      print("appointment Data");
      print(appointmentData);
      print(appointmentDate);
      final response = await http.post(
        Uri.parse('https://2887-203-201-231-35.ngrok-free.app/registry/api/v1/Appointment'),
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

  void _showBeneficiariesPopup() {
    Beneficiary? defaultBeneficiary;
    var userData = widget.createAppointmentArgs?.userDataEntity;

    if (_beneficiaries.isEmpty && userData != null) {
      defaultBeneficiary = Beneficiary(
        name: userData.kyc?.firstName ?? "Unknown Name",
        relationship: "self",
        age: 30,
        abhaId: userData.kyc?.provider.id ?? "Unknown ABHA ID",
      );
      _selectedBeneficiary = defaultBeneficiary;
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Beneficiary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16.0),
              if (_beneficiaries.isEmpty && defaultBeneficiary != null)
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
                    // Trigger the same behavior as the Radio button when ListTile is tapped
                    setState(() {
                      _selectedBeneficiary = defaultBeneficiary; // Select the value
                    });
                    Navigator.pop(context); // Close the dialog or popup
                  },
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: _beneficiaries.length,
                    itemBuilder: (context, index) {
                      final beneficiary = _beneficiaries[index];
                      // return ListTile(
                      //   // title: Text(beneficiary.name),
                      //   title: Text(
                      //     beneficiary.name.isNotEmpty
                      //         ? '${beneficiary.name[0].toUpperCase()}${beneficiary.name.substring(1)}'
                      //         : 'No Name', // Fallback if name is empty
                      //   ),
                      //   subtitle: Text(beneficiary.relationship),
                      //   leading: Radio<Beneficiary>(
                      //     value: beneficiary,
                      //     groupValue: _selectedBeneficiary,
                      //     onChanged: (value) {
                      //       setState(() => _selectedBeneficiary = value);
                      //       Navigator.pop(context);
                      //     },
                      //   ),
                      // );
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
                            setState(() {
                              _selectedBeneficiary = value; // Update the selected beneficiary
                            });
                            Navigator.pop(context); // Close the dialog or popup
                          },
                        ),
                        onTap: () {
                          // Trigger the same behavior as the Radio button when ListTile is tapped
                          setState(() {
                            _selectedBeneficiary = beneficiary; // Select the value when ListTile is tapped
                          });
                          Navigator.pop(context); // Close the dialog or popup
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

  Widget _buildTimeSlotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        slots.isEmpty
            ? Text("No slots available")
            : Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: slots.map((String time) {
            bool isDisabled = disabledSlots.contains(time);
            return ChoiceChip(
              label: Text(
                time,
                style: TextStyle(
                  color: isDisabled ? Colors.grey[600] : Colors.white,
                ),
              ),
              selected: selectedTimeSlot == time,
              onSelected: isDisabled ? null : (bool selected) {
                setState(() {
                  selectedTimeSlot = selected ? time : '';
                });
              },
              selectedColor: Color(0xFF1581BF),
              backgroundColor: isDisabled ? Colors.grey[300] : Colors.blue,
              disabledColor: Colors.grey[300],
            );
          }).toList(),
        ),
      ],
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Card(
              color: Colors.white,
              elevation: 4, // Adds a shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              margin: EdgeInsets.all(0), // Adds space around the card
              child: ListTile(
                title: Text("Select Date"),
                subtitle: Text("${selectedDate.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ),


            SizedBox(height: 16.0),

            // Morning Slots
            Text("Select Morning Slot", style: TextStyle(fontWeight: FontWeight.bold)),
            _morningSlots .isNotEmpty
                ? Wrap(
              spacing: 8.0,
              children: _morningSlots .map((String time) {
                return ChoiceChip(
                  label: Text(time, style: TextStyle(color: Colors.white)),
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
            Text("Select Evening Slot", style: TextStyle(fontWeight: FontWeight.bold)),
            _eveningSlots .isNotEmpty
                ? Wrap(
              spacing: 8.0,
              children: _eveningSlots .map((String time) {
                return ChoiceChip(
                  label: Text(time, style: TextStyle(color: Colors.white)),
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
                _showBeneficiariesPopup();  // Show beneficiary selection popup
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
                elevation: 5, // Add shadow depth
                shadowColor: Colors.grey.withOpacity(0.5), // Shadow color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _submitAppointment(context),
              child: Text('Book Appointment', style: TextStyle(color:Color(
                  0xFF1581BF))), // Black text
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Color(
                    0xFF1581BF), width: 2), // Blue border
                backgroundColor: Colors.white, // No background color
                minimumSize: Size(double.infinity, 50),

              ).copyWith(
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // No rounded corners
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
