
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../../extensions/passbook_parser.dart';
import 'passbook_scanner_event.dart';
import 'passbook_scanner_state.dart';

class PassbookScannerBloc
    extends Bloc<PassbookScannerEvent, PassbookScannerState> {

  final ImagePicker _imagePicker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  PassbookScannerBloc() : super(const PassbookScannerInitial()) {
    on<PassbookScanFromCamera>(_onScanFromCamera);
    on<PassbookScanFromGallery>(_onScanFromGallery);
    on<PassbookOcrCompleted>(_onOcrCompleted);
    on<PassbookScanReset>(_onReset);
    on<PassbookScanErrorOccurred>(_onError);
  }

  Future<void> _onScanFromCamera(
    PassbookScanFromCamera event,
    Emitter<PassbookScannerState> emit,
  ) async {
    await _pickAndProcess(ImageSource.camera, emit);
  }

  Future<void> _onScanFromGallery(
    PassbookScanFromGallery event,
    Emitter<PassbookScannerState> emit,
  ) async {
    await _pickAndProcess(ImageSource.gallery, emit);
  }

  Future<void> _pickAndProcess(
    ImageSource source,
    Emitter<PassbookScannerState> emit,
  ) async {
    emit(PassbookScannerLoading(
      message: source == ImageSource.camera
          ? 'Opening camera...'
          : 'Opening gallery...',
    ));

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        emit(const PassbookScannerInitial());
        return;
      }

      emit(const PassbookScannerLoading(message: 'Recognising text...'));

      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final recognisedText = await _textRecognizer.processImage(inputImage);

      add(PassbookOcrCompleted(
        rawText: recognisedText.text,
        imagePath: pickedFile.path,
      ));
    } catch (e) {
      add(PassbookScanErrorOccurred('Error: ${e.toString()}'));
    }
  }

  void _onOcrCompleted(
    PassbookOcrCompleted event,
    Emitter<PassbookScannerState> emit,
  ) {
    emit(const PassbookScannerLoading(message: 'Parsing bank details...'));

    final bankDetails = PassbookParser.parsePassbook(event.rawText);

    if (bankDetails.hasData) {
      emit(PassbookScannerSuccess(
        bankDetails: bankDetails,
        imagePath: event.imagePath,
        rawText: event.rawText,
      ));
    } else {
      emit(PassbookScannerNoData(imagePath: event.imagePath));
    }
  }

  void _onReset(PassbookScanReset event, Emitter<PassbookScannerState> emit) {
    emit(const PassbookScannerInitial());
  }

  void _onError(
    PassbookScanErrorOccurred event,
    Emitter<PassbookScannerState> emit,
  ) {
    emit(PassbookScannerError(event.message));
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
