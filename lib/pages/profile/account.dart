import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/home/widgets/kycstatus/kyc_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool isLoading = false;
  Map<String, dynamic>? kycData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final phoneNumber = prefs.getString('phoneNumber') ?? '9519874704';
    setState(() => isLoading = true);

    final data = await KYCService.fetchKYCDetails(phoneNumber);

    setState(() {
      kycData = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Account', style: bold20White),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/deposite/bg.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : _buildProfileView(size),
    );
  }

  Widget _buildProfileView(Size size) {
    if (kycData == null) return const Center(child: Text('No data found'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(fixPadding * 2),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userInfo(size),
          const SizedBox(height: 20),
          _buildSection('Personal Information', [
            _infoTile('Name', kycData!['name']),
            _infoTile('Phone', kycData!['phone']),
            _infoTile('Email', kycData!['selectedUserEmail']),
            _infoTile('Address', kycData!['address']),
          ]),
          const SizedBox(height: 20),
          _buildSection('KYC Details', [
            _infoTile('Aadhar', kycData!['aadhar']),
            _infoTile('PAN', kycData!['pan']),
            _infoTile('Voter ID', kycData!['voter']),
          ]),
          const SizedBox(height: 20),
          _buildSection('Nominee Details', [
            _infoTile('Nominee Name', kycData!['nominee']?['name']),
            _infoTile('Relation', kycData!['nominee']?['relation']),
            _infoTile('Nominee Aadhar', kycData!['nominee']?['aadhar']),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> fields) {
    return Container(
      padding: const EdgeInsets.all(fixPadding * 1.5),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: blackColor.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: bold18Black33),
          const SizedBox(height: 10),
          ...fields,
        ],
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: semibold15Grey94),
          Text(value ?? 'N/A', style: semibold15Black33),
        ],
      ),
    );
  }

  Widget userInfo(Size size) => Container(
        margin: const EdgeInsets.symmetric(
            horizontal: fixPadding * 1, vertical: fixPadding),
        padding: const EdgeInsets.all(fixPadding * 2),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: blackColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Profile Image
            Container(
              height: size.height * 0.1,
              width: size.height * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border:
                    Border.all(color: primaryColor.withOpacity(0.2), width: 3),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 6,
                    color: primaryColor.withOpacity(0.15),
                    offset: const Offset(0, 3),
                  )
                ],
                image: const DecorationImage(
                  image: AssetImage("assets/profile/profileImage.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            widthSpace,
            // Name & Phone Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kycData?['name'] ?? 'User Name',
                    style: bold22Black.copyWith(
                      color: black33Color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  height5Space,
                  Text(
                    kycData?['phone'] ?? '+91 1234567890',
                    style: semibold16Grey94,
                  ),
                  height5Space,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Verified Account',
                      style:
                          bold14Primary.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            // Verified icon or status
            Icon(
              Icons.verified,
              color: primaryColor,
              size: 26,
            ),
          ],
        ),
      );
}
