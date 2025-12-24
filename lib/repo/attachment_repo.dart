import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';


import '../model/attachment_upload.dart';

class AttachmentRepo {
  final String baseUrl;
  final String sessionCookie;

  AttachmentRepo({
    required this.baseUrl,
    required this.sessionCookie,
  });

  Future<AttachmentUpload> uploadAttachment(File file) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "Accept": "application/json",
          "Cookie": sessionCookie,

        },
      ),
    );

    final formData = FormData.fromMap({

      "file": await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final res = await dio.post(
      "/api/discuss/attachment/upload",
      data: formData,
    );
print("attachment file");

print(res.realUri);
    final data = res.data is Map ? Map<String, dynamic>.from(res.data) : <String, dynamic>{};

    if (res.statusCode != 200) {
      throw Exception("Upload failed (${res.statusCode}): $data");
    }

    return AttachmentUpload.fromJson(data);
  }
  Future<File> downloadAttachment({
    required int attachmentId,
    required String fileName,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: {
          "Accept": "*/*",
          "Cookie": sessionCookie, // 🔑 REQUIRED
        },
        responseType: ResponseType.bytes,
      ),
    );

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$fileName';

    final response = await dio.get(
      '/api/discuss/attachment/$attachmentId',
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Download failed (${response.statusCode})',
      );
    }

    final file = File(filePath);
    await file.writeAsBytes(response.data);

    return file;
  }

}
