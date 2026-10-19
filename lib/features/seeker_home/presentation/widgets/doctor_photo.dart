import 'package:flutter/material.dart';

class DoctorPhoto extends StatelessWidget {
  const DoctorPhoto({
    super.key,
    this.doctorId,
    this.imageUrl,
  });

  final String? doctorId;
  final String? imageUrl;

  static const _malePortrait = 'assets/images/doctor_placeholder_2.jpg';
  static const _placeholderAssetsByDoctorId = {
    '1-63b60472-5667-44e2-92d0-00e417ae956d':
        'assets/images/doctor_placeholder_1.jpg',
    '1-04f93c2b-9eec-48a0-a54a-b9cf0f7c1b21': _malePortrait,
    '1-45839b1e-e5d1-4d73-abb5-e039aa84e871':
        'assets/images/doctor_placeholder_3.jpg',
    '1-aba7673a-411d-4e47-bda5-a1fcfae2cc5f': _malePortrait,
    '1-3de2b7a7-a957-4b3c-8f81-7540a27eace0': _malePortrait,
    '1-b733d325-ebb1-4e7b-b7ad-41e5757a1cd6': _malePortrait,
  };

  @override
  Widget build(BuildContext context) {
    final placeholderAsset = _placeholderAssetsByDoctorId[doctorId];
    final placeholder = placeholderAsset == null
        ? const ColoredBox(
            color: Color(0xFFE8F0F4),
            child: Icon(Icons.person_outline, size: 36, color: Colors.blueGrey),
          )
        : Image.asset(
            placeholderAsset,
            width: 70,
            height: 70,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            excludeFromSemantics: true,
          );
    final url = imageUrl?.trim() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: 70,
        height: 70,
        child: url.isEmpty
            ? placeholder
            : Image.network(
                url,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) =>
                    frame == null ? placeholder : child,
                errorBuilder: (context, error, stackTrace) => placeholder,
              ),
      ),
    );
  }
}
