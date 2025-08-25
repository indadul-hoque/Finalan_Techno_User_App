import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:fl_banking_app/services/kyc_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController voterController = TextEditingController();
  TextEditingController panController = TextEditingController();
  TextEditingController occupationController = TextEditingController();
  TextEditingController incomeController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController guardianController = TextEditingController();
  TextEditingController nomineeNameController = TextEditingController();
  TextEditingController nomineeRelationController = TextEditingController();
  TextEditingController nomineeAadharController = TextEditingController();

  String? selectedGender;
  String? selectedMaritalStatus;
  String? selectedUserId;
  bool isLoading = false;
  bool isKYCLoaded = false;

  final List<String> genderOptions = ['male', 'female', 'other'];
  final List<String> maritalStatusOptions = [
    'unmarried',
    'married',
    'divorced',
    'widowed'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber');

    setState(() {
      selectedUserId = phoneNumber;
    });

    // Load KYC data after user data is loaded
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      _loadKYCData();
    } else {
      // For testing purposes, use the API test phone number
      print('No phone number found in SharedPreferences, using test number');
      setState(() {
        selectedUserId = '9519874704'; // Test phone number from your API
      });
      _loadKYCData();
    }
  }

  Future<void> _loadKYCData() async {
    if (selectedUserId == null) return;

    setState(() {
      isLoading = true;
    });

    print('Loading KYC data for phone: $selectedUserId'); // Debug log

    final kycData = await KYCService.fetchKYCDetails(selectedUserId!);

    if (kycData != null) {
      print('KYC data received: $kycData'); // Debug log

      setState(() {
        nameController.text = kycData['name'] ?? '';
        emailController.text = kycData['selectedUserEmail'] ?? '';
        phoneController.text = kycData['phone'] ?? '';
        addressController.text = kycData['address'] ?? '';
        aadharController.text = kycData['aadhar'] ?? '';
        voterController.text = kycData['voter'] ?? '';
        panController.text = kycData['pan'] ?? '';
        occupationController.text = kycData['occupation'] ?? '';
        incomeController.text = kycData['income'] ?? '';
        educationController.text = kycData['education'] ?? '';
        guardianController.text = kycData['guardian'] ?? '';
        selectedGender = kycData['gender'] ?? '';
        selectedMaritalStatus = kycData['materialStatus'] ?? '';

        // Nominee details
        if (kycData['nominee'] != null) {
          nomineeNameController.text = kycData['nominee']['name'] ?? '';
          nomineeRelationController.text = kycData['nominee']['relation'] ?? '';
          nomineeAadharController.text = kycData['nominee']['aadhar'] ?? '';
        }

        isKYCLoaded = true;
      });

      print('Form fields populated with KYC data'); // Debug log
    } else {
      print('Failed to load KYC data: ${KYCService.errorMessage}'); // Debug log
      KYCService.showToast(KYCService.errorMessage ?? 'Failed to load KYC data',
          isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (selectedUserId == null) {
      KYCService.showToast('User ID not found', isError: true);
      return;
    }

    setState(() {
      isLoading = true;
    });

    final kycData = {
      'name': nameController.text,
      'selectedUserEmail': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'aadhar': aadharController.text,
      'voter': voterController.text,
      'pan': panController.text,
      'occupation': occupationController.text,
      'income': incomeController.text,
      'education': educationController.text,
      'guardian': guardianController.text,
      'gender': selectedGender,
      'materialStatus': selectedMaritalStatus,
      'nominee': {
        'name': nomineeNameController.text,
        'relation': nomineeRelationController.text,
        'aadhar': nomineeAadharController.text,
      }
    };

    final success = await KYCService.updateKYCDetails(selectedUserId!, kycData);

    if (success) {
      KYCService.showToast('Profile updated successfully!');
      Navigator.pop(context);
    } else {
      KYCService.showToast(
          KYCService.errorMessage ?? 'Failed to update profile',
          isError: true);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        shadowColor: blackColor.withValues(alpha: 0.4),
        foregroundColor: black33Color,
        backgroundColor: scaffoldBgColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        titleSpacing: 0.0,
        title: Text(
          getTranslation(context, 'edit_profile.edit_profile'),
          style: appBarStyle,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : ListView(
              padding: const EdgeInsets.all(fixPadding * 2),
              physics: const BouncingScrollPhysics(),
              children: [
                userProfileImage(size),
                heightSpace,
                heightSpace,
                _buildKYCStatusCard(),
                heightSpace,
                heightSpace,
                _buildPersonalInfoSection(),
                heightSpace,
                heightSpace,
                _buildIdentitySection(),
                heightSpace,
                heightSpace,
                _buildFinancialSection(),
                heightSpace,
                heightSpace,
                _buildNomineeSection(),
                heightSpace,
                heightSpace,
                heightSpace,
                heightSpace,
                updateButton(context),
              ],
            ),
    );
  }

  Widget _buildKYCStatusCard() {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: blackColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_user,
                color: primaryColor,
                size: 24,
              ),
              widthSpace,
              Text(
                'KYC Status',
                style: bold18Black33,
              ),
            ],
          ),
          heightSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: ${KYCService.getKYCStatus()}',
                style: semibold15Black33,
              ),
              Text(
                '${KYCService.getKYCCompletionPercentage().toStringAsFixed(0)}% Complete',
                style: bold16Primary,
              ),
            ],
          ),
          heightSpace,
          LinearProgressIndicator(
            value: KYCService.getKYCCompletionPercentage() / 100,
            backgroundColor: greyD9Color,
            valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Information',
          style: bold18Black33,
        ),
        heightSpace,
        nameField(),
        heightSpace,
        heightSpace,
        emialField(),
        heightSpace,
        heightSpace,
        phoneField(),
        heightSpace,
        heightSpace,
        _buildAddressField(),
        heightSpace,
        heightSpace,
        _buildGenderField(),
        heightSpace,
        heightSpace,
        _buildMaritalStatusField(),
        heightSpace,
        heightSpace,
        _buildGuardianField(),
      ],
    );
  }

  Widget _buildIdentitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Identity Documents',
          style: bold18Black33,
        ),
        heightSpace,
        _buildAadharField(),
        heightSpace,
        heightSpace,
        _buildVoterField(),
        heightSpace,
        heightSpace,
        _buildPanField(),
      ],
    );
  }

  Widget _buildFinancialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Financial Information',
          style: bold18Black33,
        ),
        heightSpace,
        _buildOccupationField(),
        heightSpace,
        heightSpace,
        _buildIncomeField(),
        heightSpace,
        heightSpace,
        _buildEducationField(),
      ],
    );
  }

  Widget _buildNomineeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominee Details',
          style: bold18Black33,
        ),
        heightSpace,
        _buildNomineeNameField(),
        heightSpace,
        heightSpace,
        _buildNomineeRelationField(),
        heightSpace,
        heightSpace,
        _buildNomineeAadharField(),
      ],
    );
  }

  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Address',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: addressController,
            keyboardType: TextInputType.streetAddress,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your address',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Select gender',
            ),
            items: genderOptions.map((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender.toUpperCase()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedGender = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMaritalStatusField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marital Status',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: selectedMaritalStatus,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Select marital status',
            ),
            items: maritalStatusOptions.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status.toUpperCase()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedMaritalStatus = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGuardianField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guardian Name',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: guardianController,
            keyboardType: TextInputType.name,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter guardian name',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAadharField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aadhar Number',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: aadharController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Aadhar number',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoterField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Voter ID',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: voterController,
            keyboardType: TextInputType.text,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Voter ID',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAN Number',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: panController,
            keyboardType: TextInputType.text,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter PAN number',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOccupationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Occupation',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: occupationController,
            keyboardType: TextInputType.text,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your occupation',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncomeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Annual Income',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: incomeController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter annual income',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEducationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: educationController,
            keyboardType: TextInputType.text,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter your education level',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNomineeNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominee Name',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: nomineeNameController,
            keyboardType: TextInputType.name,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter nominee name',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNomineeRelationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominee Relation',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: nomineeRelationController,
            keyboardType: TextInputType.text,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter relation with nominee',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNomineeAadharField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nominee Aadhar',
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: nomineeAadharController,
            keyboardType: TextInputType.number,
            cursorColor: primaryColor,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter nominee Aadhar number',
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  // Original field methods
  nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'edit_profile.name'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          width: double.maxFinite,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: nameController,
            keyboardType: TextInputType.name,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: getTranslation(context, 'edit_profile.enter_your_name'),
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  emialField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'edit_profile.email_address'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: whiteColor,
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              )
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  getTranslation(context, 'edit_profile.enter_email_address'),
              hintStyle: semibold15Grey94,
            ),
          ),
        )
      ],
    );
  }

  phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'edit_profile.phone_number'),
          style: bold17Black33,
        ),
        heightSpace,
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: blackColor.withValues(alpha: 0.25),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            style: semibold15Black33,
            controller: phoneController,
            keyboardType: TextInputType.phone,
            cursorColor: primaryColor,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  getTranslation(context, 'edit_profile.enter_phone_number'),
              hintStyle: semibold15Grey94,
            ),
          ),
        ),
      ],
    );
  }

  updateButton(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : _updateProfile,
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: isLoading ? grey94Color : primaryColor,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: whiteColor,
                  strokeWidth: 2,
                ),
              )
            : Text(
                getTranslation(context, 'edit_profile.update'),
                style: bold18White,
              ),
      ),
    );
  }

  userProfileImage(Size size) {
    return Center(
      child: SizedBox(
        height: size.height * 0.14,
        width: size.height * 0.14,
        child: Stack(
          children: [
            Container(
              height: size.height * 0.14,
              width: size.height * 0.14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(
                    "assets/profile/profileImage.png",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) {
                      return Container(
                        width: double.maxFinite,
                        padding: const EdgeInsets.all(fixPadding * 2),
                        decoration: const BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(10.0),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getTranslation(
                                  context, 'edit_profile.upload_image'),
                              style: semibold18Black33,
                            ),
                            heightSpace,
                            heightSpace,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                optionWidget(
                                    size,
                                    getTranslation(
                                        context, 'edit_profile.camera'),
                                    Icons.camera_alt,
                                    const Color(0xFF1E4799)),
                                optionWidget(
                                    size,
                                    getTranslation(
                                        context, 'edit_profile.gallery'),
                                    Icons.photo,
                                    const Color(0xFF1E996D)),
                                optionWidget(
                                    size,
                                    getTranslation(
                                        context, 'edit_profile.remove'),
                                    CupertinoIcons.trash_fill,
                                    const Color(0xFFEF1717)),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: size.height * 0.045,
                  width: size.height * 0.045,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: scaffoldBgColor,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  optionWidget(Size size, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Column(
        children: [
          Container(
            height: size.height * 0.07,
            width: size.height * 0.07,
            decoration: BoxDecoration(
              color: whiteColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.25),
                  blurRadius: 5,
                )
              ],
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          heightSpace,
          Text(
            title,
            style: semibold15Black33,
          )
        ],
      ),
    );
  }
}
