import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff20202B),
          title: Text('pleasurepal'.toUpperCase(),
              style: TextStyle(
                  fontSize: 18,
                  fontFamily: GoogleFonts.poppins(fontWeight: FontWeight.w900)
                      .fontFamily)),
        ),
        body: Container(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Stack(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Connect your devices'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          GoogleFonts.poppins(fontWeight: FontWeight.bold)
                              .fontFamily,
                    ),
                  ),
                  Text(
                    'Connect devices to use in pleasurepal'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                    ),
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => {},
                    child: Text(
                      'Start scanning'.toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily,
                      ),
                    ),
                  ),
                  //full width container
                  Container(
                      width: double.infinity,
                      child: Row(children: [
                        Text(
                          'Device name'.toUpperCase(),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold)
                                  .fontFamily),
                        ),
                        Spacer(),
                        Switch(
                            value: true,
                            onChanged: (value) {
                              print(value);
                            }),
                      ]),
                      decoration: BoxDecoration(
                        color: Color(0xff20202B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 20),
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10)),
                ],
              ),
            ])));
  }
}
