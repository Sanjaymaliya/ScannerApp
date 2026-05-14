
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../extensions/card_parser.dart';
import 'card_scanner_event.dart';
import 'card_scanner_state.dart';

class CardScannerBloc extends Bloc<CardScannerEvent, CardScannerState> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  CardScannerBloc() : super(const CardScannerInitial()) {
    on<CardScanStarted>(_onScanStarted);
    on<CardOcrCompleted>(_onOcrCompleted);
    on<CardScanReset>(_onReset);
    on<CardScanErrorOccurred>(_onError);
  }

  Future<void> _onScanStarted(
    CardScanStarted event,
    Emitter<CardScannerState> emit,
  ) async {
    emit(const CardScannerLoading(message: 'Opening camera...'));

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (pickedFile == null) {
        // User cancelled
        emit(const CardScannerInitial());
        return;
      }

      emit(const CardScannerLoading(message: 'Recognising text...'));

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final recognisedText = await _textRecognizer.processImage(inputImage);
      final rawText = recognisedText.text;

      add(CardOcrCompleted(rawText: rawText, imagePath: pickedFile.path));
    } catch (e) {
      add(CardScanErrorOccurred('Camera error: ${e.toString()}'));
    }
  }

  void _onOcrCompleted(
    CardOcrCompleted event,
    Emitter<CardScannerState> emit,
  ) {
    emit(const CardScannerLoading(message: 'Parsing card data...'));

    final cardDetails = CardParser.parseCard(event.rawText);

    if (cardDetails.hasData) {
      emit(CardScannerSuccess(
        cardDetails: cardDetails,
        imagePath: event.imagePath,
        rawText: event.rawText,
      ));
    } else {
      emit(CardScannerNoData(imagePath: event.imagePath));
    }
  }

  void _onReset(CardScanReset event, Emitter<CardScannerState> emit) {
    emit(const CardScannerInitial());
  }

  void _onError(CardScanErrorOccurred event, Emitter<CardScannerState> emit) {
    emit(CardScannerError(event.message));
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
