import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quickpaisa/database/user_data_storage.dart';

import 'package:qr_flutter/qr_flutter.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:dio/dio.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:slug_it/slug_it.dart';
import 'package:intl/intl.dart'; // for date format
import 'package:file_manager/file_manager.dart'; // for date format
import 'package:open_file_plus/open_file_plus.dart';

class ProductQRCodeScreen extends StatefulWidget {
  final dynamic product;

  const ProductQRCodeScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductQRCodeScreen> createState() => _ProductQRCodeScreen();
}

class _ProductQRCodeScreen extends State<ProductQRCodeScreen> {
  String _downloadButtonText = "Download PDF";
  bool _isDownloading = false;
  String _localPath = "";
  bool _permissionReady = false;
  String fileName = "";
  final FileManagerController controller = FileManagerController();

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      return "/storage/emulated/0/Download/";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return directory.path + Platform.pathSeparator + 'Download';
    }
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;

    print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  void _downloadPDF() async {
    _permissionReady = await _checkPermission();
    if (_permissionReady) {
      if (!_isDownloading) {
        await _prepareSaveDir();
        try {
          setState(() {
            _downloadButtonText = "Generating PDF...";
            _isDownloading = true;
          });
          String titleSlug = SlugIT().makeSlug(widget.product['title']);
          fileName = titleSlug +
              "-" +
              DateFormat('yyyy-MM-dd-hh-mm-ss').format(DateTime.now()) +
              ".pdf";
          await Dio().download(
              "${ApiConstants.baseUrl}download-product-pdf/${widget.product['id']}",
              _localPath + fileName,
              onReceiveProgress: (received, total) async {
            int percentage = ((received / total) * 100).floor();
            // await Future.delayed(Duration(milliseconds: 100));
            // print("${received}% ${total}");
            setState(() {
              _downloadButtonText =
                  "${percentage.toInt().toString()}% Downloaded";
            });
          });
          final status = await Permission.storage.status;
          if (status != PermissionStatus.granted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 3),
                content: Text("PDF Downloaded! See the download folder"),
                backgroundColor: Colors.green));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 5),
                content: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Text("PDF Downloaded!"),
                    ),
                    InkWell(
                      child: Text(
                        "Open File",
                        style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationThickness: 1),
                      ),
                      onTap: () {
                        OpenFile.open(_localPath + fileName);
                      },
                    )
                  ],
                ),
                backgroundColor: Colors.green));
          }
        } catch (e) {
          print("Download Failed.\n\n" + e.toString());
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 3),
              content: Text("Download Failed: " + e.toString()),
              backgroundColor: Colors.redAccent));
        }
        await Future.delayed(Duration(seconds: 3));
        setState(() {
          _downloadButtonText = "Download PDF";
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.primaryBackground),
      appBar: AppBar(
        title: Text(widget.product['title']),
        centerTitle: true,
        backgroundColor: Color(AppColors.primaryBackground),
        elevation: 0,
        foregroundColor: Color(AppColors.primaryText),
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back)),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 12,
            ),
            OutlinedButton(
                onPressed: _downloadPDF,
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        Color(AppColors.primaryColorDim).withOpacity(.15)),
                    foregroundColor: MaterialStateProperty.all(
                        Color(AppColors.primaryColor))),
                child: Text(_downloadButtonText)),
            SizedBox(
              height: 12,
            ),
            Text(
              "Share this code to receicve payments",
              style: GoogleFonts.poppins(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: <TextSpan>[
                  TextSpan(text: '( '),
                  TextSpan(
                      text: 'QuickPaisa',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.primaryColor))),
                  TextSpan(
                      text:
                          ' is a prototype, \nyou cannot send or\nreceive real money )'),
                ])),
            SizedBox(
              height: 20,
            ),
            Text(
              "Rs. ${widget.product['amount']}",
              style: TextStyle(
                  color: Color(AppColors.primaryColor),
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 60,
            ),
            Stack(children: [
              ClipPath(
                clipper: QRClipper(),
                child: Container(
                  width: 304,
                  height: 304,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Color(AppColors.primaryColor),
                      width: 8.4,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ),
              Container(
                  width: 304,
                  height: 304,
                  padding: EdgeInsets.all(24),
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: UserDataStorage().getUserData(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          Map<String, dynamic> qrFields = {
                            'type': "product",
                            'title': widget.product['title'] ?? "",
                            'amount': widget.product['amount'] ?? "",
                            'banner': widget.product['banner'] ?? "",
                            'brandName': widget.product['brand']!['name'] ?? "",
                            'walletAddress':
                                widget.product['walletAddress'] ?? "",
                          };
                          return QrImage(
                            data: json.encode(qrFields),
                            version: QrVersions.auto,
                            size: 240,
                            backgroundColor: Color(AppColors.primaryText),
                            gapless: false,
                            errorStateBuilder: (cxt, err) {
                              return Positioned.fill(
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Uh oh! Something went wrong...",
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(
                              child: SizedBox(
                            width: 64,
                            height: 64,
                            child: CircularProgressIndicator(
                              color: Colors.cyan.shade400,
                              strokeWidth: 6.18,
                            ),
                          ));
                        }
                      })),
            ])
          ],
        ),
      )),
    );
  }
}

class QRClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path
      ..moveTo(size.width * .8, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * .2)
      ..moveTo(size.width, size.height * .8)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * .8, size.height)
      ..moveTo(size.width * .2, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, size.height * .8)
      ..moveTo(0, size.height * .2)
      ..lineTo(0, 0)
      ..lineTo(size.width * .2, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
