import '../model/user_model.dart';

class OrderModel {
  String? id;
  String? orderNumber;
  String? orgId;
  String? packageDescription;
  String? customerId;
  String? riderId;
  String? riderCurrentLocation;
  String? customerLocationLabel;
  String? customerLocationPrecise;
  String? status;

  // Dates
  String? assignedAt;
  String? riderAcceptedAt;
  String? customerLocationSetAt;
  String? deliveredAt;
  String? cancelledAt;
  String? createdAt;
  String? updatedAt;

  // Nested Objects
  OrderUser? customer;
  OrderUser? rider;

  OrderModel({
    this.id,
    this.orderNumber,
    this.orgId,
    this.packageDescription,
    this.customerId,
    this.riderId,
    this.riderCurrentLocation,
    this.customerLocationLabel,
    this.customerLocationPrecise,
    this.status,
    this.assignedAt,
    this.riderAcceptedAt,
    this.customerLocationSetAt,
    this.deliveredAt,
    this.cancelledAt,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.rider,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['orderNumber'];
    orgId = json['orgId'];
    packageDescription = json['packageDescription'];
    customerId = json['customerId'];
    riderId = json['riderId'];
    riderCurrentLocation = json['riderCurrentLocation'];
    customerLocationLabel = json['customerLocationLabel'];
    customerLocationPrecise = json['customerLocationPrecise'];
    status = json['status'];

    // Dates
    assignedAt = json['assignedAt'];
    riderAcceptedAt = json['riderAcceptedAt'];
    customerLocationSetAt = json['customerLocationSetAt'];
    deliveredAt = json['deliveredAt'];
    cancelledAt = json['cancelledAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    // Parse Nested Objects
    customer = json['customer'] != null ? OrderUser.fromJson(json['customer']) : null;
    rider = json['rider'] != null ? OrderUser.fromJson(json['rider']) : null;
  }
}

class OrderUser {
  String? id;
  String? email;
  String? name;
  String? phoneNumber;
  String? currentLocation;
  List<LocationModel>? locations; // Reusing your existing LocationModel

  OrderUser({
    this.id,
    this.email,
    this.name,
    this.phoneNumber,
    this.currentLocation,
    this.locations,
  });

  OrderUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    currentLocation = json['currentLocation'];

    if (json['locations'] != null) {
      locations = <LocationModel>[];
      json['locations'].forEach((v) {
        locations!.add(LocationModel.fromJson(v));
      });
    }
  }
}