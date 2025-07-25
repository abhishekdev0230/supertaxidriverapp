import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translation/translation.dart';
import '../../widgets/widgets.dart';
import '../noInternet/nointernet.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(media.width * 0.05),
              height: media.height * 1,
              width: media.width * 1,
              color: page,
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: MediaQuery.of(context).padding.top),
                        Stack(
                          children: [
                            Container(
                              padding:
                                  EdgeInsets.only(bottom: media.width * 0.05),
                              width: media.width * 1,
                              alignment: Alignment.center,
                              child: MyText(
                                text: languages[choosenLanguage]['text_about'],
                                size: media.width * twenty,
                                fontweight: FontWeight.w600,
                              ),
                            ),
                            Positioned(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(
                                      Icons.arrow_back_ios,
                                      color: textColor,
                                    )))
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        SizedBox(
                          width: media.width * 0.9,
                          height: media.height * 0.16,
                          child: Image.asset(
                            'assets/images/aboutImage.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                        //terms and conditions
                        InkWell(
                          onTap: () {
                            openBrowser('https://supertaxi.in/terms/');
                          },
                          child: Text(
                            languages[choosenLanguage]
                                ['text_termsandconditions'],
                            style: GoogleFonts.notoSans(
                                fontSize: media.width * sixteen,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        //privacy policy
                        InkWell(
                          onTap: () {
                            openBrowser('https://supertaxi.in/privacy/');
                          },
                          child: Text(
                            languages[choosenLanguage]['text_privacy'],
                            style: GoogleFonts.notoSans(
                                fontSize: media.width * sixteen,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        //website
                        InkWell(
                          onTap: () {
                            openBrowser('https://supertaxi.in/');
                          },
                          child: Text(
                            languages[choosenLanguage]['text_about'],
                            style: GoogleFonts.notoSans(
                                fontSize: media.width * sixteen,
                                fontWeight: FontWeight.w600,
                                color: textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

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
      ),
    );
  }
}
