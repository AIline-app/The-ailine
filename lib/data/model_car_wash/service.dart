class Service {
  final String title;
  final int price;
  bool isSelected;

  Service({
    required this.title,
    required this.price,
    this.isSelected = false,
  });
}