import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

Future<bool> verifyUpdateFile(VerifyUpdateFileParams params) async {
  return await compute<VerifyUpdateFileParams, bool>(
      _verifyUpdateFileWorker, params,
      debugLabel: 'Verify Update File Isolate - verifyUpdateFile()');
}

Future<bool> _verifyUpdateFileWorker(VerifyUpdateFileParams params) async {
  final file = File(params.filePath);
  if (await file.exists() == false) {
    return false;
  }

  final fileContents = await file.readAsBytes();
  final localChecksum = sha256.convert(fileContents).toString().toLowerCase();

  print(localChecksum);
  print(params.remoteChecksum);

  return localChecksum == params.remoteChecksum.toLowerCase();
}

class VerifyUpdateFileParams {
  final String remoteChecksum;
  final String filePath;

  VerifyUpdateFileParams({
    required this.remoteChecksum,
    required this.filePath,
  });
}
