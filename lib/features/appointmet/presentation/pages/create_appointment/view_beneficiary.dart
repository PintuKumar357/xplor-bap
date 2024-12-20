import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/features/appointmet/presentation/pages/create_appointment/add_beneficiary.dart';

import '../../../../../utils/common_top_header.dart';
import '../../../domain/entities/CreateAppointmentArgs.dart';

class Beneficiary {
  final String name;
  final String relationship;
  final int age;
  final String _abhaId;

  Beneficiary({
    required this.name,
    required this.relationship,
    required this.age,
    required String abhaId,
  }) : _abhaId = abhaId;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'age': age,
      'abhaId': _abhaId,
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

class ViewBeneficiaryPage extends StatefulWidget {


   const ViewBeneficiaryPage({Key? key}) : super(key: key);

  @override
  _ViewBeneficiaryPageState createState() => _ViewBeneficiaryPageState();
}

class _ViewBeneficiaryPageState extends State<ViewBeneficiaryPage> {
  List<Beneficiary> _beneficiaries = [];

  @override
  void initState() {
    super.initState();
    _loadBeneficiaries();
  }

  Future<void> _loadBeneficiaries() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');

    if (beneficiariesJson != null) {
      setState(() {
        _beneficiaries = beneficiariesJson
            .map((jsonStr) => Beneficiary.fromJson(jsonStr))
            .toList();
      });
    }
  }

  Future<void> _deleteBeneficiary(int index) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');

    if (beneficiariesJson != null && index >= 0 && index < beneficiariesJson.length) {
      beneficiariesJson.removeAt(index);
      prefs.setStringList('beneficiaries', beneficiariesJson);

      setState(() {
        _beneficiaries.removeAt(index);
      });
    }
  }

  void _showEditPopup(int index) {
    final beneficiary = _beneficiaries[index];
    TextEditingController nameController = TextEditingController(text: beneficiary.name);
    TextEditingController relationshipController = TextEditingController(text: beneficiary.relationship);
    TextEditingController ageController = TextEditingController(text: beneficiary.age.toString());
    TextEditingController abhaIdController = TextEditingController(text: beneficiary._abhaId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Beneficiary'),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(labelText: 'Relationship'),
            ),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: abhaIdController,
              decoration: const InputDecoration(labelText: 'ABHA ID'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF1581BF),
            ),
          ),
          TextButton(
            onPressed: () {
              _updateBeneficiary(index, Beneficiary(
                name: nameController.text,
                relationship: relationshipController.text,
                age: int.tryParse(ageController.text) ?? 0,
                abhaId: abhaIdController.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFF1581BF),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBeneficiary(int index, Beneficiary updatedBeneficiary) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? beneficiariesJson = prefs.getStringList('beneficiaries');

    if (beneficiariesJson != null && index >= 0 && index < beneficiariesJson.length) {
      beneficiariesJson[index] = updatedBeneficiary.toJson();
      prefs.setStringList('beneficiaries', beneficiariesJson);

      setState(() {
        _beneficiaries[index] = updatedBeneficiary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: CommonTopHeader(
          title: 'View Beneficiaries',
          isTitleOnly: false,
          dividerColor: Colors.grey,
          onBackButtonPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _beneficiaries.isEmpty
            ? Center(child: const Text('No beneficiaries added yet.'))
            : ListView.builder(
          itemCount: _beneficiaries.length,
          itemBuilder: (context, index) {
            final beneficiary = _beneficiaries[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      '${beneficiary.name}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Relationship: ${beneficiary.relationship}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                        Text(
                          'Age: ${beneficiary.age}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                        Text(
                          'ABHA ID: ${beneficiary._abhaId}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Color(0xFF1581BF),
                          onPressed: () => _showEditPopup(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Color(0xFF1581BF),
                          onPressed: () => _deleteBeneficiary(index),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to Add Beneficiary page and reload the list after returning
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddBeneficiaryPage(),
            ),
          );

          // Reload the beneficiaries list when returning from AddBeneficiaryPage
          _loadBeneficiaries();
        },
        backgroundColor: Color(0xFF1581BF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

