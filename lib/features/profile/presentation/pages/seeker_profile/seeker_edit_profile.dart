import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/extensions/padding.dart';
import '../../../../../utils/extensions/string_to_string.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../../utils/widgets/app_background_widget.dart';
import '../../../../../utils/widgets/build_button.dart';
import '../../../../../utils/widgets/custom_text_form_fields.dart';
import '../../../../multi_lang/domain/mappers/profile/profile_keys.dart';
import '../../../../on_boarding/domain/entities/user_data_entity.dart';
import '../../widgets/phone_number_widget.dart';
import '../../widgets/profile_display_values.dart';

/// A screen widget to edit user profile details.
class SeekerEditProfile extends StatefulWidget {
  /// The user data entity containing profile details.
  final UserDataEntity? userData;

  /// Constructor for SeekerEditProfile.
  const SeekerEditProfile({super.key, required this.userData});

  @override
  State<SeekerEditProfile> createState() => _SeekerEditProfileState();
}

class _SeekerEditProfileState extends State<SeekerEditProfile> {
  /// Controllers for managing the text input fields.
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController genderController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize the text controllers with user data.
    nameController.text = profileDisplayName(widget.userData);
    emailController.text = profileDisplayEmail(widget.userData);
    addressController.text = _formatAddress(widget.userData?.kyc?.address);
    dobController.text = _profileText(widget.userData?.kyc?.dob);
    mobileNumberController.text = _profileText(widget.userData?.phoneNumber);

    // Set gender based on the user data.
    final genderCode = _profileText(widget.userData?.kyc?.gender).toUpperCase();
    String gender = genderCode == 'M' || genderCode == 'MALE'
        ? ProfileKeys.male.stringToString
        : genderCode == 'F' || genderCode == 'FEMALE'
            ? ProfileKeys.female.stringToString
            : '';
    genderController.text = gender;
  }

  String _profileText(String? value) {
    final text = value?.trim() ?? '';
    return text.toLowerCase() == 'null' || text.toUpperCase() == 'NA'
        ? ''
        : text;
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources.
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    addressController.dispose();
    mobileNumberController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackgroundDecoration(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: Column(
              children: [
                CommonTopHeader(
                  title: ProfileKeys.editProfile.stringToString,
                  isTitleOnly: false,
                  dividerColor: AppColors.checkBoxDisableColor,
                  onBackButtonPressed: () => Navigator.of(context).pop(),
                ),
                _buildProfileBody(),
                ButtonWidget(
                  onPressed: () {},
                  title: ProfileKeys.saveChanges.stringToString,
                  isValid: false,
                ).symmetricPadding(horizontal: AppDimensions.medium),
              ],
            )),
          ],
        ),
      ),
    );
  }

  /// Builds the profile details form.
  Widget _buildProfileBody() {
    return Column(children: [
      // Name input field, read-only.
      CustomTextFormField(
        controller: nameController,
        label: ProfileKeys.name.stringToString,
        readOnly: true,
      ),
      AppDimensions.small.verticalSpace, // Add vertical space.

      // Conditionally display email input field.
        emailController.text.isNotEmpty
          ? CustomTextFormField(
              controller: emailController,
              label: ProfileKeys.email.stringToString,
              readOnly: true,
            )
          : Container(),

      // Conditionally display gender input field.
      widget.userData?.kyc?.gender != 'NA'
          ? CustomTextFormField(
              controller: genderController,
              label: ProfileKeys.gender.stringToString,
              readOnly: true,
            )
          : Container(),
      AppDimensions.small.verticalSpace, // Add vertical space.

      // Phone number input field with country code.
      PhoneNumberWidget(
        countryCode: widget.userData?.countryCode ?? '',
        phoneNumber: widget.userData?.phoneNumber ?? '',
      ),
      AppDimensions.small.verticalSpace, // Add vertical space.

      // Conditionally display date of birth input field.
      widget.userData?.kyc?.dob != ''
          ? CustomTextFormField(
              controller: dobController,
              label: ProfileKeys.dateOfBirth.stringToString,
              readOnly: true,
            )
          : Container(),

      // Address input field, read-only.
      CustomTextFormField(
        controller: addressController,
        label: ProfileKeys.addressString.stringToString,
        readOnly: true,
      ),
    ]).paddingAll(padding: AppDimensions.medium); // Add padding to the form.
  }

  /// Formats the address from a JSON string to a human-readable format.
  String _formatAddress(String? address) {
    final text = _profileText(address);
    if (text.isEmpty || text == '""') {
      return "";
    }

    dynamic decoded;
    try {
      decoded = json.decode(text);
    } on FormatException {
      return text;
    }
    if (decoded is String) return _profileText(decoded);
    if (decoded is! Map<String, dynamic>) return '';
    final addressMap = decoded;

    // Create a list of non-null address components.
    List addressComponents = [
      addressMap['careOf'] ?? "",
      addressMap['houseNumber'] ?? "",
      addressMap['street'] ?? "",
      addressMap['locality'] ?? "",
      addressMap['district'] ?? "",
      addressMap['state'] ?? "",
      addressMap['pincode'] ?? "",
      addressMap['postOffice'] ?? "",
    ].map((component) => _profileText(component.toString()))
      .where((component) => component.isNotEmpty).toList();

    // Join the components with commas.
    final addressString = addressComponents.join(', ');
    return addressString;
  }
}
