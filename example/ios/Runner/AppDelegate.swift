import Flutter
import UIKit
import NISdk

@main
@objc class AppDelegate: FlutterAppDelegate,CardPaymentDelegate {
 var resultA: FlutterResult?
 var orderCAllData: OrderResponse?
   func paymentDidComplete(with status: PaymentStatus) {
      if(status == .PaymentSuccess) {
        // Payment was successful
      } else if(status == .PaymentFailed) {
         // Payment failed
      } else if(status == .PaymentCancelled) {
        // Payment was cancelled by user
      }
    }

    func authorizationDidComplete(with status: AuthorizationStatus) {
      if(status == .AuthFailed) {
        // Authentication failed
        return
      }
      // Authentication was successful
    }

   func showCardPaymentUI(orderResponse: OrderResponse) {
       let sharedSDKInstance = NISdk.sharedInstance
       if let rootViewController = self.window?.rootViewController {
           sharedSDKInstance.showCardPaymentViewWith(
               cardPaymentDelegate: self,
               overParent: rootViewController,
               for: orderResponse
           )
       } else {
           // Handle the case where `rootViewController` is nil
           print("Error: Root view controller is nil")
       }
   }

 override func application(
   _ application: UIApplication,
   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
 ) -> Bool {
   GeneratedPluginRegistrant.register(with: self)
     let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
             let videoChatChannel = FlutterMethodChannel(name: "com.stl.flutchat/opentok",
                                                         binaryMessenger: controller as! FlutterBinaryMessenger)

             videoChatChannel.setMethodCallHandler({
                 [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
                 self?.resultA = result
                 var text = ""
                 if let args = call.arguments as? [String : Any]
                 {
                   text = args["url"] as! String
                 }
                 switch call.method {
                 case "openVideoChat":
                     // Example JSON data (as Data)
                     let jsonData = """
                     {
                         "_id": "12345",
                         "type": "order",
                         "action": "create",
                         "amount": null,
                         "formattedAmount": "$10.00",
                         "language": "en",
                         "merchantAttributes": {"key": "value"},
                         "emailAddress": "example@example.com",
                         "reference": "order123",
                         "outletId": "67890"
                         "createDateTime": "2024-12-31T12:00:00Z",
                         "referrer": "web",
                         "orderSummary": null,
                         "formattedOrderSummary": null,
                         "billingAddress": null,
                         "paymentMethods": null,
                         "orderLinks": null,
                         "embeddedData": null,
                         "savedCard": null
                     }

                     """.data(using: .utf8)!
                     do {
                         // Decode JSON data into an OrderResponse instance
                         let orderData = try JSONDecoder().decode(OrderResponse.self, from: jsonData)
                         print("Order Response: \(orderData)")
                         self?.showCardPaymentUI(orderResponse:orderData)
                     } catch {
                         print("Failed to decode OrderResponse: \(error)")
                     }
                     //self?.showCardPaymentUI(orderResponse: self?.orderCAllData ?? OrderResponse())
                  //self?.resultA!(text)
                   // print(123)
                   //   let alert = UIAlertController(title: "My Title", message: "My Message", preferredStyle: .alert)

 

                   //   let actionYes = UIAlertAction(title: "Yes", style: .default, handler: { action in

                   //       print("action yes handler")

                   //   })

 

                   //   let actionCancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { action in

                   //       print("action cancel handler")

                   //   })

 

                   //   alert.addAction(actionYes)

                   //   alert.addAction(actionCancel)

 

                   //   DispatchQueue.main.async {

                   //       self?.window?.rootViewController?.present(alert, animated: true, completion: nil)

                   //   }
                 default:
                     result(FlutterMethodNotImplemented)

                 }
             })
   return super.application(application, didFinishLaunchingWithOptions: launchOptions)

 }

}

 

 