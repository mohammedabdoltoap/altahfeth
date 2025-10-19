import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class NetworkController extends GetxController {
  var isConnected = true.obs;
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();

    // التعامل مع Stream الذي قد يرجع List<ConnectivityResult>
    _connectivity.onConnectivityChanged.listen((event) {
      // event قد يكون List<ConnectivityResult> أو ConnectivityResult حسب النسخة
      ConnectivityResult result;
      if (event is List<ConnectivityResult>) {
        result = event.isNotEmpty ? event.first : ConnectivityResult.none;
      } else if (event is ConnectivityResult) {
        result = event as ConnectivityResult;
      } else {
        result = ConnectivityResult.none;
      }
      _updateConnectionStatus(result);
    });
  }

  Future<void> _checkInitialConnection() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    ConnectivityResult result;
    if (connectivityResult is List<ConnectivityResult>) {
      result = connectivityResult.isNotEmpty ? connectivityResult.first : ConnectivityResult.none;
    } else if (connectivityResult is ConnectivityResult) {
      result = connectivityResult as ConnectivityResult;
    } else {
      result = ConnectivityResult.none;
    }

    await _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (result == ConnectivityResult.none) {
      isConnected.value = false;
      return;
    }

    try {
      final lookupResult = await InternetAddress.lookup('example.com');
      if (lookupResult.isNotEmpty && lookupResult[0].rawAddress.isNotEmpty) {
        isConnected.value = true;
      } else {
        isConnected.value = false;
      }
    } on SocketException catch (_) {
      isConnected.value = false;
    }
  }
}
