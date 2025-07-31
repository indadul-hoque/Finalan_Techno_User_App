import 'package:fl_banking_app/localization/localization_const.dart';
import 'package:fl_banking_app/theme/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    nameController.text = "Leslie Alexander";
    emailController.text = "lesliealexander@example .com";
    phoneController.text = "+91 1234567890";
    super.initState();
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
      body: ListView(
        padding: const EdgeInsets.all(fixPadding * 2),
        physics: const BouncingScrollPhysics(),
        children: [
          userProfileImage(size),
          heightSpace,
          heightSpace,
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
          heightSpace,
          heightSpace,
          heightSpace,
          updateButton(context),
        ],
      ),
    );
  }

  updateButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.all(fixPadding * 1.5),
        decoration: BoxDecoration(
          color: primaryColor,
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
        child: Text(
          getTranslation(context, 'edit_profile.update'),
          style: bold18White,
        ),
      ),
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
              )
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
