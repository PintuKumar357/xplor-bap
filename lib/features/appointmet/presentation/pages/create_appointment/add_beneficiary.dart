import 'dart:convert';  // Import for JSON serialization
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../profile/presentation/pages/seeker_profile/seeker_profile_page_view.dart';

class AbhaIdInputFormatter extends TextInputFormatter {
  const AbhaIdInputFormatter({this.onInvalidInput});

  final ValueChanged<bool>? onInvalidInput;

  static final _lengthLimit = LengthLimitingTextInputFormatter(
    14,
    maxLengthEnforcement: MaxLengthEnforcement.enforced,
  );

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    onInvalidInput?.call(RegExp(r'[^0-9-]').hasMatch(newValue.text));
    final digitsOnly = FilteringTextInputFormatter.digitsOnly;
    final oldDigits =
        digitsOnly.formatEditUpdate(TextEditingValue.empty, oldValue);
    final newDigits = digitsOnly.formatEditUpdate(oldDigits, newValue);
    final limited = _lengthLimit.formatEditUpdate(oldDigits, newDigits);
    final formatted = StringBuffer();
    for (var index = 0; index < limited.text.length; index++) {
      if (index == 2 || index == 6 || index == 10) formatted.write('-');
      formatted.write(limited.text[index]);
    }

    int formattedOffset(int offset) {
      if (offset < 0) return formatted.length;
      return offset +
          (offset > 2 ? 1 : 0) +
          (offset > 6 ? 1 : 0) +
          (offset > 10 ? 1 : 0);
    }

    return limited.copyWith(
      text: formatted.toString(),
      selection: limited.selection.copyWith(
        baseOffset: formattedOffset(limited.selection.baseOffset),
        extentOffset: formattedOffset(limited.selection.extentOffset),
      ),
      composing: TextRange.empty,
    );
  }
}

// Beneficiary model to hold the data
class Beneficiary {
  final String name;
  final String relationship;
  final int age;
  final String abhaId;  // New field for ABHA ID

  Beneficiary({
    required this.name,
    required this.relationship,
    required this.age,
    required this.abhaId,  // Add ABHA ID to constructor
  });

  // Convert the Beneficiary to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'age': age,
      'abhaId': abhaId,  // Include ABHA ID
    };
  }

  // Convert a map to Beneficiary
  factory Beneficiary.fromMap(Map<String, dynamic> map) {
    return Beneficiary(
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      age: map['age'] ?? 0,
      abhaId: map['abhaId'] ?? '',  // Handle ABHA ID
    );
  }

  // Convert Beneficiary to JSON string
  String toJson() {
    return json.encode(toMap());
  }

  // Convert JSON string back to Beneficiary
  factory Beneficiary.fromJson(String jsonStr) {
    return Beneficiary.fromMap(json.decode(jsonStr));
  }
}

class AddBeneficiaryPage extends StatefulWidget {
  const AddBeneficiaryPage({super.key});

  @override
  _AddBeneficiaryPageState createState() => _AddBeneficiaryPageState();
}

class _AddBeneficiaryPageState extends State<AddBeneficiaryPage> {
  final _formKey = GlobalKey<FormState>(); // Form validation key
  String _name = '';
  String _relationship = ''; // This will hold the selected relationship
  int _age = 0;
  String _abhaId = '';  // New field for ABHA ID
  bool _hasInvalidAbhaInput = false;

  // List of relationships for the dropdown
  List<String> _relationshipOptions = [
    'Spouse', 'Parent', 'Child', 'Sibling', 'Other'
  ];

  // Save Beneficiary data to local storage
  Future<void> _saveBeneficiaryData(Beneficiary beneficiary) async {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve existing beneficiaries list from SharedPreferences
    List<String> beneficiariesList = prefs.getStringList('beneficiaries') ?? [];

    // Add new beneficiary to the list (serialized to JSON string)
    beneficiariesList.add(beneficiary.toJson());

    // Save the updated list back to SharedPreferences
    await prefs.setStringList('beneficiaries', beneficiariesList);
  }

  // Method to handle form submission
  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // If the form is valid, create a Beneficiary object
      Beneficiary newBeneficiary = Beneficiary(
        name: _name,
        relationship: _relationship,
        age: _age,
        abhaId: _abhaId,  // Pass the ABHA ID to the Beneficiary object
      );

      // Save beneficiary data to local storage (await the async method)
      await _saveBeneficiaryData(newBeneficiary);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Beneficiary added successfully!"),
          duration: Duration(seconds: 1), // Set duration to 1 second
        ),
      );

      // Clear the fields
      _formKey.currentState?.reset();

      // Navigate back
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // Adjust height as needed
        child: CommonTopHeader(
          title: 'Add Beneficiary',
          isTitleOnly: false,
          dividerColor: Colors.grey, // Use appropriate color
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name input field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Beneficiary Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Relationship dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                value: _relationship.isEmpty ? null : _relationship,
                onChanged: (newValue) {
                  setState(() {
                    _relationship = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a relationship';
                  }
                  return null;
                },
                items: _relationshipOptions.map((String relationship) {
                  return DropdownMenuItem<String>(
                    value: relationship,
                    child: Text(relationship),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),

              // Age input field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _age = int.tryParse(value) ?? 0;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number for age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // ABHA ID input field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'ABHA ID',
                  hintText: 'XX-XXXX-XXXX-XXXX',
                  helperText: _hasInvalidAbhaInput
                      ? 'Only digits are allowed; hyphens are added automatically.'
                      : null,
                  helperMaxLines: 3,
                  helperStyle: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  errorMaxLines: 2,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [
                  AbhaIdInputFormatter(onInvalidInput: (hasInvalidInput) {
                    if (_hasInvalidAbhaInput != hasInvalidInput) {
                      setState(() => _hasInvalidAbhaInput = hasInvalidInput);
                    }
                  }),
                ],
                onChanged: (value) {
                  _abhaId = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an ABHA ID';
                  }
                  if (!RegExp(r'^[0-9]{2}-[0-9]{4}-[0-9]{4}-[0-9]{4}$')
                      .hasMatch(value)) {
                    return 'Enter a 14-digit ABHA ID (XX-XXXX-XXXX-XXXX)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Submit button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(
                  'Add Beneficiary',
                  style: TextStyle(
                    color: Color(0xFF1581BF), // Text color
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.white, // Background color
                  side: BorderSide(color: Color(0xFF1581BF)), // Border color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
