import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dragchat.dart';

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
  double readingProgress = 0.0;
  Set<int> bookmarkedPages = {};
  PdfDocument? pdfDocument;
  List<Map<String, dynamic>> chapters = [];
  String? selectedVoiceName;
  double _speechRate = 0.5;
  String? userEmail;



  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    // loadPDF();
    // _loadBookmarks();
    // _loadTtsSettings();

  }
  Future<void> _loadUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    userEmail = prefs.getString('username');
    await loadPDF();
    await _loadBookmarks();
    await _loadTtsSettings();
  }
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBookmarks = prefs.getStringList('bookmarked_pages_${userEmail ?? "default"}') ?? [];
    setState(() {
      bookmarkedPages = savedBookmarks.map((e) => int.tryParse(e) ?? 0).toSet();
    });
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_pages_${userEmail ?? "default"}', bookmarkedPages.map((e) => e.toString()).toList());
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
    await _loadLastPage();
  }
  Future<void> _loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastPage = prefs.getInt('last_page_${userEmail ?? "default"}') ?? 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pdfViewerController.jumpToPage(lastPage);
      setState(() {
        currentPage = lastPage;
        if (pdfDocument != null) {
          readingProgress = (lastPage / pdfDocument!.pages.count) * 100;
        }
      });
    });
  }


  void extractChapters() {
    chapters.clear();
    if (pdfDocument == null) return;

    for (int i = 0; i < pdfDocument!.pages.count; i++) {
      final text = PdfTextExtractor(pdfDocument!).extractText(startPageIndex: i, endPageIndex: i);
      if (text != null && text.toLowerCase().contains('unit')) {
        final unitTitle = text.split('\n').firstWhere(
              (line) => line.toLowerCase().contains('unit'),
          orElse: () => 'Unit ${i + 1}',
        );
        chapters.add({'title': unitTitle, 'page': i + 1});
      }
    }
  }
  Future<void> _loadTtsSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _speechRate = prefs.getDouble('speech_rate') ?? 0.5;
    selectedVoiceName = prefs.getString('voice_name');

    await flutterTts.setSpeechRate(_speechRate);
    if (selectedVoiceName != null) {
      final voices = await flutterTts.getVoices;
      final matchingVoice = voices.firstWhere(
            (v) => v['name'] == selectedVoiceName,
        orElse: () => null,
      );
      if (matchingVoice != null) {
        await flutterTts.setVoice(matchingVoice);
      }
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
  void _saveLastReadPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page_${userEmail ?? "default"}', page);
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
    double _speechRate = 0.5;
    String? selectedVoiceName;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {

            SharedPreferences.getInstance().then((prefs) {
              final savedRate = prefs.getDouble('speech_rate') ?? 0.5;
              final voiceName = prefs.getString('voice_name');
              if (_speechRate != savedRate || selectedVoiceName != voiceName) {
                setState(() {
                  _speechRate = savedRate;
                  selectedVoiceName = voiceName;
                });
                flutterTts.setSpeechRate(_speechRate);
              }
            });

            return AlertDialog(
              title: const Text("Command Center"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        flutterTts.stop();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("TTS Reset.")),
                        );
                      },
                      child: const Text("🔁 Reset TTS"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _pdfViewerController.jumpToPage(1);
                        _saveLastReadPage(1);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reading progress reset.")),
                        );
                      },
                      child: const Text("🧨 Reset Reading Progress"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final bookmarksText =
                        bookmarkedPages.map((e) => "Page $e").join("\n");
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("📚 Bookmarked Pages"),
                            content: Text(bookmarksText.isEmpty
                                ? "No bookmarks yet."
                                : bookmarksText),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Close"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: const Text("📥 Export Bookmarks"),
                    ),
                    const SizedBox(height: 16),
                    const Text("🎙️ Read Aloud Speed"),
                    Slider(
                      value: _speechRate,
                      min: 0.2,
                      max: 1.5,
                      divisions: 13,
                      label: _speechRate.toStringAsFixed(2),
                      onChanged: (value) async {
                        setState(() => _speechRate = value);
                        await flutterTts.setSpeechRate(value);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setDouble('speech_rate', value);
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        var voices = await flutterTts.getVoices;
                        if (!context.mounted) return;

                        showDialog(
                          context: context,
                          builder: (_) {
                            return StatefulBuilder(
                              builder: (context, innerSetState) {
                                return AlertDialog(
                                  title: const Text("🗣️ Available Voices"),
                                  content: SizedBox(
                                    width: double.maxFinite,
                                    height: 300,
                                    child: ListView.builder(
                                      itemCount: voices.length,
                                      itemBuilder: (context, index) {
                                        final voice = voices[index];
                                        final voiceName = voice['name'] ?? 'Voice $index';
                                        final isSelected = voiceName == selectedVoiceName;

                                        return ListTile(
                                          title: Text(voiceName),
                                          subtitle: Text(voice['locale'] ?? 'Unknown'),
                                          trailing: isSelected ? const Icon(Icons.check) : null,
                                          onTap: () async {
                                            final voiceName = voice['name'];
                                            final voiceLocale = voice['locale'];

                                            if (voiceName != null && voiceLocale != null) {
                                              final voiceMap = <String, String>{
                                                'name': voiceName,
                                                'locale': voiceLocale,
                                              };

                                              final result = await flutterTts.setVoice(voiceMap);
                                              debugPrint('Voice set result: $result');

                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('voice_name', voiceName);
                                              await prefs.setString('voice_locale', voiceLocale);

                                              innerSetState(() => selectedVoiceName = voiceName);
                                              setState(() => selectedVoiceName = voiceName);
                                              Navigator.pop(context);
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Voice data incomplete")),
                                              );
                                            }
                                          },


                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                      child: const Text("🎧 Choose Voice"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final file = File(localPath!);
                        if (await file.exists()) {
                          await file.delete();
                          Navigator.pop(context);
                          setState(() => localPath = null);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("PDF cache deleted.")),
                          );
                        }
                      },
                      child: const Text("🧹 Delete Cached PDF"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close"),
                ),
              ],
            );
          },
        );
      },
    );
  }



  void _bookmarkPage() {
    setState(() {
      if (bookmarkedPages.contains(currentPage)) {
        bookmarkedPages.remove(currentPage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bookmark removed.")),
        );
      } else {
        bookmarkedPages.add(currentPage);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Page bookmarked.")),
        );
      }
    });
    _saveBookmarks();
  }


  @override
  Widget build(BuildContext context) {
     return WillPopScope(
       onWillPop: () async {
         // Save current progress before popping
         final prefs = await SharedPreferences.getInstance();
         final currentPage = _pdfViewerController.pageNumber;
         final totalPages = pdfDocument?.pages.count ?? 1;
         await prefs.setInt('last_page', currentPage);
         await prefs.setDouble('reading_progress', (currentPage / totalPages) * 100);

         // Return true to allow pop, and send back a result
         Navigator.pop(context, true); // This triggers the `if (result == true)` block
         return false; // Prevent default pop (since we manually popped)
       },
      child: Scaffold(
      backgroundColor:Colors.teal,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, true),
        ),
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
        ],
      ),
      body: localPath != null
          ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: readingProgress / 100,
                  color: Colors.green,
                  backgroundColor: Colors.grey.shade300,
                ),
                SizedBox(height: 4),
                Text(
                  '${readingProgress.toStringAsFixed(1)}% read',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
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
                    if (pdfDocument != null) {
                      readingProgress = (currentPage / pdfDocument!.pages.count) * 100;
                    }
                  });

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('last_page', currentPage);
                  await prefs.setDouble('reading_progress', readingProgress); // <-- ADD THIS LINE
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
        backgroundColor: Colors.teal,
        child: const Icon(Icons.chat),
        onPressed: () {
      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DraggableChatSheet(),
      );
      },
      ),
    ),
     );

  }
}
