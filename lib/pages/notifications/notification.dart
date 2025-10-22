import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final notifications = [
    {
      "icon": Icons.done,
      "color": const Color(0xFF3EB290),
      "title": "Loan application approved!",
      "description": "Your car loan application has been successfully approved",
      "date": "Aug 20,2022",
      "time": "09:36 AM"
    },
    {
      "icon": CupertinoIcons.exclamationmark_triangle,
      "color": const Color(0xFFEECC55),
      "title": "Loan EMI period expires!",
      "description":
          "Lorem ipsum dolor sit amet consectetur. Doxpo sueretellus za volutpat aliquam vestibulum.",
      "date": "Aug 20,2022",
      "time": "08:36 AM"
    },
    {
      "icon": Icons.close,
      "color": const Color(0xFFFF5887),
      "title": "Loan application was rejected!",
      "description":
          "Lorem ipsum dolor sit amet consectetur. Doxpo sueretellus za volutpat aliquam vestibulum.",
      "date": "Aug 20,2022",
      "time": "09:36 AM"
    },
    {
      "icon": Icons.done,
      "color": const Color(0xFF3EB290),
      "title": "Loan application approved!",
      "description": "Your car loan application has been successfully approved",
      "date": "Aug 20,2022",
      "time": "09:36 AM"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        shadowColor: blackColor.withValues(alpha: 0.4),
        backgroundColor: scaffoldBgColor,
        foregroundColor: black33Color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text(
          getTranslation(context, 'notification.notification'),
          style: appBarStyle,
        ),
      ),
      body: notifications.isEmpty
          ? emptyNotificationContent()
          : notificationList(),
    );
  }

  emptyNotificationContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.bell_slash,
            size: 45,
            color: grey87Color,
          ),
          heightSpace,
          Text(
            getTranslation(context, 'notification.no_new_notification'),
            style: bold16Grey87,
          )
        ],
      ),
    );
  }

  notificationList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: fixPadding),
      physics: const BouncingScrollPhysics(),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              notifications.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: blackColor,
                content: Text(
                  getTranslation(context, 'notification.removed_notification'),
                  style: snackBarStyle,
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(milliseconds: 1500),
              ),
            );
          },
          background: Container(
            color: redColor,
            margin: const EdgeInsets.symmetric(vertical: fixPadding),
          ),
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(fixPadding * 1.5),
            margin: const EdgeInsets.symmetric(
                vertical: fixPadding, horizontal: fixPadding * 2),
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: blackColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 22,
                      width: 22,
                      decoration: BoxDecoration(
                        color: notifications[index]['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        notifications[index]['icon'] as IconData? ?? Icons.notifications,
                        color: whiteColor,
                        size: 14,
                      ),
                    ),
                    widthSpace,
                    Expanded(
                      child: Text(
                        notifications[index]['title'].toString(),
                        style: bold16Black33,
                      ),
                    )
                  ],
                ),
                heightSpace,
                Text(
                  notifications[index]['description'].toString(),
                  style: regular15Black33,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(
                  thickness: 1.5,
                  color: Color(0xFFD4D4D4),
                ),
                Text.rich(
                  TextSpan(
                    text: notifications[index]['date'].toString(),
                    style: semibold12Grey87,
                    children: [
                      const TextSpan(text: " "),
                      TextSpan(
                        text: getTranslation(context, 'notification.at'),
                        style: semibold12Grey87,
                      ),
                      const TextSpan(text: " "),
                      TextSpan(
                        text: notifications[index]['time'].toString(),
                        style: semibold12Grey87,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
