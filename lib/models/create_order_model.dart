class CreateOrderModel {
  final String orderId;
  final String orderAmount;
  final String orderCurrency;

  CreateOrderModel({
    required this.orderId,
    required this.orderAmount,
    required this.orderCurrency,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'orderAmount': orderAmount,
        'orderCurrency': orderCurrency,
      };
}
