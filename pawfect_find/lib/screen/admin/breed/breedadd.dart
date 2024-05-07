import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class BreedAddPage extends StatefulWidget {
  const BreedAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _BreedAddPage();
}

class _BreedAddPage extends State<BreedAddPage> {
  // dropdown
  String dropdownValue = "Olahraga";

  // controller input
  TextEditingController _nameController = TextEditingController();
  TextEditingController _minHeightController = TextEditingController();
  TextEditingController _maxHeightController = TextEditingController();
  TextEditingController _minWeightController = TextEditingController();
  TextEditingController _maxWeightController = TextEditingController();
  TextEditingController _minLifeController = TextEditingController();
  TextEditingController _maxLifeController = TextEditingController();
  TextEditingController _originController = TextEditingController();
  TextEditingController _colourController = TextEditingController();
  TextEditingController _attentionController = TextEditingController();

  // photo handler
  File? puppyImg;
  File? adultImg;
  Uint8List? puppyByte;
  Uint8List? adultByte;

  // method enable button
  bool isFilled() =>
      _nameController.text.isNotEmpty &&
      _minHeightController.text.isNotEmpty &&
      _maxHeightController.text.isNotEmpty &&
      _minWeightController.text.isNotEmpty &&
      _maxWeightController.text.isNotEmpty &&
      _minLifeController.text.isNotEmpty &&
      _maxLifeController.text.isNotEmpty &&
      _originController.text.isNotEmpty &&
      _colourController.text.isNotEmpty &&
      _attentionController.text.isNotEmpty &&
      puppyImg != null &&
      adultImg != null;

  // method pick img
  pickImage(bool isPuppy) async {
    final ImagePicker picker = ImagePicker();

    XFile? img;
    img = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1080, maxWidth: 1080);

    if (img != null) {
      var inByte = await img.readAsBytes();

      setState(() {
        if (isPuppy) {
          puppyImg = File(img!.path);
          puppyByte = inByte;
        } else {
          adultImg = File(img!.path);
          adultByte = inByte;
        }
      });
    }
  }

  // method post image to firebase storage
  Future<String> upImgFirebase(Uint8List imgByte) async {
    try {
      // buat nama file unik
      String name = DateTime.now().millisecondsSinceEpoch.toString();

      Reference ref = FirebaseStorage.instance.ref().child('images/$name');

      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // upload
      UploadTask uploadTask = ref.putData(imgByte, metadata);
      TaskSnapshot taskSnapshot = await uploadTask;

      // ambil url
      String imgUrl = await taskSnapshot.ref.getDownloadURL();

      return imgUrl;
    } catch (ex) {
      throw Exception("Gagal unggah ke Firebase: $ex");
    }
  }

  // method tambah data
  Future addData() async {
    if (isFilled()) {
      try {
        // upload foto ke firebase
        String puppyUrl = await upImgFirebase(puppyByte!);
        String adultUrl = await upImgFirebase(adultByte!);

        final response = await http.post(
          Uri.https("cellaaudi.000webhostapp.com", "/admin/breed_add.php"),
          body: {
            'breed': _nameController.text,
            'group': dropdownValue,
            'minHeight': _minHeightController.text,
            'maxHeight': _maxHeightController.text,
            'minWeight': _minWeightController.text,
            'maxWeight': _maxWeightController.text,
            'minLife': _minLifeController.text,
            'maxLife': _maxLifeController.text,
            'origin': _originController.text,
            'colour': _colourController.text,
            'attention': _attentionController.text,
            'imgPuppy': puppyUrl,
            'imgAdult': adultUrl,
          },
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> json = jsonDecode(response.body);

          if (json['result'] == 'Success') {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Berhasil menambahkan data baru."),
              duration: Duration(seconds: 3),
            ));

            Navigator.pop(context);
          } else {
            throw Exception("Terjadi kesalahan: ${json['message']}.");
          }
        } else {
          throw Exception("Terjadi kesalahan: Status ${response.statusCode}.");
        }
      } catch (ex) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Terjadi kesalahan: $ex."),
          duration: Duration(seconds: 3),
        ));
        throw Exception("Terjadi kesalahan: $ex.");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Data belum semua terisi."),
        duration: Duration(seconds: 3),
      ));
    }
  }

  // method back message
  void _backMessage() => showDialog<void>(
      context: context,
      builder: (BuildContext ctxt) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          title: Text(
            'Batalkan',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apa kamu yakin ingin keluar tanpa menyimpan?',
            style: GoogleFonts.nunito(fontSize: 16.0),
          ),
          actions: <Widget>[
            TextButton(
                style: TextButton.styleFrom(
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: GoogleFonts.nunito(),
                )),
            TextButton(
                onPressed: () => Navigator.popUntil(
                    context, ModalRoute.withName('breed_index')),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    textStyle: TextStyle(fontWeight: FontWeight.w600)),
                child: Text(
                  'Keluar',
                  style: GoogleFonts.nunito(),
                ))
          ],
        );
      });

  // method input text field
  Widget inputStr(String txt, String hint, TextEditingController _controller) =>
      Column(
        children: [
          Row(
            children: [
              Text(txt, style: GoogleFonts.nunito(fontSize: 14)),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                maxLines: null,
                controller: _controller,
                decoration: InputDecoration(
                    hintText: hint, border: OutlineInputBorder()),
              ))
            ],
          ),
          SizedBox(
            height: 16,
          ),
        ],
      );

  // method input field min max
  Widget inputMinMax(
          String type,
          String unit,
          TextEditingController _minController,
          TextEditingController _maxController) =>
      Column(
        children: [
          Row(
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$type minimal",
                      style: GoogleFonts.nunito(fontSize: 14)),
                  SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: _minController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        hintText: "0.0",
                        suffixText: unit,
                        border: OutlineInputBorder()),
                  )
                ],
              )),
              SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("$type maksimal",
                      style: GoogleFonts.nunito(fontSize: 14)),
                  SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: _maxController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        hintText: "100.0",
                        suffixText: unit,
                        border: OutlineInputBorder()),
                  )
                ],
              ))
            ],
          ),
          SizedBox(
            height: 16,
          ),
        ],
      );

  // method input poto
  Widget inputImg(String age) {
    File? imgPath;
    Uint8List? imgByte;

    if (age == "muda") {
      imgPath = puppyImg;
      imgByte = puppyByte;
    } else {
      imgPath = adultImg;
      imgByte = adultByte;
    }

    return Column(
      children: [
        Row(
          children: [
            Text("Foto anjing $age", style: GoogleFonts.nunito(fontSize: 14)),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: imgPath == null ? EdgeInsets.all(16) : null,
                child: imgPath == null
                    ? Center(child: Text("Tidak ada foto dipilih."))
                    : kIsWeb
                        ? Image.memory(imgByte!, fit: BoxFit.cover)
                        : Image.file(
                            imgPath,
                            fit: BoxFit.cover,
                          ),
                decoration: BoxDecoration(
                  border: imgPath == null
                      ? Border.all(color: Colors.grey, width: 1)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
                child: OutlinedButton.icon(
              icon: Icon(Icons.photo_library_rounded),
              onPressed: () async {
                if (age == "muda") {
                  pickImage(true);
                } else {
                  pickImage(false);
                }
              },
              label: Text("Ambil dari Galeri"),
            ))
          ],
        ),
        SizedBox(
          height: 16,
        )
      ],
    );
  }

  // method untuk build body
  Widget buildBody() => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            inputStr("Nama ras anjing", "Contoh: Corgi", _nameController),
            Row(
              children: [
                Text("Kelompok", style: GoogleFonts.nunito(fontSize: 14)),
              ],
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                    child: DecoratedBox(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.black45, width: 1.0)),
                  child: DropdownButtonFormField(
                    value: dropdownValue,
                    items: <String>[
                      'Olahraga',
                      'Non-olahraga',
                      'Pekerja',
                      'Penggembala',
                      'Pemburu',
                      'Terrier',
                      'Mainan'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              value,
                              style: GoogleFonts.nunito(fontSize: 16.0),
                            ),
                          ));
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownValue = newValue!;
                      });
                    },
                    isExpanded: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(8)),
                  ),
                ))
              ],
            ),
            SizedBox(
              height: 16,
            ),
            inputMinMax(
                "Tinggi", "cm", _minHeightController, _maxHeightController),
            inputMinMax(
                "Berat", "kg", _minWeightController, _maxWeightController),
            inputMinMax(
                "Umur", "tahun", _minLifeController, _maxLifeController),
            inputStr(
                "Negara asal", "Contoh: Jerman, Inggris", _originController),
            inputStr("Warna", "Contoh: Sable, hitam, biru", _colourController),
            inputStr(
                "Perhatian khusus",
                "Contoh: Anjing ras ini sangat tidak disarankan untuk menjadi anjing peliharaan pertama",
                _attentionController),
            inputImg("muda"),
            inputImg("dewasa"),
            SizedBox(
              height: 48,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: isFilled() ? () => addData() : null,
                        child: Text(
                          "Simpan Ras Anjing",
                          style: GoogleFonts.nunito(fontSize: 16),
                        )))
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          _backMessage();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => _backMessage(),
            ),
            title: Text(
              "Tambah Ras Anjing",
              style:
                  GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800),
            ),
          ),
          body: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 500),
              child: buildBody(),
            ),
          ),
        ));
  }
}
