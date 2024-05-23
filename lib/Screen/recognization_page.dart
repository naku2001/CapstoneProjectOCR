import 'dart:developer';
import 'dart:typed_data';


import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

class RecognizePage extends StatefulWidget {
  final String? path;
  const RecognizePage({Key? key, this.path}) : super(key: key);

  @override
  State<RecognizePage> createState() => _RecognizePageState();
}

class _RecognizePageState extends State<RecognizePage> {
  bool _isBusy = false;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _processImage();  // Call the asynchronous function
  }
  Future<void> _processImage() async { // Make this method asynchronous
    final Uint8List imageBytes = await File(widget.path!).readAsBytes();
    processImage(imageBytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("recognized page")),
        body: _isBusy == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  maxLines: MediaQuery.of(context).size.height.toInt(),
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "Text goes here..."),
                ),
              ));
  }


  void processImage(Uint8List imageBytes) async {
    await dotenv.load(fileName: ".env"); // Load the .env file

    // Access variables
    String apiKey = dotenv.env['API_KEY']!;
    // final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    setState(() {
      _isBusy = true;
    });

    // log(image.filePath!);
    // final RecognizedText recognizedText =
    //     await textRecognizer.processImage(image);
    //
    // controller.text = recognizedText.text;

    // Generative AI Integration
    final model = GenerativeModel(model: 'gemini-pro-vision', apiKey: apiKey);
    //
    // final imageBytes = await File(image.filePath!).readAsBytes(); // Load image bytes
    // final imagePart = DataPart('image/jpeg', imageBytes);

    final prompt = TextPart("extract text from the given image,keep structure of the text,if you identify tabular data draw a dataframe for the data");
    // final content = Content.multi([prompt, imagePart]); // Combine text and image
    final imagePart = DataPart('image/jpeg', imageBytes ); // Adjust MIME type if needed


    final response = await model.generateContent([ Content.multi([prompt,imagePart])]);

    // Combine results
    controller.text =
    "Extracted Text:\n${response.text}";



    ///End busy state
    setState(() {
      _isBusy = false;
    });
  }

}
