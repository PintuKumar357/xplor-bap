import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../../../../utils/common_top_header.dart'; // Import this package for formatting date and time

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // for DateFormat
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Documents',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HealthDocumentsPage(),
    );
  }
}

class HealthDocumentsPage extends StatefulWidget {
  const HealthDocumentsPage({super.key});

  @override
  State<HealthDocumentsPage> createState() => _HealthDocumentsPageState();
}

class _HealthDocumentsPageState extends State<HealthDocumentsPage> {
  // Sample data to display for records
  final List<Map<String, dynamic>> healthRecords = [
    {
      'title': 'Diagnostic Report',
      'description': 'View detailed diagnostic report',
      'icon': Icons.analytics,
      'date': DateTime.now(),
      'hospitalName': 'ABC Hospital',
      'doctorName': 'Dr. John Doe',
      'laboratoryRecord': 'Laboratory A - Blood Test',
      'hospitalImage':
          'https://i.ibb.co/5xmzCgM/hospital-data.jpg', // Added image URL
    },
    {
      'title': 'Discharge Summary',
      'description': 'View discharge summary from hospital',
      'icon': Icons.medical_services,
      'date': DateTime.now().subtract(Duration(days: 1)),
      'hospitalName': 'XYZ Medical Center',
      'doctorName': 'Dr. Alice Smith',
      'laboratoryRecord': 'Laboratory B - X-ray',
      'hospitalImage':
          'https://i.ibb.co/5xmzCgM/hospital-data.jpg', // Added image URL
    },
    {
      'title': 'Health Document',
      'description': 'View general health documents',
      'icon': Icons.document_scanner,
      'date': DateTime.now().subtract(Duration(days: 2)),
      'hospitalName': 'Health Plus Clinic',
      'doctorName': 'Dr. Mike Johnson',
      'laboratoryRecord': 'Laboratory C - General Checkup',
      'hospitalImage':
          'https://i.ibb.co/5xmzCgM/hospital-data.jpg', // Added image URL
    },
    {
      'title': 'Immunization Record',
      'description': 'View immunization records',
      'icon': Icons.health_and_safety,
      'date': DateTime.now().subtract(Duration(days: 3)),
      'hospitalName': 'Family Health Clinic',
      'doctorName': 'Dr. Emily Davis',
      'laboratoryRecord': 'Laboratory A - Vaccination',
      'hospitalImage':
          'https://i.ibb.co/5xmzCgM/hospital-data.jpg', // Added image URL
    },
    {
      'title': 'OP Consultation',
      'description': 'View outpatient consultation details',
      'icon': Icons.local_hospital,
      'date': DateTime.now().subtract(Duration(days: 4)),
      'hospitalName': 'General Hospital',
      'doctorName': 'Dr. Robert Brown',
      'laboratoryRecord': 'Laboratory B - ECG',
      'hospitalImage':
          'https://i.ibb.co/5xmzCgM/hospital-data.jpg', // Added image URL
    },
  ];
  List<Map<String, dynamic>> healthRecords2 = [];
  bool _isLoading = false;

  void fetchUserRecords() async {
    try {
      setState(() => _isLoading = true);

      print("Fetching users...");
      final url = Uri.parse(
          'https://api.myjson.online/v1/records/4016cb07-f6d2-4bc8-997c-1acf6238e3f7');

      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final body = response.body;
        final Map<String, dynamic> jsonMap = jsonDecode(body);
        final List<dynamic> jsonData = jsonMap['data'] as List<dynamic>;
        setState(() {
          healthRecords2 =
              jsonData.map((item) => item as Map<String, dynamic>).toList();
        });
        print("Users fetched: Complete");
      } else {
        print("Error: Server returned status code ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust height as needed
        child: CommonTopHeader(
          title: 'Health Documents',
          isTitleOnly: false,
          dividerColor: Colors.grey, // Use appropriate color
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor:
          Colors.white, // Set the background color of the body to white
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1581BF)),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Looping through the records to display each card
                  Expanded(
                    child: ListView.builder(
                      itemCount: healthRecords2.length,
                      itemBuilder: (context, index) {
                        final record = healthRecords2[index];
                        return Card(
                          color: Colors
                              .white, // Set the card background color to white
                          margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10), // Margin set to 10px
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Hospital Name above the Title
                                // Space between the hospital name and the title

                                // Title and Description in Row
                                Row(
                                  children: [
                                    // Left side: Image (Hospital image)
                                    Container(
                                      width: 100, // Reduced size for the image
                                      height: 100, // Reduced size for the image
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            10), // Border radius for rounded corners
                                        image: DecorationImage(
                                          image: NetworkImage(record[
                                              'hospitalImage']), // Use the hospital image URL from the data
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            16), // Add space between the image and the text

                                    // Right side: Health Document Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            record['hospitalName'],
                                            style: TextStyle(
                                              fontSize:
                                                  16, // Larger font for the hospital name
                                              fontWeight: FontWeight.bold,
                                              color: Colors
                                                  .blue, // Color for the hospital name
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          // Title
                                          Text(
                                            record['title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(
                                              height:
                                                  5), // Space between title and description

                                          // Description
                                          Text(
                                            record['description'],
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey),
                                          ),
                                          SizedBox(
                                              height:
                                                  5), // Space between description and date

                                          // Date
                                          Text(
                                            //DateFormat('yyyy-MM-dd HH:mm').format(record['date'])),
                                            DateFormat('yyyy-MM-dd HH:mm')
                                                .format(DateTime.parse(
                                                    record['date'])),
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                    height:
                                        10), // Space between content and button

                                // Full-width Button (with border and text)
                                Container(
                                  width: double
                                      .infinity, // Makes the button stretch across the card width
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navigate to the details page with the selected record's data
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HealthDetailsPage(record: record),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'View Details',
                                      style: TextStyle(
                                        color: Color(
                                            0xFF1581BF), // Green text color
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .white, // White background for the button
                                      side: BorderSide(
                                          color: Color(
                                              0xFF1581BF)), // Green border color
                                      padding: EdgeInsets.all(
                                          12), // Padding inside the button
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            6), // Rounded corners for button
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class HealthDetailsPage extends StatelessWidget {
  final Map<String, dynamic> record;

  HealthDetailsPage({required this.record});

  @override
  Widget build(BuildContext context) {
    // Safely access 'labDescription' and provide a fallback if it's null
    final labDescription = record['labDescription'] ??
        'No description available for this laboratory record.';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust height as needed
        child: CommonTopHeader(
          title: 'Health Details',
          isTitleOnly: false,
          dividerColor: Colors.grey, // Use appropriate color
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white, // Set the background color to white
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // This will allow scrolling if content is too long
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hospital Image at the top of the details page
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(record['hospitalImage']),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 20),

              // Hospital Name Section
              Text('Hospital Name:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(record['hospitalName'], style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Doctor Name Section
              Text('Doctor:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(record['doctorName'], style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Document Title Section
              Text('Document Title:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(record['title'], style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Document Description Section
              Text('Document Description:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(record['description'], style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Date of Record Section
              Text('Date:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(DateFormat('yyyy-MM-dd HH:mm').format(record['date']),
                  style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Laboratory Record Section
              Text('Laboratory Record:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(record['laboratoryRecord'], style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),

              // Lab Description Section (using the labDescription safely)
              Text('Lab Description:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(labDescription, style: TextStyle(fontSize: 16)),
              Divider(
                color: Color(0xFF1581BF), // Set the color to the specified blue
                thickness:
                    1.5, // Optional: You can adjust the thickness of the divider
              ),
            ],
          ),
        ),
      ),
    );
  }
}
