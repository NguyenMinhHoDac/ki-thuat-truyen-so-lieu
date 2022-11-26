import 'dart:convert';

class FileMessage {
  String fileSenderName;
  String? fileCreateAt = DateTime.now().toString();
  String fileName;
  String fileBytes;

  FileMessage(
      {required this.fileSenderName,
      this.fileCreateAt,
      required this.fileName,
      required this.fileBytes});

  static FileMessage fromJson(String jsonString) {
    // String youtube = jsonString.substring(jsonString.indexOf('['), jsonString.lastIndexOf(']') + 1);
    Map<String, dynamic> map = json.decode(jsonString);
    return FileMessage(
        fileSenderName: map['fileSenderName'],
        fileName: map['fileName'],
        fileCreateAt: map['fileCreateAt'],
        fileBytes: map['fileBytes']);
  }

  Map<String, dynamic> toJson() {
    return {
      "fileSenderName": fileSenderName,
      "fileName": fileName,
      "fileCreateAt": fileCreateAt,
      "fileBytes": fileBytes
    };
  }
}
