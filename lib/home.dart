import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      home: const PDFReaderPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PDFReaderPage extends StatefulWidget {
  const PDFReaderPage({super.key});

  @override
  State<PDFReaderPage> createState() => _PDFReaderPageState();
}

class _PDFReaderPageState extends State<PDFReaderPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final byteData = await rootBundle.load('assets/pdf/chem.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/sample.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    setState(() {
      localPath = file.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF86363),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chemistry Grade 9', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: const [
          Icon(Icons.volume_up, color: Colors.white),
          SizedBox(width: 16),
          Icon(Icons.more_vert, color: Colors.white),
          SizedBox(width: 8),
        ],
      ),
      body: localPath != null
          ? Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: PDFView(
                filePath: localPath!,
              ),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.file_copy),
                label: '',
              ),
            ],
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}
