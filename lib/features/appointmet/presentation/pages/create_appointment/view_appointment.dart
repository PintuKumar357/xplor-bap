
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../../utils/widgets/app_background_widget.dart';
import '../../../../on_boarding/domain/entities/user_data_entity.dart';

class ViewAppointment extends StatefulWidget {
  final UserDataEntity? userData;

  const ViewAppointment({super.key, required this.userData});

  @override
  _ViewAppointmentState createState() => _ViewAppointmentState();
}

class _ViewAppointmentState extends State<ViewAppointment> {
  List<Map<String, dynamic>> dataList = [];
  Map<String, dynamic> doctorData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHealthRecords();
    _fetchHospitalRecords();
  }

  Future<void> _fetchHospitalRecords() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
        'https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/Hospital/search'); // Replace with actual API endpoint

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
        setState(() {
          doctorData = {for (var item in records) item["osid"]: item};
          _isLoading = false;
        });
      } else {
        print('Failed to load hospital records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hospital records: $e');
    }
  }

  Future<void> _fetchHealthRecords() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse(
        'https://32f5-203-201-231-35.ngrok-free.app/registry/api/v1/Appointment/search'); // Replace with actual API endpoint

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'offset': 0,
          'limit': 500,
          'filters': {
            "mobile": {"eq": widget.userData?.phoneNumber}
          },
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> records = responseData['data'] ?? [];
        setState(() {
          dataList = records
              .map((record) => {
            'name': record['patientName'] ?? 'N/A',
            'appointmentDate': record['appointmentDate'] ?? 'N/A',
            'link': record['link'] ?? '#',
            'doctorOsid': record['doctorOsid'] ?? '#',
            'status': record['status'] ?? 'pending', // Add status field here
          })
              .toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load health records: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching health records: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : AppBackgroundDecoration(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                CommonTopHeader(
                  title: 'Appointments',
                  isTitleOnly: false,
                  dividerColor: AppColors.checkBoxDisableColor,
                  onBackButtonPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: dataList.isEmpty
                      ? Center(child: Text('No appointments available'))
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.medium,
                      vertical: AppDimensions.large,
                    ),
                    itemCount: dataList.length,
                    itemBuilder: (BuildContext context, int index) {
                      var record = dataList[index];
                      var doctor = doctorData[record["doctorOsid"]];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  doctor == null
                                      ? Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey,
                                    child: Icon(Icons.person),
                                  )
                                      : Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                      BorderRadius.circular(5),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            doctor['doctorPhoto'] ??
                                                ''),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          doctor != null
                                              ? doctor['doctorName'] ?? 'N/A'
                                              : 'N/A',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          doctor != null
                                              ? doctor['doctorSpecialization'] ??
                                              'Specialization'
                                              : 'Specialization',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey),
                                        ),
                                        SizedBox(height: 5),
                                        Divider(
                                          thickness: 1,
                                          color: Color(0xFF1581BF),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          doctor != null
                                              ? doctor['hospitalName'] ??
                                              'Hospital Name'
                                              : 'Hospital Name',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Appointment Time: " +
                                              record['appointmentDate'] ??
                                              'N/A',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Show Completed Message or Button Based on Status
                              if (record['status'] == 'completed')
                                Center( // Center the "Completed" message
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (isFutureAppointment(
                                          record)) {
                                        return null;
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                WebViewPage(
                                                    url: record[
                                                    'link']!),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                          color: isFutureAppointment(
                                              record)
                                              ? Colors.red
                                              : Color(0xFF1581BF)),
                                      padding: EdgeInsets.all(12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            6),
                                      ),
                                    ),
                                    child: Text(
                                      isFutureAppointment(record)
                                          ? 'Upcoming Appointment'
                                          : 'Join Appointment',
                                      style: TextStyle(
                                        color:
                                        isFutureAppointment(
                                            record)
                                            ? Colors.red
                                            : Color(0xFF1581BF),
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
          ],
        ),
      ),
    );
  }

  // bool isFutureAppointment(Map<String, dynamic> record) =>
  //     DateTime.parse(record["appointmentDate"]).isAfter(DateTime.now());

  bool isFutureAppointment(Map<String, dynamic> record) {
    try {
      // Extract appointmentDate and preprocess if needed
      String dateStr = record["appointmentDate"] ?? '';
      // Remove "Am" or "Pm" if present and default to midnight time
      if (dateStr.contains("Am") || dateStr.contains("Pm")) {
        dateStr = dateStr.split(' ')[0]; // Extract the date part only
        dateStr += "T00:00:00"; // Append midnight time for parsing
      }
      DateTime appointmentDate = DateTime.parse(dateStr);
      return appointmentDate.isAfter(DateTime.now());
    } catch (e) {
      print("Error parsing appointment date: $e");
      return false;
    }
  }

}

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print("Loading: $url");
          },
          onPageFinished: (String url) {
            print("Finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            print("Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebView'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
