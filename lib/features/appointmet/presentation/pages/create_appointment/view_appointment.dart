import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:xplor/core/api_constants.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../../utils/widgets/app_background_widget.dart';
import '../../../../on_boarding/domain/entities/user_data_entity.dart';
import '../../../../seeker_home/presentation/widgets/doctor_photo.dart';
import 'package:intl/intl.dart';

class ViewAppointment extends StatefulWidget {
  //final UserDataEntity? userData;
  //const ViewAppointment({super.key, required this.userData});

  final String? phoneNumber;
  const ViewAppointment({super.key, required this.phoneNumber});

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
        '$domain/registry/api/v1/Hospital/search'); // Replace with actual API endpoint

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
        print("ok..............");
        print(records);
        print("ok..............");
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
        '$domain/registry/api/v1/Appointment/search'); // Replace with actual API endpoint

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
            "mobile": {
              "eq": widget.phoneNumber
            } //widget.userData?.phoneNumber  ---> "+917760613505"
          },
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> records = responseData['data'] ?? [];
        print(records);
        setState(() {
          dataList = records
              .map((record) => {
                    'name': record['patientName'] ?? 'N/A',
                    'appointmentDate': record['appointmentDate'] ?? 'N/A',
                    'link': record['link'] ?? '#',
                    'doctorOsid': record['doctorOsid'] ?? '#',
                    'status':
                        record['status'] ?? 'pending', // Add status field here
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
                                              DoctorPhoto(
                                                imageUrl:
                                                    doctor?['doctorPhoto'],
                                                doctorId: record['doctorOsid'],
                                              ),
                                              SizedBox(width: 16),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      doctor != null
                                                          ? doctor[
                                                                  'doctorName'] ??
                                                              'N/A'
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
                                                          ? doctor[
                                                                  'doctorSpecialization'] ??
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
                                                          ? 'Beneficiary: ${record["name"] ?? 'patientName'}' // Display "PatientName: record['name']" or "patientName" if null
                                                          : 'PatientName: patientName', // Default when doctor is null
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),

                                                    // Text(
                                                    //   doctor != null
                                                    //       ?  record["name"]??
                                                    //       'patientName '
                                                    //       : ' patientName',
                                                    //   style: TextStyle(fontSize: 14),
                                                    // ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      doctor != null
                                                          ? doctor[
                                                                  'hospitalName'] ??
                                                              'Hospital Name'
                                                          : 'Hospital Name',
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    SizedBox(height: 5),
                                                    // Text(
                                                    //   "Appointment Time: " +
                                                    //       record['appointmentDate'] ??
                                                    //       'N/A',
                                                    //   style: TextStyle(fontSize: 14),
                                                    // ),
                                                    Text(
                                                      "Appointment Time: ${record['appointmentDate'].toString().replaceAll('â¯', ' ').trim()}",
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          // Show Completed Message or Button Based on Status
                                          if (record['status'] == 'completed')
                                            Center(
                                              // Center the "Completed" message
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
                                                      color:
                                                          isFutureAppointment(
                                                                  record)
                                                              ? Colors.red
                                                              : Color(
                                                                  0xFF1581BF)),
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
                                                    color: isFutureAppointment(
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

bool isTrustedConsultationUrl(String? url) {
  final uri = Uri.tryParse(url ?? '');
  return uri != null &&
      uri.scheme == 'https' &&
      uri.host == '8x8.vc' &&
      uri.port == 443 &&
      uri.userInfo.isEmpty;
}

class WebViewPage extends StatefulWidget {
  final String url;

  WebViewPage({required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  Future<void> _permissionQueue = Future<void>.value();
  String? _loadError;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController(
      onPermissionRequest: (request) {
        _permissionQueue = _permissionQueue.then(
          (_) => _handleMediaPermission(request),
        );
      },
    )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            return request.isMainFrame && !isTrustedConsultationUrl(request.url)
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() {
                _loadError =
                    'Unable to load the consultation. Please try again.';
              });
            }
          },
        ),
      );
    _loadConsultation();
  }

  Future<void> _loadConsultation() async {
    if (!isTrustedConsultationUrl(widget.url)) {
      setState(() => _loadError = 'This consultation link is not supported.');
      return;
    }
    setState(() => _loadError = null);
    try {
      final platformController = _controller.platform;
      if (platformController is AndroidWebViewController) {
        await platformController.setMediaPlaybackRequiresUserGesture(false);
      }
      if (!mounted) return;
      await _controller.loadRequest(Uri.parse(widget.url));
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadError = 'Unable to load the consultation. Please try again.';
        });
      }
    }
  }

  Future<void> _handleMediaPermission(WebViewPermissionRequest request) async {
    try {
      final pageUrl = await _controller.currentUrl();
      if (!mounted ||
          !isTrustedConsultationUrl(pageUrl) ||
          request.types.isEmpty ||
          request.types.any((type) =>
              type != WebViewPermissionResourceType.camera &&
              type != WebViewPermissionResourceType.microphone)) {
        await request.deny();
        return;
      }

      final permissions = [
        if (request.types.contains(WebViewPermissionResourceType.camera))
          Permission.camera,
        if (request.types.contains(WebViewPermissionResourceType.microphone))
          Permission.microphone,
      ];
      final statuses = await permissions.request();
      if (!mounted || await _controller.currentUrl() != pageUrl) {
        await request.deny();
        return;
      }
      if (permissions
          .every((permission) => statuses[permission]?.isGranted == true)) {
        await request.grant();
      } else {
        await request.deny();
        _showPermissionError();
      }
    } catch (_) {
      try {
        await request.deny();
      } catch (_) {}
      _showPermissionError();
    }
  }

  void _showPermissionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Camera or microphone access was denied.'),
      action: SnackBarAction(
        label: 'Settings',
        onPressed: () => openAppSettings(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation'),
      ),
      body: _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!, textAlign: TextAlign.center),
                  if (isTrustedConsultationUrl(widget.url))
                    TextButton(
                      onPressed: _loadConsultation,
                      child: const Text('Retry'),
                    ),
                ],
              ),
            )
          : WebViewWidget.fromPlatformCreationParams(
              params: WebViewPlatform.instance is AndroidWebViewPlatform
                  ? AndroidWebViewWidgetCreationParams(
                      controller: _controller.platform,
                      displayWithHybridComposition: true,
                    )
                  : PlatformWebViewWidgetCreationParams(
                      controller: _controller.platform,
                    ),
            ),
    );
  }
}
