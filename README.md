# edubadges

A Flutter application

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
## TODO

### Aroma Error Configuration
If you're using the `aroma_error` package, you need to:
1. Create `lib/core/utils/aroma_error_provider.dart` with an `AromaErrorController` provider
2. Update `lib/core/network/network_providers.dart` to use the error controller:
   - Uncomment the `aromaErrorController` line in `networkConfigProvider`
   - Add the import for `aroma_error_provider.dart`
