import 'dart:typed_data';

class ChatOutgoingFile {
  const ChatOutgoingFile({required this.bytes, required this.mimeType, this.name, this.document = false});

  final Uint8List bytes;
  final String mimeType;
  final String? name;
  final bool document;

  int get size => bytes.length;
}
