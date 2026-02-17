import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class DocumentsController extends GetxController {
  var isLoading = false.obs;
  var documents = <Map<String, dynamic>>[].obs;

  // For Add Document View
  var selectedFile = Rxn<File>();
  var fileName = ''.obs;
  var fileSize = ''.obs;
  var titleController = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // TODO: Fetch documents from backend API
    _loadMockDocuments();
  }

  void _loadMockDocuments() {
    isLoading.value = true;
    // Simulate network delay
    Future.delayed(const Duration(seconds: 2), () {
      documents.value = [
        {
          'title': 'Service Agreement Contract.pdf',
          'size': '200 KB',
          'type': 'PDF',
        },
        {
          'title': 'Invoice for Services Rendered.pdf',
          'size': '720 KB',
          'type': 'PDF',
        },
        {'title': 'Client Onboarding Form.pdf', 'size': '16 MB', 'type': 'PDF'},
        {
          'title': 'Service Provider Evaluation .pdf',
          'size': '4.2 MB',
          'type': 'PDF',
        },
        {'title': 'Terms and Conditions .pdf', 'size': '400 KB', 'type': 'PDF'},
        {'title': 'SLA.pdf', 'size': '12 MB', 'type': 'PDF'},
        {
          'title': 'Payment Receipt for Services.pdf',
          'size': '18.6 MB',
          'type': 'PDF',
        },
      ];
      isLoading.value = false;
    });
  }

  Future<void> pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      selectedFile.value = file;
      fileName.value = result.files.single.name;
      fileSize.value = _formatBytes(result.files.single.size);
    }
  }

  String _formatBytes(int bytes, [int decimals = 1]) {
    if (bytes <= 0) return "0 B";
    const prefixes = ["B", "KB", "MB", "GB", "TB"];
    // Standard byte formatting
    int index = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    if (index >= prefixes.length) index = prefixes.length - 1;
    double d = bytes / (index == 0 ? 1 : (1 << (10 * index)));
    return '${d.toStringAsFixed(decimals)} ${prefixes[index]}';
  }

  // Re-implementing a better formatBytes
  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (bytes > 0) ? (bytes.toString().length - 1) ~/ 3 : 0;
    // Actually log10/log1024 is better but this is fine for simple app
    double size = bytes / (1 << (10 * i));
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  void addDocument(String title) {
    if (selectedFile.value != null && title.isNotEmpty) {
      documents.insert(0, {
        'title': '$title.${fileName.value.split('.').last}',
        'size': fileSize.value,
        'type': fileName.value.split('.').last.toUpperCase(),
      });
      Get.back();
      // Reset
      selectedFile.value = null;
      fileName.value = '';
      fileSize.value = '';
    }
  }
}
