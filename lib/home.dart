// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
//
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PDF Reader',
//       theme: ThemeData(
//         primarySwatch: Colors.deepOrange,
//       ),
//       home: const PDFReaderPage(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class PDFReaderPage extends StatefulWidget {
//   const PDFReaderPage({super.key});
//
//   @override
//   State<PDFReaderPage> createState() => _PDFReaderPageState();
// }
//
// class _PDFReaderPageState extends State<PDFReaderPage> {
//   String? localPath;
//   final FlutterTts flutterTts = FlutterTts();
//   final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
//   final PdfViewerController _pdfViewerController = PdfViewerController();
//   int currentPage = 1;
//   Set<int> bookmarkedPages = {};
//   PdfDocument? pdfDocument;
//   List<Map<String, dynamic>> chapters = [];
//
//   @override
//   void initState() {
//     super.initState();
//     loadPDF();
//   }
//
//   Future<void> loadPDF() async {
//     final byteData = await rootBundle.load('assets/pdf/chem.pdf');
//     final file = File('${(await getTemporaryDirectory()).path}/chem.pdf');
//     await file.writeAsBytes(byteData.buffer.asUint8List());
//
//     pdfDocument = PdfDocument(inputBytes: byteData.buffer.asUint8List());
//
//     setState(() {
//       localPath = file.path;
//     });
//
//     extractChapters();
//   }
//
//   void extractChapters() {
//     chapters.clear();
//     if (pdfDocument == null) return;
//
//     for (int i = 0; i < pdfDocument!.pages.count; i++) {
//       final text = PdfTextExtractor(pdfDocument!).extractText(startPageIndex: i, endPageIndex: i);
//       if (text != null && text.toLowerCase().contains('unit')) {
//         final unitTitle = text.split('\n').firstWhere((line) => line.toLowerCase().contains('unit'), orElse: () => 'Unit ${i + 1}');
//         chapters.add({'title': unitTitle, 'page': i + 1});
//       }
//     }
//
//     if (chapters.isEmpty) {
//       debugPrint("No chapters detected.");
//     } else {
//       debugPrint("Chapters detected: \$chapters");
//     }
//   }
//
//   Future<void> _startTextToSpeech() async {
//     if (pdfDocument != null && pdfDocument!.pages.count >= currentPage) {
//       final pageText = PdfTextExtractor(pdfDocument!).extractText(startPageIndex: currentPage - 1, endPageIndex: currentPage - 1);
//       if (pageText != null && pageText.isNotEmpty) {
//         await flutterTts.speak(pageText);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No text found on this page.")));
//       }
//     }
//   }
//
//   void _showChapters() {
//     if (chapters.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No chapters found.")));
//       return;
//     }
//
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => ListView.builder(
//         itemCount: chapters.length,
//         itemBuilder: (context, index) => ListTile(
//           title: Text(chapters[index]['title']),
//           onTap: () {
//             _pdfViewerController.jumpToPage(chapters[index]['page']);
//             Navigator.pop(context);
//           },
//         ),
//       ),
//     );
//   }
//
//   void _openSettings() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Settings"),
//         content: ElevatedButton(
//           onPressed: () {
//             flutterTts.stop();
//             Navigator.pop(context);
//           },
//           child: const Text("Reset TTS"),
//         ),
//       ),
//     );
//   }
//
//   void _showOptions() {
//     showMenu(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//       items: const [
//         PopupMenuItem<int>(value: 0, child: Text("Option 1")),
//         PopupMenuItem<int>(value: 1, child: Text("Option 2")),
//       ],
//     );
//   }
//
//   void _bookmarkPage() {
//     setState(() {
//       bookmarkedPages.add(currentPage);
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Page bookmarked.")));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF86363),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Some Book Grade 9', style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.volume_up, color: Colors.white),
//             onPressed: _startTextToSpeech,
//           ),
//           IconButton(
//             icon: const Icon(Icons.menu_book, color: Colors.white),
//             onPressed: _showChapters,
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings, color: Colors.white),
//             onPressed: _openSettings,
//           ),
//           IconButton(
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onPressed: _showOptions,
//           ),
//         ],
//       ),
//       body: localPath != null
//           ? Column(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(24),
//                   topRight: Radius.circular(24),
//                 ),
//               ),
//               child: SfPdfViewer.file(
//                 File(localPath!),
//                 key: _pdfViewerKey,
//                 controller: _pdfViewerController,
//                 enableTextSelection: true,
//                 onPageChanged: (details) {
//                   setState(() {
//                     currentPage = _pdfViewerController.pageNumber;
//                   });
//                 },
//               ),
//             ),
//           ),
//           BottomNavigationBar(
//             backgroundColor: Colors.white,
//             selectedItemColor: Colors.deepOrange,
//             unselectedItemColor: Colors.grey,
//             items: [
//               const BottomNavigationBarItem(
//                 icon: Icon(Icons.home),
//                 label: 'Home',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.bookmark,
//                     color: bookmarkedPages.contains(currentPage)
//                         ? Colors.deepOrange
//                         : Colors.grey),
//                 label: 'Bookmark',
//               ),
//             ],
//             onTap: (index) {
//               if (index == 1) _bookmarkPage();
//             },
//           ),
//         ],
//       )
//           : const Center(child: CircularProgressIndicator()),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.blue,
//         child: const Icon(Icons.chat),
//         onPressed: () {},
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PDFReaderPage extends StatefulWidget {
  const PDFReaderPage({super.key});

  @override
  State<PDFReaderPage> createState() => _PDFReaderPageState();
}

class _PDFReaderPageState extends State<PDFReaderPage> {
  String? localPath;
  final FlutterTts flutterTts = FlutterTts();
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int currentPage = 1;
  int? lastPage;
  Set<int> bookmarkedPages = {};
  PdfDocument? pdfDocument;
  List<Map<String, dynamic>> chapters = [];

  @override
  void initState() {
    super.initState();
    loadPDF();
    loadBookmarks();
    loadLastPage();
  }

  Future<void> loadPDF() async {
    final byteData = await rootBundle.load('assets/pdf/chem.pdf');
    final file = File('${(await getTemporaryDirectory()).path}/chem.pdf');
    await file.writeAsBytes(byteData.buffer.asUint8List());

    pdfDocument = PdfDocument(inputBytes: byteData.buffer.asUint8List());

    setState(() {
      localPath = file.path;
    });

    extractChapters();

    // Jump to last page after widget builds
    if (lastPage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pdfViewerController.jumpToPage(lastPage!);
      });
    }
  }

  void extractChapters() {
    chapters.clear();
    if (pdfDocument == null) return;

    for (int i = 0; i < pdfDocument!.pages.count; i++) {
      final text = PdfTextExtractor(pdfDocument!).extractText(startPageIndex: i, endPageIndex: i);
      if (text != null && text.toLowerCase().contains('unit')) {
        final unitTitle = text.split('\n').firstWhere((line) => line.toLowerCase().contains('unit'), orElse: () => 'Unit ${i + 1}');
        chapters.add({'title': unitTitle, 'page': i + 1});
      }
    }

    if (chapters.isEmpty) {
      debugPrint("No chapters detected.");
    } else {
      debugPrint("Chapters detected: $chapters");
    }
  }

  Future<void> _startTextToSpeech() async {
    if (pdfDocument != null && pdfDocument!.pages.count >= currentPage) {
      final pageText = PdfTextExtractor(pdfDocument!).extractText(startPageIndex: currentPage - 1, endPageIndex: currentPage - 1);
      if (pageText != null && pageText.isNotEmpty) {
        await flutterTts.speak(pageText);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No text found on this page.")));
      }
    }
  }

  void _showChapters() {
    if (chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No chapters found.")));
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(chapters[index]['title']),
          onTap: () {
            _pdfViewerController.jumpToPage(chapters[index]['page']);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Settings"),
        content: ElevatedButton(
          onPressed: () {
            flutterTts.stop();
            Navigator.pop(context);
          },
          child: const Text("Reset TTS"),
        ),
      ),
    );
  }

  void _showOptions() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 100, 0, 0),
      items: const [
        PopupMenuItem<int>(value: 0, child: Text("Option 1")),
        PopupMenuItem<int>(value: 1, child: Text("Option 2")),
      ],
    );
  }

  void _bookmarkPage() {
    setState(() {
      bookmarkedPages.add(currentPage);
    });
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Page bookmarked.")));
    saveBookmarks();
  }

  void loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('bookmarks') ?? [];
    setState(() {
      bookmarkedPages = saved.map(int.parse).toSet();
    });
  }

  void saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'bookmarks', bookmarkedPages.map((e) => e.toString()).toList());
  }

  Future<void> loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    lastPage = prefs.getInt('last_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF86363),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Some Book Grade 9', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.white),
            onPressed: _startTextToSpeech,
          ),
          IconButton(
            icon: const Icon(Icons.menu_book, color: Colors.white),
            onPressed: _showChapters,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showOptions,
          ),
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
              child: SfPdfViewer.file(
                File(localPath!),
                key: _pdfViewerKey,
                controller: _pdfViewerController,
                enableTextSelection: true,
                onPageChanged: (details) async {
                  setState(() {
                    currentPage = _pdfViewerController.pageNumber;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('last_page', currentPage);
                },
              ),
            ),
          ),
          BottomNavigationBar(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.deepOrange,
            unselectedItemColor: Colors.grey,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark,
                    color: bookmarkedPages.contains(currentPage)
                        ? Colors.deepOrange
                        : Colors.grey),
                label: 'Bookmark',
              ),
            ],
            onTap: (index) {
              if (index == 1) _bookmarkPage();
            },
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: const Icon(Icons.chat),
        onPressed: () {},
      ),
    );
  }
}
