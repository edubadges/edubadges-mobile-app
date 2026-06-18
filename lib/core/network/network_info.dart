import 'package:connectivity_plus/connectivity_plus.dart';

/// Interface for checking network connectivity
abstract class NetworkInfo {
  /// Checks if the device is connected to the internet
  Future<bool> get isConnected;

  /// Stream of connectivity changes
  Stream<bool> get onConnectivityChanged;

  /// Gets the current connectivity status
  Future<List<ConnectivityResult>> get connectivityStatus;
}

/// Implementation of [NetworkInfo] using connectivity_plus package
class NetworkInfoImpl implements NetworkInfo {
  final Connectivity _connectivity;

  NetworkInfoImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(_isConnected);
  }

  @override
  Future<List<ConnectivityResult>> get connectivityStatus {
    return _connectivity.checkConnectivity();
  }

  bool _isConnected(List<ConnectivityResult> result) {
    // If the list contains none, device is not connected
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    // If the list contains any valid connection type, device is connected
    return result.any(
      (element) =>
          element == ConnectivityResult.mobile ||
          element == ConnectivityResult.wifi ||
          element == ConnectivityResult.ethernet ||
          element == ConnectivityResult.vpn,
    );
  }
}
