import Flutter
import UIKit
import NISdk

public class NgeniusPlugin: NSObject, FlutterPlugin, CardPaymentDelegate {
    private var viewController: UIViewController? // Store reference to view controller
    private var pendingResult: FlutterResult? // Add this to store the result callback
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ngenius", binaryMessenger: registrar.messenger())
        let instance = NgeniusPlugin()
        
        // Get the root view controller
        if let viewController = UIApplication.shared.keyWindow?.rootViewController {
            instance.viewController = viewController
        }
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // Required CardPaymentDelegate methods
    public func paymentDidComplete(with status: PaymentStatus) {
        switch status {
        case .PaymentSuccess:
            pendingResult?("SUCCESS")
        case .PaymentFailed:
            pendingResult?(FlutterError(code: "PAYMENT_FAILED",
                                      message: "Payment failed",
                                      details: nil))
        case .PaymentCancelled:
            pendingResult?(FlutterError(code: "PAYMENT_CANCELLED",
                                      message: "Payment cancelled",
                                      details: nil))
        @unknown default:
            pendingResult?(FlutterError(code: "UNKNOWN_STATUS",
                                      message: "Unknown payment status",
                                      details: nil))
        }
        pendingResult = nil // Clear the stored result
    }
    
    public func authorizationDidComplete(with status: AuthorizationStatus) {
        switch status {
        case .AuthSuccess:
            // Wait for paymentDidComplete
            break
        case .AuthFailed:
            pendingResult?(FlutterError(code: "AUTH_FAILED",
                                      message: "Authorization failed",
                                      details: nil))
            pendingResult = nil
        @unknown default:
            pendingResult?(FlutterError(code: "UNKNOWN_AUTH_STATUS",
                                      message: "Unknown authorization status",
                                      details: nil))
            pendingResult = nil
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "showCardPaymentUI":
            if pendingResult != nil {
                result(FlutterError(code: "ALREADY_IN_PROGRESS",
                                  message: "Payment UI is already being shown",
                                  details: nil))
                return
            }
            
            if let args = call.arguments as? [String: Any],
               let jsonString = args["response"] as? String,
               let jsonData = jsonString.data(using: .utf8) {
                do {
                    let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: jsonData)
                    pendingResult = result // Store the result callback
                    showCardPaymentUI(orderResponse: orderResponse)
                } catch {
                    result(FlutterError(code: "DECODE_ERROR",
                                      message: "Failed to decode order response: \(error.localizedDescription)",
                                      details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                  message: "Invalid or missing response argument",
                                  details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func showCardPaymentUI(orderResponse: OrderResponse) {
        guard let viewController = self.viewController else {
            print("Error: View controller not available")
            return
        }
        
        let sharedSDKInstance = NISdk.sharedInstance
        sharedSDKInstance.showCardPaymentViewWith(
            cardPaymentDelegate: self,
            overParent: viewController,
            for: orderResponse
        )
    }
}
