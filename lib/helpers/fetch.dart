import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:async/async.dart';
import 'package:mime_type/mime_type.dart';

enum Method {
  get,
  put,
  post,
  delete,
}

class ApiResult {
  String error = '';
  int statusCode = 0;
  Map<String, dynamic> data;

  ApiResult({this.error, this.data});
  ApiResult.error(this.error, {this.statusCode});
  ApiResult.data(this.data, {this.statusCode});

  get isError => error.isNotEmpty;
}

Future<ApiResult> fetch({
  Method method = Method.get,
  String url,
  Map<String, String> headers,
  dynamic data,
}) async {
  http.Response response;
  final fullURL = 'https://demo-api.huxapp.com${url}';
  if (headers == null) {
    headers = Map();
  }
  String body;
  if (canHaveBody(method)) {
    headers['Content-Type'] = 'application/json; charset=utf-8';
    body = data == null ? '{}' : json.encode(data);
  }
  try {
    if (method == Method.get) {
      response = await http.get(fullURL, headers: headers);
    } else {
      response = await http.post(fullURL, headers: headers, body: body);
    }
  } catch (ex) {
    return ApiResult.error('Failed to load data; ${ex.toString()}');
  }
  final statusCode = response.statusCode;
  if (!isStatusOK(statusCode)) {
    return ApiResult.error(
      'Failed to load data; Response Status: $statusCode',
      statusCode: statusCode,
    );
  }
  return ApiResult.data(
    json.decode(response.body),
    statusCode: statusCode,
  );
}

Future<ApiResult> sendFile({
  Method method = Method.post,
  String url,
  Map<String, String> fields,
  Map<String, File> files,
}) async {
  if (!canHaveBody(method)) {
    return ApiResult.error('Error: bad request method');
  }
  final methodStr = method == Method.put ? 'PUT' : 'POST';
  final request = http.MultipartRequest(methodStr, Uri.parse(url));
  fields.forEach((final key, final value) {
    request.fields[key] = value;
  });
  for (final name in files.keys) {
    final file = files[name];
    final byteLength = await file.length();
    final fileName = basename(file.path);
    final mimeType = mime(fileName);
    request.files.add(
      http.MultipartFile(
        name,
        http.ByteStream(DelegatingStream.typed(file.openRead())),
        byteLength,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ),
    );
  }
  http.Response response;
  try {
    final responseStream = await request.send();
    response = await http.Response.fromStream(responseStream);
  } catch (ex) {
    return ApiResult.error('Failed to load data; ${ex.toString()}');
  }
  final statusCode = response.statusCode;
  if (!isStatusOK(statusCode)) {
    return ApiResult.error(
      'Failed to load data; Response Status: $statusCode',
      statusCode: statusCode,
    );
  }
  return ApiResult.data(
    json.decode(response.body),
    statusCode: statusCode,
  );
}

bool isStatusOK(int statusCode) {
  return statusCode >= 200 && statusCode < 300;
}

bool canHaveBody(Method method) {
  return method == Method.post || method == Method.put;
}
