import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionAddPage extends StatefulWidget {
  const QuestionAddPage({super.key});

  @override
  State<StatefulWidget> createState() => _QuestionAddPage();
}

class _QuestionAddPage extends State<QuestionAddPage> {
  // controller
  TextEditingController _queController = TextEditingController();
  List<TextEditingController> _ansController = [];

  // add/remove field
  void addField() {
    setState(() {
      _ansController.add(TextEditingController());
    });
  }

  void removeField(int index) {
    setState(() {
      _ansController.removeAt(index);
    });
  }

  // disable save
  void checkFilled() {
    setState(() {});
  }

  bool isFilled() {
    if (_queController.text.isEmpty) return false;

    for (var cont in _ansController) {
      if (cont.text.isEmpty) return false;
    }

    return true;
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
                    context, ModalRoute.withName('quiz_index')),
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

  // method build body
  Widget buildBody() => SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Nomor Urut",
              style: GoogleFonts.nunito(fontSize: 12.0),
            ),
            Text(
              0.toString(),
              style: GoogleFonts.nunito(
                  fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Pertanyaan",
              style: GoogleFonts.nunito(fontSize: 12.0),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                    child: TextField(
                  maxLines: null,
                  controller: _queController,
                  onChanged: (_) => checkFilled(),
                  decoration: InputDecoration(
                      hintText:
                          "Contoh: Apa warna bulu anjing yang kamu inginkan?",
                      border: OutlineInputBorder()),
                ))
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              "Pilihan Jawaban",
              style: GoogleFonts.nunito(fontSize: 12.0),
            ),
            SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    maxLines: null,
                    controller: _ansController[0],
                    onChanged: (_) => checkFilled(),
                    decoration: InputDecoration(
                        hintText: "Contoh: Hitam",
                        border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  onPressed: addField,
                  icon: Icon(
                    Icons.add_rounded,
                    color: Colors.blue,
                  ),
                  tooltip: "Tambah pilihan jawaban",
                ),
              ],
            ),
            Column(
                children: List.generate(_ansController.length - 1, (index) {
              return Row(
                children: [
                  Expanded(
                      child: TextField(
                    maxLines: null,
                    controller: _ansController[index + 1],
                    onChanged: (_) => checkFilled(),
                    decoration: InputDecoration(
                        hintText: "Contoh: Putih",
                        border: OutlineInputBorder()),
                  )),
                  IconButton(
                    onPressed: () {
                      removeField(index + 1);
                    },
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Colors.red,
                    ),
                    tooltip: "Hapus pilihan jawaban",
                  ),
                ],
              );
            })),
            SizedBox(
              height: 48,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: isFilled() ? () {} : null,
                        child: Text(
                          "Simpan Pertanyaan Baru",
                          style: GoogleFonts.nunito(fontSize: 16),
                        )))
              ],
            )
          ],
        ),
      );

  @override
  void initState() {
    super.initState();

    _ansController.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var cont in _ansController) {
      cont.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
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
            "Tambah Pertanyaan",
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
