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
import 'package:pawfect_find/class/breed.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BreedEditPage extends StatefulWidget {
  const BreedEditPage({super.key});

  @override
  State<StatefulWidget> createState() => _BreedEditPage();
}

class _BreedEditPage extends State<BreedEditPage> {
  Breed? _breed;

  // shared pref
  int? idBreed;

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
  bool isPuppyChanged = false;
  bool isAdultChanged = false;

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
      _attentionController.text.isNotEmpty;

  // check double input
  bool isDouble() =>
      double.tryParse(_minHeightController.text) != null &&
      double.tryParse(_maxHeightController.text) != null &&
      double.tryParse(_minWeightController.text) != null &&
      double.tryParse(_maxWeightController.text) != null &&
      double.tryParse(_minLifeController.text) != null &&
      double.tryParse(_maxLifeController.text) != null;

  // check range
  bool isRangeTrue() {
    double minHeight = double.parse(_minHeightController.text);
    double maxHeight = double.parse(_maxHeightController.text);
    double minWeight = double.parse(_minWeightController.text);
    double maxWeight = double.parse(_maxWeightController.text);
    double minLife = double.parse(_minLifeController.text);
    double maxLife = double.parse(_maxLifeController.text);

    return minHeight <= maxHeight &&
        minWeight <= maxWeight &&
        minLife <= maxLife;
  }

  // method shared preferences
  Future<int?> getBreedID() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idBreed = prefs.getInt('id_breed');
    });
    return idBreed;
  }

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
          isPuppyChanged = true;
        } else {
          adultImg = File(img!.path);
          adultByte = inByte;
          isAdultChanged = true;
        }
      });
    }
  }

  // method fetch data
  Future<Breed> fetchData() async {
    try {
      final response = await http.post(
          Uri.parse("http://localhost/ta/Pawfect-Find-PHP/detail.php"),
          body: {
            'breed_id': idBreed.toString(),
          });

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['result'] == 'Success') {
          Breed result = Breed.fromJson(json['data']);

          _nameController.text = result.breed;
          dropdownValue = result.group;
          _minHeightController.text = result.heightMin.toString();
          _maxHeightController.text = result.heightMax.toString();
          _minWeightController.text = result.weightMin.toString();
          _maxWeightController.text = result.weightMax.toString();
          _minLifeController.text = result.lifeMin.toString();
          _maxLifeController.text = result.lifeMax.toString();
          _originController.text = result.origin;
          _colourController.text = result.colour;
          _attentionController.text = result.attention;

          return result;
        } else {
          throw Exception("Gagal menampilkan data: ${json['message']}.");
        }
      } else {
        throw Exception(
            "Gagal menampilkan data: Status ${response.statusCode}.");
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex.");
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

  // method delete foto lama di firebase
  Future<void> deleteFirebaseImg(String imgUrl) async {
    try {
      if (imgUrl.isNotEmpty) {
        Reference ref = FirebaseStorage.instance.refFromURL(imgUrl);
        await ref.delete();
      }
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Terjadi kesalahan: $ex."),
        duration: Duration(seconds: 3),
      ));
      throw Exception("Terjadi kesalahan: $ex.");
    }
  }

  // method edit data
  Future updateData(String? dbPuppy, String? dbAdult) async {
    if (isFilled()) {
      if (isDouble()) {
        if (isRangeTrue()) {
          try {
            String puppyUrl = '';
            String adultUrl = '';

            // Hapus foto lama jika ada perubahan
            if (isPuppyChanged && dbPuppy != null) {
              await deleteFirebaseImg(dbPuppy);
            }
            if (isAdultChanged && dbAdult != null) {
              await deleteFirebaseImg(dbAdult);
            }

            // upload foto ke firebase
            if (isPuppyChanged) {
              puppyUrl = await upImgFirebase(puppyByte!);
            } else {
              puppyUrl = dbPuppy ?? '';
            }

            if (isAdultChanged) {
              adultUrl = await upImgFirebase(adultByte!);
            } else {
              adultUrl = dbAdult ?? '';
            }

            final response = await http.post(
              Uri.parse(
                  "http://localhost/ta/Pawfect-Find-PHP/admin/breed_edit.php"),
              body: {
                'id': idBreed.toString(),
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
                  content: Text("Berhasil memperbarui data."),
                  duration: Duration(seconds: 3),
                ));

                Navigator.pop(context);
              } else {
                throw Exception("Gagal memperbarui data: ${json['message']}.");
              }
            } else {
              throw Exception(
                  "Gagal memperbarui data: Status ${response.statusCode}.");
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
            content: Text("Nilai minimum harus lebih kecil atau sama dengan nilai maksimum."),
            duration: Duration(seconds: 3),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Data minimum dan maksimum harus berupa angka."),
          duration: Duration(seconds: 3),
        ));
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
  Widget inputImg(String age, String? dbImg) {
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
                child: dbImg != null && imgPath == null
                    ? Image.network(
                        dbImg,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, trace) {
                          return Image.asset(
                            "assets/logos/logo-black.png",
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : imgPath == null
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
  Widget buildBody() => idBreed == null
      ? Center(
          child: CircularProgressIndicator(),
        )
      :
      // FutureBuilder<Breed>(
      //     future: fetchData(),
      //     builder: (context, snapshot) {
      //       if (snapshot.connectionState == ConnectionState.done) {
      //         if (snapshot.hasError) {
      //           return Center(
      //             child: Text(
      //               'Error: ${snapshot.error}',
      //               style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
      //             ),
      //           );
      //         } else if (snapshot.hasData) {
      //           Breed breed = snapshot.data!;

      //           return
      SingleChildScrollView(
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
                        dropdownValue = newValue!;
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
              inputStr(
                  "Warna", "Contoh: Sable, hitam, biru", _colourController),
              inputStr(
                  "Perhatian khusus",
                  "Contoh: Anjing ras ini sangat tidak disarankan untuk menjadi anjing peliharaan pertama",
                  _attentionController),
              inputImg("muda", _breed!.imgPuppy),
              inputImg("dewasa", _breed!.imgAdult),
              SizedBox(
                height: 48,
              ),
              Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () =>
                              updateData(_breed!.imgPuppy, _breed!.imgAdult),
                          child: Text(
                            "Simpan Pembaruan",
                            style: GoogleFonts.nunito(fontSize: 16),
                          )))
                ],
              )
            ],
          ),
        );
  //     } else {
  //       return Center(
  //         child: Text(
  //           'Data tidak ditemukan.',
  //           style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey),
  //         ),
  //       );
  //     }
  //   } else {
  //     return Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   }
  // });

  @override
  void initState() {
    super.initState();

    getBreedID().then((id) {
      setState(() {
        idBreed = id;
      });

      if (idBreed != null) {
        fetchData().then((breed) {
          setState(() {
            _breed = breed;
          });
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Terjadi kesalahan: $error."),
            duration: Duration(seconds: 3),
          ));
          throw Exception("Terjadi kesalahan: $error.");
        });
      }
    });
  }

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
              "Perbarui Ras Anjing",
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
