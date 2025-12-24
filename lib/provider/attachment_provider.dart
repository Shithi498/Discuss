import 'dart:io';
import 'package:flutter/foundation.dart';

import '../model/attachment_upload.dart';
import '../repo/attachment_repo.dart';

class AttachmentProvider extends ChangeNotifier {
  final AttachmentRepo repo;

  AttachmentProvider({required this.repo});

  bool _uploading = false;
  bool get uploading => _uploading;
bool _downloading= false;
bool get downloading =>_downloading;
  String? _error;
  String? get error => _error;

  AttachmentUpload? _last;
  AttachmentUpload? get last => _last;
  File? _selectedFile;
  File? get selectedFile => _selectedFile;
  File? _downloadedFile;
  File? get downloadedFile => _downloadedFile;


  void setSelectedFile(File? file) {
    _selectedFile = file;
    notifyListeners();
  }

  void clearSelectedFile() {
    _selectedFile = null;
    notifyListeners();
  }
  Future<AttachmentUpload?> upload(File file) async {
    _uploading = true;
    _error = null;
    _last = null;
    notifyListeners();

    try {
      final res = await repo.uploadAttachment(file);
      _last = res;
      return res;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _uploading = false;
      notifyListeners();
    }
  }
  Future<File?> download({
    required int attachmentId,
    required String fileName,
  }) async {
    _downloading = true;
    _error = null;
    _downloadedFile = null;
    notifyListeners();

    try {
      final file = await repo.downloadAttachment(
        attachmentId: attachmentId,
        fileName: fileName,
      );

      _downloadedFile = file;
      return file;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _downloading = false;
      notifyListeners();
    }
  }
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
