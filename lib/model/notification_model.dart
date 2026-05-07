class NotificationModel {
  String? id;
  String? userId;
  String? title;
  String? body;
  String? type;
  String? orderId;
  bool? read;
  DateTime? createdAt;

  NotificationModel({
    this.id,
    this.userId,
    this.title,
    this.body,
    this.type,
    this.orderId,
    this.read,
    this.createdAt,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userId = json['userId']?.toString();
    title = json['title']?.toString();
    body = json['body']?.toString();
    type = json['type']?.toString();
    orderId = json['orderId']?.toString();
    read = json['read'] == true;
    createdAt = json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
  }
}