
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xplor/features/apply_course/data/data_sources/apply_form_service.dart';
import 'package:xplor/utils/extensions/string_to_string.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../on_boarding/domain/entities/user_data_entity.dart';
import 'package:intl/intl.dart';

class IssuePrescriptionPage extends StatefulWidget {
  final UserDataEntity? userData;
  const IssuePrescriptionPage({super.key, required this.userData});

  @override
  _IssuePrescriptionPageState createState() => _IssuePrescriptionPageState();
}

class _IssuePrescriptionPageState extends State<IssuePrescriptionPage> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  Map<String, dynamic> doctorData = {};
  List<dynamic> hospitalData = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = '';
      });

      // Fetch both sets of data concurrently
      await Future.wait([
        _fetchHospitaloneRecords(),
        _fetchHospitalRecords(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load data. Please try again.';
      });
    }
  }

  Future<void> _fetchHospitalRecords() async {
    final url = Uri.parse(
        'https://2887-203-201-231-35.ngrok-free.app/registry/api/v1/PrescriptionCredential/search');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'offset': 0,
          'limit': 500,
          'filters': {},
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> records = responseData['data'] ?? [];
        if (mounted) {
          setState(() {
            doctorData = {for (var item in records) item["osid"]: item};
          });
        }
      } else {
        throw Exception('Failed to load hospital records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hospital records: $e');
      throw e;
    }
  }

  Future<void> _fetchHospitaloneRecords() async {
    final url = Uri.parse(
        'https://2887-203-201-231-35.ngrok-free.app/registry/api/v1/Hospital/search');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'offset': 0,
          'limit': 500,
          'filters': {},
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> records = responseData['data'] ?? [];
        if (mounted) {
          setState(() {
            hospitalData = records;
          });
        }
      } else {
        throw Exception('Failed to load hospital records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hospital records: $e');
      throw e;
    }
  }

  void _navigateToPramaPage(BuildContext context, String doctorName, String osid, List<dynamic> drugPrescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PramaPage(
          doctorName: doctorName,
          osid: osid,
          drugPrescription: drugPrescription,
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _initializeData,
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1581BF),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: CommonTopHeader(
          title: 'View Prescription',
          isTitleOnly: false,
          dividerColor: Colors.grey,
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1581BF)),
        ),
      )
          : _hasError
          ? _buildErrorView()
          : doctorData.isNotEmpty
          ? ListView.builder(
        itemCount: doctorData.length,
        itemBuilder: (context, index) {
          final key = doctorData.keys.elementAt(index);
          final record = doctorData[key];

          var doctor = hospitalData.firstWhere(
                (doctor) => doctor['osid'] == record["doctorOsid"],
            orElse: () => null,  // Return null if no match is found
          );
          final doctorPhoto = doctor["doctorPhoto"];

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        child: doctorPhoto != null && doctorPhoto.isNotEmpty
                            ? Image.network(
                          doctorPhoto,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 50,
                              color: Color(0xFF1581BF),
                            );
                          },
                        )
                            : Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF1581BF),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record["doctorName"] ?? "No Name",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Beneficiary: ${record["patientName"].toString().capitalizeFirstLetter()}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              "Prescription Issued Date: ${_formatDateTime(record["osUpdatedAt"])}",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: record["status"] == "completed"
                          ? null
                          : () {
                        _navigateToPramaPage(
                          context,
                          record["doctorName"] ?? "No Name",
                          record["osid"] ?? "No ID",
                          record["drugPrescription"] ?? [],
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: record["status"] == "completed" ? Colors.grey[300] : Colors.white,
                        side: BorderSide(
                          color: record["status"] == "completed" ? Colors.grey : Color(0xFF1581BF),
                        ),
                        foregroundColor: record["status"] == "completed" ? Colors.grey[600] : Color(0xFF1581BF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Order Medicine"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          "No records found",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  String _formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return "No Data";
    }

    try {
      DateTime dateTime = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      print("Error formatting date: $e");
      return "Invalid Date";
    }
  }
}
class PramaPage extends StatelessWidget {
  final String doctorName;
  final String osid;
  final List<dynamic> drugPrescription; // Add this field

  PramaPage({
    Key? key,
    required this.doctorName,
    required this.osid,
    required this.drugPrescription,
  }) : super(key: key);

  // Mock data for pharmacies
  final List<Map<String, dynamic>> pramaData = [
    {
      "name": "HealthCare Pharmacy",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Koramangala, Bangalore",
      "distance": "1.5 km",
    },
    {
      "name": "Wellness Meds",
      "photo": "https://i.ibb.co/99CWsrr/d1.webp",
      "location": "Indiranagar, Bangalore",
      "distance": "3.0 km",
    },
    {
      "name": "Prime Pharmacy",
      "photo": "https://i.ibb.co/MRK57g0/d2.jpg",
      "location": "MG Road, Bangalore",
      "distance": "2.2 km",
    },
  ];

  void _navigateToOrderSummaryPage(BuildContext context, String pramaName, String doctorName, String osid, List<dynamic> drugPrescription) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(
          pramaName: pramaName,
          doctorName: doctorName,
          osid: osid,
          drugPrescription: drugPrescription, // Pass the drugPrescription data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: CommonTopHeader(
          title: 'Prama List',
          isTitleOnly: false,
          dividerColor: Colors.grey,
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        itemCount: pramaData.length,
        itemBuilder: (context, index) {
          final prama = pramaData[index];
          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row for image and details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pharmacy Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          prama["photo"],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Pharmacy Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prama["name"],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Location: ${prama["location"]}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Distance: ${prama["distance"]}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, // Makes the button take the full width
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToOrderSummaryPage(
                          context,
                          prama["name"],      // pramaName
                          doctorName,         // doctorName
                          osid,               // osid
                          drugPrescription ?? [], // Pass drugPrescription (avoid null)
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 7),
                        side: BorderSide(color: Color(0xFF1581BF), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Place Order",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1581BF)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class OrderSummaryPage extends StatefulWidget {
  final String pramaName;
  final String doctorName;
  final String osid;
  final List<dynamic> drugPrescription;

  OrderSummaryPage({
    required this.pramaName,
    required this.doctorName,
    required this.osid,
    required this.drugPrescription,
  });

  @override
  _OrderSummaryPageState createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  bool isLoading = false;

  Future<bool> endAppointmentHandler(String osid) async {
    setState(() {
      isLoading = true;
    });

    final data = {
      "osid": osid,
      "status": "completed",
    };
    print("ok......................................");
    print("Data being sent: $data");
    print("ok......................................");
    try {
      final response = await http.put(
        Uri.parse(
            'https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/PrescriptionCredential/$osid'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        print("Appointment ended successfully.");
        return true;
      } else {
        print("Failed to place order. Status: ${response.statusCode}");
        return false;
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print("Error: $error");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Base values
    double baseAmount = 1000.0;
    double taxPercentage = 18.0;
    double discount = 150.0;
    double shippingFee = 50.0;

    // Tablet total amount calculation (including ₹10 or ₹20 additional per tablet)
    double tabletTotalAmount = 0;
    final random = Random();
    for (var prescription in widget.drugPrescription) {
      // Ensure both values are treated as doubles
      double tabletAmount = (prescription['amount'] ?? 0).toDouble() + (10 + random.nextInt(11)).toDouble();
      tabletTotalAmount += tabletAmount;
      prescription['finalAmount'] = tabletAmount; // Store the updated amount for display
    }
    // Additional calculations
    double taxAmount = (baseAmount * taxPercentage) / 100;
    double totalAmount = baseAmount + taxAmount + shippingFee - discount;

    // Random discount for the bill
    double deduction = (tabletTotalAmount * (5 + random.nextInt(15)) / 100).roundToDouble();
    double finalAmount = tabletTotalAmount + totalAmount - deduction;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(100),
            child: CommonTopHeader(
              title: 'Medical Bill Invoice',
              isTitleOnly: false,
              dividerColor: Colors.grey,
              onBackButtonPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pharma Name: ${widget.pramaName}",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Divider(),
                Text(
                  "Doctor's Name: ${widget.doctorName}",
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                Divider(),
                Text(
                  "Items Purchased:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                widget.drugPrescription.isNotEmpty
                    ? ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.drugPrescription.length,
                  itemBuilder: (context, index) {
                    final prescription = widget.drugPrescription[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            prescription['tablet'] ?? 'N/A',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            "₹${prescription['finalAmount']?.toStringAsFixed(2) ?? '0.00'}",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "No items purchased.",
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
                Divider(),
                Text(
                  "Cost Breakdown:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Base Amount:", style: TextStyle(fontSize: 16)),
                    Text("₹${baseAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tax (${taxPercentage.toStringAsFixed(0)}%):", style: TextStyle(fontSize: 16)),
                    Text("₹${taxAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Shipping Fee:", style: TextStyle(fontSize: 16)),
                    Text("₹${shippingFee.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Discount:", style: TextStyle(fontSize: 16)),
                    Text("-₹${discount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
                  ],
                ),
                Divider(),
                Text(
                  "Additional Charges:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text("1. Pharmacy Service Charge: ₹50", style: TextStyle(fontSize: 16)),
                Text("2. Packaging and Handling: ₹30", style: TextStyle(fontSize: 16)),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tablet Total:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹$tabletTotalAmount",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Discount Applied:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "- ₹$deduction",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Payable Amount:",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "₹$finalAmount",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () async {
                        print("Order placed for ${widget.pramaName}");
                        final success = await endAppointmentHandler(widget.osid);
                        if (success) {
                          Navigator.pushReplacementNamed(context, '/seekerHome');
                        } else {
                          print("Failed to place order or end appointment");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1581BF),
                        foregroundColor: Colors.white,
                      ),
                      child: Text("Confirm Payment"),
                    ),
                    ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black,
                      ),
                      child: Text("Cancel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1581BF)),
              ),
            ),
          ),
      ],
    );
  }
}


// class OrderSummaryPage extends StatelessWidget {
//   bool isLoading = false;
//   final String pramaName;
//   final String doctorName;
//   final String osid;
//   final List<dynamic> drugPrescription;
//
//   OrderSummaryPage({
//     required this.pramaName,
//     required this.doctorName,
//     required this.osid,
//     required this.drugPrescription,
//   });
//
//   Future<bool> endAppointmentHandler(String osid) async {
//     final data = {
//       "osid": osid,
//       "status": "completed",
//     };
//     print("ok......................................");
//     print("Data being sent: $data");
//     print("ok......................................");
//     try {
//       final response = await http.put(
//         Uri.parse(
//             'https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/PrescriptionCredential/$osid'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(data),
//       );
//
//       if (response.statusCode == 200) {
//         print("Appointment ended successfully.");
//         return true;
//       } else {
//         print("Failed to place order. Status: ${response.statusCode}");
//         return false;
//       }
//     } catch (error) {
//       print("Error: $error");
//       return false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Base values
//     double baseAmount = 1000.0;
//     double taxPercentage = 18.0;
//     double discount = 150.0;
//     double shippingFee = 50.0;
//
//     // Tablet total amount calculation (including ₹10 or ₹20 additional per tablet)
//     double tabletTotalAmount = 0;
//     final random = Random();
//     for (var prescription in drugPrescription) {
//       // Ensure both values are treated as doubles
//       double tabletAmount = (prescription['amount'] ?? 0).toDouble() + (10 + random.nextInt(11)).toDouble();
//       tabletTotalAmount += tabletAmount;
//       prescription['finalAmount'] = tabletAmount; // Store the updated amount for display
//     }
//     // Additional calculations
//     double taxAmount = (baseAmount * taxPercentage) / 100;
//     double totalAmount = baseAmount + taxAmount + shippingFee - discount;
//
//     // Random discount for the bill
//     double deduction = (tabletTotalAmount * (5 + random.nextInt(15)) / 100).roundToDouble();
//     double finalAmount = tabletTotalAmount + totalAmount - deduction;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: PreferredSize(
//         preferredSize: Size.fromHeight(100),
//         child: CommonTopHeader(
//           title: 'Medical Bill Invoice',
//           isTitleOnly: false,
//           dividerColor: Colors.grey,
//           onBackButtonPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Pharma Name: $pramaName",
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Divider(),
//             Text(
//               "Doctor's Name: $doctorName",
//               style: TextStyle(fontSize: 18),
//             ),
//             SizedBox(height: 16),
//             Divider(),
//             Text(
//               "Items Purchased:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             drugPrescription.isNotEmpty
//                 ? ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: drugPrescription.length,
//               itemBuilder: (context, index) {
//                 final prescription = drugPrescription[index];
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         prescription['tablet'] ?? 'N/A',
//                         style: TextStyle(fontSize: 16),
//                       ),
//                       Text(
//                         "₹${prescription['finalAmount']?.toStringAsFixed(2) ?? '0.00'}",
//                         style: TextStyle(fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//                 : Padding(
//               padding: const EdgeInsets.symmetric(vertical: 8.0),
//               child: Text(
//                 "No items purchased.",
//                 style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
//               ),
//             ),
//             Divider(),
//             Text(
//               "Cost Breakdown:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Base Amount:", style: TextStyle(fontSize: 16)),
//                 Text("₹${baseAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Tax (${taxPercentage.toStringAsFixed(0)}%):", style: TextStyle(fontSize: 16)),
//                 Text("₹${taxAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Shipping Fee:", style: TextStyle(fontSize: 16)),
//                 Text("₹${shippingFee.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Discount:", style: TextStyle(fontSize: 16)),
//                 Text("-₹${discount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
//               ],
//             ),
//             Divider(),
//             Text(
//               "Additional Charges:",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             Text("1. Pharmacy Service Charge: ₹50", style: TextStyle(fontSize: 16)),
//             Text("2. Packaging and Handling: ₹30", style: TextStyle(fontSize: 16)),
//             Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Tablet Total:",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "₹$tabletTotalAmount",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Discount Applied:",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "- ₹$deduction",
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//                 ),
//               ],
//             ),
//             Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Final Payable Amount:",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "₹$finalAmount",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
//                 ),
//               ],
//             ),
//             Divider(),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 ElevatedButton(
//                   onPressed: () async {
//                     print("Order placed for $pramaName");
//                     final success = await endAppointmentHandler(osid);
//                     if (success) {
//                       Navigator.pushReplacementNamed(context, '/seekerHome');
//                     } else {
//                       print("Failed to place order or end appointment");
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF1581BF),
//                     foregroundColor: Colors.white,
//                   ),
//                   child: Text("Confirm Payment"),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey[300],
//                     foregroundColor: Colors.black,
//                   ),
//                   child: Text("Cancel"),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//
//
//     );
//   }
// }

