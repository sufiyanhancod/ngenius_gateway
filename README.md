# ngenius

A Flutter plugin for integrating Network International (N-Genius) payment gateway in Flutter applications. This plugin supports both Android and iOS platforms.

## Features

- Seamless integration with N-Genius payment gateway
- Support for both Android and iOS platforms
- Handles card payments
- Customizable payment flow
- Type-safe response handling
- Comprehensive error handling

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```

### Platform Specific Setup

#### Android
No additional setup required.

#### iOS
Add the following to your `ios/Podfile`:

```

### Usage

1. First, import the package:

```dart
import 'package:ngenius/ngenius.dart';
```

2. Initialize the payment service with your credentials:

```dart
final ngenius = Ngenius.instance;
```

3. Create an order and process payment:

create order response is the response from the create order api
and the order payload is the payload that you need to pass to the create order function

```dart
try {
  // Initialize payment
  final result = await ngenius.createOrder(
    orderPayload: <create_order_response>,
  );

  // Handle the payment result
  if (result.success) {
    print('Payment successful: ${result.status}');
    print('Message: ${result.message}');
  } else {
    print('Payment failed: ${result.status}');
    print('Error message: ${result.message}');
  }
} catch (e) {
  print('Error: $e');
}
```

### Payment Result Handling

The plugin returns a `NgeniusPaymentResult` object with the following properties:

```dart
class NgeniusPaymentResult {
  final bool success;      // Whether the payment was successful
  final String status;     // Payment status code
  final String message;    // Human-readable message
  final Map<String, dynamic>? data;  // Additional payment data if available
}
```

Possible status codes:
- `AUTH_SUCCESS`: Payment authorization successful
- `CAPTURE_SUCCESS`: Payment capture successful
- `PURCHASE_SUCCESS`: Purchase successful
- `REVIEW_SUCCESS`: Payment under review
- `FAILED`: Payment failed
- `CANCELLED`: Payment cancelled by user
- `ERROR`: An error occurred during payment

### Example

Here's a complete example of implementing a payment button:

```dart
ElevatedButton(
  onPressed: () async {
    try {
      final result = await Ngenius.instance.createOrder(
        orderPayload: <create_order_response>,
      );

      if (result.success) {
        // Handle successful payment
        print('Payment successful: ${result.status}');
      } else {
        // Handle failed payment
        print('Payment failed: ${result.message}');
      }
    } catch (e) {
      // Handle errors
      print('Error processing payment: $e');
    }
  },
  child: Text('Pay Now'),
),
```

## Error Handling

The plugin provides comprehensive error handling. Here are some common errors you might encounter:

```dart
try {
  // Payment code here
} catch (e) {
  if (e is PlatformException) {
    switch (e.code) {
      case 'PAYMENT_CANCELLED':
        // Handle payment cancellation
        break;
      case 'PAYMENT_FAILED':
        // Handle payment failure
        break;
      case 'INITIALIZATION_ERROR':
        // Handle initialization errors
        break;
      default:
        // Handle other platform-specific errors
    }
  } else {
    // Handle other types of errors
  }
}
```

## Additional Information

- This plugin requires iOS 12.0 or later
- For Android, ensure you have the latest version of the Android SDK
- Test thoroughly in sandbox environment before going live
- Refer to the Network International documentation for API credentials and setup

## Contributing

Contributions are welcome! If you find a bug or want to contribute to the code or documentation, please visit [our GitHub repository](https://github.com/sufiyanhancod/ngenius_gateway).

## License

This project is licensed under the [Hancod] License - see the LICENSE file for details.
```

This README provides comprehensive documentation for your plugin, including:
- Installation instructions
- Platform-specific setup
- Usage examples
- Error handling
- Payment result handling
- Complete implementation example

You should customize the following parts:
1. Update the version number
2. Add your actual GitHub repository URL
3. Specify the license type
4. Add any additional platform-specific requirements
5. Include any other specific features or limitations of your implementation

The documentation follows pub.dev's best practices and provides clear instructions for developers to integrate your plugin into their Flutter applications.