import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  Map<String, dynamic> doctorData = {};

  @override
  void initState() {
    super.initState();
    _fetchHospitalRecords();
  }

  Future<void> _fetchHospitalRecords() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/Hospital/search');

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
        print("ok.....................");
        print(records);
        print("ok.....................");
        setState(() {
          doctorData = {for (var item in records) item["osid"]: item};
          _isLoading = false;
        });
      } else {
        print('Failed to load hospital records: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching hospital records: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPramaPage(BuildContext context, String doctorName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PramaPage(doctorName: doctorName),
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
        child: CircularProgressIndicator(),
      )
          : doctorData.isNotEmpty
          ? ListView.builder(
        itemCount: doctorData.length,
        itemBuilder: (context, index) {
          final key = doctorData.keys.elementAt(index);
          final record = doctorData[key];

          // Format the date
          String formattedDate = '';
          try {
            if (record["osUpdatedAt"] != null) {
              DateTime date = DateTime.parse(record["osUpdatedAt"]);
              formattedDate = "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
            }
          } catch (e) {
            formattedDate = 'No Date';
          }

          return Card(
            color: Colors.white,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Doctor Photo and Details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Photo
                      Container(
                        width: 100,
                        height: 100,
                        child: record["doctorPhoto"] != null && record["doctorPhoto"].isNotEmpty
                            ? Image.network(
                          record["doctorPhoto"],
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
                      // Doctor Details
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
                            // Text(
                            //   "Prescription Issued Date: $formattedDate",
                            //   style: TextStyle(
                            //     fontSize: 16,
                            //     color: Colors.grey[700],
                            //   ),
                            // ),
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

                  // Divider
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),

                  SizedBox(
                    width: double.infinity, // Makes the button take full width
                    child: ElevatedButton(
                      onPressed: () {
                        _navigateToPramaPage(
                          context,
                          record["doctorName"] ?? "No Name",
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Color(0xFF1581BF)),
                        foregroundColor: Color(0xFF1581BF),
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
  // Helper function to format the date
  String _formatDateTime(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) {
      return "No Data";
    }

    try {
      // Parse the ISO date
      DateTime dateTime = DateTime.parse(isoDate);
      // Format the date in dd-MM-yyyy hh:mm a format
      return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      // Handle parsing errors
      print("Error formatting date: $e");
      return "Invalid Date";
    }
  }

}



class PramaPage extends StatelessWidget {
  final String doctorName;

  PramaPage({required this.doctorName});

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
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Indiranagar, Bangalore",
      "distance": "3.0 km",
    },
    {
      "name": "Prime Pharmacy",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "MG Road, Bangalore",
      "distance": "2.2 km",
    },
    {
      "name": "CurePoint Pharmacy",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Whitefield, Bangalore",
      "distance": "6.5 km",
    },
    {
      "name": "MediCare Shop",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Jayanagar, Bangalore",
      "distance": "4.0 km",
    },
    {
      "name": "PharmaPlus",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Rajajinagar, Bangalore",
      "distance": "5.8 km",
    },
    {
      "name": "VitalCare Pharmacy",
      "photo": "https://i.ibb.co/C2PbvV4/Top-10-Countries-to-Study-Pharmacy.jpg",
      "location": "Electronic City, Bangalore",
      "distance": "8.3 km",
    },

  ];

  void _navigateToOrderSummaryPage(BuildContext context, String pramaName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderSummaryPage(pramaName: pramaName),
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
          title: 'Prama List ',
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
                        _navigateToOrderSummaryPage(context, prama["name"]);
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color:  Color(0xFF1581BF)),
                      ),
                    ),
                  ),

                  // Full-width Place Order Button
                  // ElevatedButton(
                  //   onPressed: () {
                  //     _navigateToOrderSummaryPage(context, prama["name"]);
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Color(0xFF1581BF),
                  //     foregroundColor: Colors.white,
                  //     padding: EdgeInsets.symmetric(vertical: 16),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  //   child: Text(
                  //     "Place Order",
                  //     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class OrderSummaryPage extends StatelessWidget {
  final String pramaName;

  OrderSummaryPage({required this.pramaName});

  @override
  Widget build(BuildContext context) {
    // Example data for the order
    double baseAmount = 1000.0; // Base amount for the order
    double taxPercentage = 18.0; // Tax percentage
    double discount = 150.0; // Fixed discount
    double shippingFee = 50.0; // Shipping fee

    // Calculations
    double taxAmount = (baseAmount * taxPercentage) / 100;
    double totalAmount = baseAmount + taxAmount + shippingFee - discount;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: CommonTopHeader(
          title: 'Order Summary',
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
              "Order Summary for $pramaName",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "Details:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Prama Name: $pramaName",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Divider(),
            Text(
              "Cost Breakdown:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Base Amount:", style: TextStyle(fontSize: 16)),
                Text("₹${baseAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tax (${taxPercentage.toStringAsFixed(0)}%):", style: TextStyle(fontSize: 16)),
                Text("₹${taxAmount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Shipping Fee:", style: TextStyle(fontSize: 16)),
                Text("₹${shippingFee.toStringAsFixed(2)}", style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Discount:", style: TextStyle(fontSize: 16)),
                Text("-₹${discount.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, color: Colors.green)),
              ],
            ),
            Divider(),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total Amount:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${totalAmount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("Order placed for $pramaName");
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Order Placed'),
                        content: Text('Your order for $pramaName has been placed successfully!'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1581BF),
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Place Order"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  child: Text("Cancel Order"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

