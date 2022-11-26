import 'dart:convert';
import 'dart:typed_data';

class FileMessage {
  String? senderName;
  String? createAt = DateTime.now().toString();
  String? fileName;
  Uint8List? fileBytes;

  FileMessage({this.senderName, this.createAt, this.fileName, this.fileBytes});

  static FileMessage fromJson(String jsonString) {
    Map<String, dynamic> map = json.decode(jsonString);
    return FileMessage(
        senderName: map['senderName'],
        fileName: map['fileName'],
        createAt: map['createAt'],
        fileBytes: Uint8List.fromList(List.from(map['fileBytes'].split(','))));
  }

  Map<String, dynamic> toJson() {
    return {
      "senderName": senderName,
      "fileName": fileName,
      "createAt": createAt,
      "fileBytes": fileBytes!.toList().toString()
    };
  }
}
