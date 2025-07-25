// ignore_for_file: use_build_context_synchronously

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/pages/NavigatorPages/carinfopage.dart';
import 'package:flutter_driver/pages/NavigatorPages/companyinformation.dart';
import 'package:flutter_driver/pages/login/carinformation.dart';
import 'package:flutter_driver/pages/login/landingpage.dart';
import 'package:flutter_driver/widgets/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../login/uploaddocument.dart';
import '../noInternet/nointernet.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

dynamic proImageFile;

class _EditProfileState extends State<EditProfile> {
  ImagePicker picker = ImagePicker();
  bool _isLoading = false;
  String _error = '';
  bool _pickImage = false;
  String _permission = '';
  bool showToast = false;
  TextEditingController name = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController mobilenum = TextEditingController();
  TextEditingController usergender = TextEditingController();

//get gallery permission
  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

  bool isEdit = false;

  showToastFunc() {
    setState(() {
      showToast = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          showToast = false;
        });
      }
    });
  }

  navigateLogout() {
    if (ownermodule == '1') {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LandingPage()),
            (route) => false);
      });
    } else {
      ischeckownerordriver = 'driver';
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      });
    }
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noPhotos';
      });
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);
      setState(() {
        proImageFile = pickedFile?.path;
        _pickImage = false;
      });
    } else {
      setState(() {
        _permission = 'noCamera';
      });
    }
  }

  @override
  void initState() {
    _error = '';
    proImageFile = null;
    isEdit = false;
    name.text = userDetails['name'].toString();
    // lastname.text = (userDetails['name'].toString().split(' ').length > 1)
    //     ? userDetails['name'].toString().split(' ')[1]
    //     : '';
    mobilenum.text = userDetails['mobile'];
    email.text = userDetails['email'];
    usergender.text = (userDetails['gender'] == null)
        ? languages[choosenLanguage]['text_not_specified']
        : userDetails['gender'];
    setState(() {});
    super.initState();
  }

  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Stack(
        children: [
          GlassMorphism(
            onTap: () {
              if (isEdit) {
                setState(() {
                  isEdit = false;
                });
              } else {
                Navigator.pop(context, true);
              }
            },
            text: (!isEdit)
                ? languages[choosenLanguage]['text_personal_info']
                : languages[choosenLanguage]['text_editprofile'],
            column: Column(
              children: [
                SizedBox(height: media.width * 0.05),
                InkWell(
                  onTap: () {
                    setState(() {
                      _pickImage = true;
                    });
                  },
                  child: Stack(
                    children: [
                      Container(
                        height: media.width * 0.25,
                        width: media.width * 0.25,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: page,
                            image: (proImageFile == null)
                                ? DecorationImage(
                                    image: NetworkImage(
                                      userDetails['profile_picture'],
                                    ),
                                    fit: BoxFit.cover)
                                : DecorationImage(
                                    image: FileImage(File(proImageFile)),
                                    fit: BoxFit.cover)),
                      ),
                      if (isEdit)
                        Positioned(
                            right: media.width * 0.02,
                            bottom: media.width * 0.02,
                            child: Container(
                              height: media.width * 0.05,
                              width: media.width * 0.05,
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff898989)),
                              child: Icon(
                                Icons.edit,
                                color: topBar,
                                size: media.width * 0.04,
                              ),
                            ))
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                ProfileDetails(
                  heading: languages[choosenLanguage]['text_name'],
                  controller: name,
                  // width: media.width * 0.4,
                  readyonly: (isEdit) ? false : true,
                ),
                SizedBox(
                  height: media.height * 0.02,
                ),
                if (isEdit == false)
                  ProfileDetails(
                    heading: languages[choosenLanguage]['text_mob_num'],
                    controller: mobilenum,
                    readyonly: true,
                  ),
                SizedBox(
                  height: media.height * 0.02,
                ),
                ProfileDetails(
                  heading: languages[choosenLanguage]['text_email'],
                  controller: email,
                  readyonly: (isEdit) ? false : true,
                ),
                SizedBox(
                  height: media.height * 0.02,
                ),
                (!isEdit)
                    ? ProfileDetails(
                        heading: languages[choosenLanguage]['text_gender'],
                        controller: usergender,
                        readyonly: (isEdit) ? false : true,
                      )
                    : SizedBox(
                        width: media.width * 0.9,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  languages[choosenLanguage]['text_gender'],
                                  // 'Gender',
                                  style: GoogleFonts.roboto(
                                      fontSize: media.width * fourteen,
                                      color: whiteText,
                                      fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: media.width * 0.025,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      usergender.text = 'male';
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1.2, color: whiteText),
                                        ),
                                        alignment: Alignment.center,
                                        child: (usergender.text == 'male')
                                            ? Container(
                                                height: media.width * 0.03,
                                                width: media.width * 0.03,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: whiteText),
                                              )
                                            : Container(),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.015,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.15,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_male'],
                                          // 'Male',
                                          style: GoogleFonts.roboto(
                                              color: whiteText,
                                              fontSize: media.width * fourteen,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      usergender.text = 'female';
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1.2, color: whiteText),
                                        ),
                                        alignment: Alignment.center,
                                        child: (usergender.text == 'female')
                                            ? Container(
                                                height: media.width * 0.03,
                                                width: media.width * 0.03,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: whiteText),
                                              )
                                            : Container(),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.015,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.15,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_female'],
                                          // 'Female',
                                          style: GoogleFonts.roboto(
                                              color: whiteText,
                                              fontSize: media.width * fourteen,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      usergender.text = 'others';
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              width: 1.2, color: whiteText),
                                        ),
                                        alignment: Alignment.center,
                                        child: (usergender.text == 'others')
                                            ? Container(
                                                height: media.width * 0.03,
                                                width: media.width * 0.03,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: whiteText),
                                              )
                                            : Container(),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.015,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.25,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_others'],
                                          style: GoogleFonts.roboto(
                                              color: whiteText,
                                              fontSize: media.width * fourteen,
                                              fontWeight: FontWeight.w600),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                (userDetails['role'] != 'owner')
                    ? InkWell(
                        onTap: () async {
                          isowner = false;
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const CarInfoPage()));
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: media.width * 0.05),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.6,
                                          child: MyText(
                                            text: languages[choosenLanguage]
                                                    ['text_car_info']
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            size: media.width * sixteen,
                                            fontweight: FontWeight.w500,
                                            color: whiteText,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: media.width * 0.04,
                                          color: whiteText,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                  top: media.width * 0.05,
                                ),
                                child: Container(
                                  color: whiteText,
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: () async {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CompanyInformation()));
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: media.width * 0.05),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.6,
                                          child: MyText(
                                            text: languages[choosenLanguage]
                                                    ['text_company_info']
                                                .toString(),
                                            overflow: TextOverflow.ellipsis,
                                            size: media.width * sixteen,
                                            fontweight: FontWeight.w500,
                                            color: whiteText,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: media.width * 0.04,
                                          color: whiteText,
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                  top: media.width * 0.05,
                                ),
                                child: Container(
                                  color: whiteText,
                                  height: 1,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                InkWell(
                  onTap: () async {
                    var nav = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UploadDocument()));
                    if (nav != null) {
                      if (nav) {
                        setState(() {});
                      }
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: media.width * 0.05),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: media.width * 0.6,
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                              ['text_docs']
                                          .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      size: media.width * sixteen,
                                      fontweight: FontWeight.w500,
                                      color: whiteText,
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: media.width * 0.04,
                                    color: whiteText,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                            top: media.width * 0.05,
                          ),
                          child: Container(
                            color: whiteText,
                            height: 1,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            error: error,
            loading: _isLoading,
            button: (isEdit)
                ? Button(
                    width: media.width * 0.5,
                    onTap: () async {
                      setState(() {
                        _error = '';
                      });
                      String pattern =
                          r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                      var remail = email.text.replaceAll(' ', '');
                      RegExp regex = RegExp(pattern);
                      if (regex.hasMatch(remail)) {
                        setState(() {
                          _isLoading = true;
                        });
                        // ignore: prefer_typing_uninitialized_variables
                        var nav;
                        if (userDetails['email'] == remail) {
                          nav = await updateProfile(
                              '${name.text} ${lastname.text}',
                              remail,
                              usergender.text);
                          if (nav != 'success') {
                            _error = nav.toString();
                          } else {
                            isEdit = false;
                            _isLoading = false;
                            showToastFunc();
                          }
                        } else {
                          var result = await validateEmail(remail);
                          if (result == 'success') {
                            nav = await updateProfile(
                                '${name.text} ${lastname.text}',
                                remail,
                                usergender.text
                                // userDetails['mobile']
                                );
                            if (nav != 'success') {
                              _error = nav.toString();
                            } else {
                              showToastFunc();
                            }
                          } else {
                            setState(() {
                              _isLoading = false;
                              _error = result;
                            });
                          }
                        }
                        setState(() {
                          _isLoading = false;
                        });
                      } else {
                        setState(() {
                          _error = languages[choosenLanguage]
                              ['text_email_validation'];
                        });
                      }
                    },
                    text: languages[choosenLanguage]['text_confirm'])
                : Button(
                    width: media.width * 0.5,
                    onTap: () {
                      setState(() {
                        isEdit = true;
                      });
                    },
                    text: languages[choosenLanguage]['text_edit']),
          ),

          if (showToast == true)
            Positioned(
                bottom: media.width * 0.05,
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                      media.width * 0.05, 0, media.width * 0.05, 0),
                  width: media.width * 0.9,
                  padding: EdgeInsets.all(media.width * 0.03),
                  decoration: BoxDecoration(
                      color: page,
                      boxShadow: [boxshadow],
                      borderRadius: BorderRadius.circular(8)),
                  alignment: Alignment.center,
                  child: MyText(
                    text: 'Profile Updated Successfully',
                    size: media.width * fourteen,
                    color: Colors.green,
                    fontweight: FontWeight.w500,
                  ),
                )),

          (_pickImage == true)
              ? Positioned(
                  bottom: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _pickImage = false;
                      });
                    },
                    child: Container(
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.all(media.width * 0.05),
                            width: media.width * 1,
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25)),
                                border: Border.all(
                                  color: borderLines,
                                  width: 1.2,
                                ),
                                color: page),
                            child: Column(
                              children: [
                                Container(
                                  height: media.width * 0.02,
                                  width: media.width * 0.15,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.01),
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            pickImageFromCamera();
                                          },
                                          child: Container(
                                              height: media.width * 0.171,
                                              width: media.width * 0.171,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Icon(
                                                Icons.camera_alt_outlined,
                                                size: media.width * 0.064,
                                                color: textColor,
                                              )),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.02,
                                        ),
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_camera'],
                                          size: media.width * ten,
                                          color: textColor.withOpacity(0.4),
                                        )
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            pickImageFromGallery();
                                          },
                                          child: Container(
                                              height: media.width * 0.171,
                                              width: media.width * 0.171,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                              child: Icon(
                                                Icons.image_outlined,
                                                size: media.width * 0.064,
                                                color: textColor,
                                              )),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.02,
                                        ),
                                        MyText(
                                          text: languages[choosenLanguage]
                                              ['text_gallery'],
                                          size: media.width * ten,
                                          color: textColor.withOpacity(0.4),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              : Container(),

          //permission denied popup
          (_permission != '')
              ? Positioned(
                  child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: media.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _permission = '';
                                  _pickImage = false;
                                });
                              },
                              child: Container(
                                height: media.width * 0.1,
                                width: media.width * 0.1,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: page),
                                child: Icon(Icons.cancel_outlined,
                                    color: textColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        width: media.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: page,
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2.0,
                                  spreadRadius: 2.0,
                                  color: Colors.black.withOpacity(0.2))
                            ]),
                        child: Column(
                          children: [
                            SizedBox(
                                width: media.width * 0.8,
                                child: MyText(
                                  text: (_permission == 'noPhotos')
                                      ? languages[choosenLanguage]
                                          ['text_open_photos_setting']
                                      : languages[choosenLanguage]
                                          ['text_open_camera_setting'],
                                  size: media.width * sixteen,
                                  fontweight: FontWeight.w600,
                                )),
                            SizedBox(height: media.width * 0.05),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () async {
                                      await openAppSettings();
                                    },
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['text_open_settings'],
                                      size: media.width * sixteen,
                                      fontweight: FontWeight.w600,
                                      color: buttonColor,
                                    )),
                                InkWell(
                                    onTap: () async {
                                      (_permission == 'noCamera')
                                          ? pickImageFromCamera()
                                          : pickImageFromGallery();
                                      setState(() {
                                        _permission = '';
                                      });
                                    },
                                    child: MyText(
                                      text: languages[choosenLanguage]
                                          ['text_done'],
                                      size: media.width * sixteen,
                                      fontweight: FontWeight.w600,
                                      color: buttonColor,
                                    ))
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ))
              : Container(),
          //loader
          (_isLoading == true)
              ? const Positioned(top: 0, child: Loading())
              : Container(),

          //error
          (_error != '')
              ? Positioned(
                  child: Container(
                  height: media.height * 1,
                  width: media.width * 1,
                  color: Colors.transparent.withOpacity(0.6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        width: media.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: page),
                        child: Column(
                          children: [
                            SizedBox(
                              width: media.width * 0.8,
                              child: MyText(
                                text: _error.toString(),
                                textAlign: TextAlign.center,
                                size: media.width * sixteen,
                                fontweight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                            Button(
                                onTap: () async {
                                  setState(() {
                                    _error = '';
                                  });
                                },
                                text: languages[choosenLanguage]['text_ok'])
                          ],
                        ),
                      )
                    ],
                  ),
                ))
              : Container(),

          //no internet
          (internet == false)
              ? Positioned(
                  top: 0,
                  child: NoInternet(
                    onTap: () {
                      setState(() {
                        internetTrue();
                      });
                    },
                  ))
              : Container(),
        ],
      ),
    );
  }
}
