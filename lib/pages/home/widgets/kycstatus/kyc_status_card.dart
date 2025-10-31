import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/pages/home/widgets/kycstatus/kyc_service.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/material.dart';

class KYCStatusCard extends StatelessWidget {
  final bool isLoadingKYC;
  final VoidCallback onRefresh;

  const KYCStatusCard({
    Key? key,
    required this.isLoadingKYC,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: fixPadding * 2),
      child: Container(
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryColor, primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.verified_user,
                  color: whiteColor,
                  size: 24,
                ),
                widthSpace,
                const Text(
                  'KYC Status',
                  style: bold18White,
                ),
                const Spacer(),
                if (isLoadingKYC)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      color: whiteColor,
                      strokeWidth: 2,
                    ),
                  )
                else
                  IconButton(
                    onPressed: onRefresh,
                    icon: const Icon(
                      Icons.refresh,
                      color: whiteColor,
                      size: 20,
                    ),
                  ),
              ],
            ),
            heightSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${KYCService.getKYCStatus()}',
                  style: semibold16White,
                ),
                Text(
                  '${KYCService.getKYCCompletionPercentage().toStringAsFixed(0)}% Complete',
                  style: bold16White,
                ),
              ],
            ),
            heightSpace,
            LinearProgressIndicator(
              value: KYCService.getKYCCompletionPercentage() / 100,
              backgroundColor: whiteColor.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(whiteColor),
            ),
            heightSpace,
            if (KYCService.getKYCCompletionPercentage() < 100)
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: fixPadding,
                    vertical: fixPadding / 2,
                  ),
                  decoration: BoxDecoration(
                    color: whiteColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Complete KYC',
                    style: bold14Primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}