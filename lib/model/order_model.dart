import '../model/user_model.dart';

class OrderModel {
  String? id;
  String? orderNumber;
  String? orgId;
  String? packageDescription;
  String? customerId;
  String? riderId;
  dynamic riderCurrentLocation;
  double? riderCurrentLat;
  double? riderCurrentLng;
  String? customerLocationLabel;
  double? customerLocationLat;
  double? customerLocationLng;
  String? status;
  String? deliveryPin;

  // Dates
  String? assignedAt;
  String? riderAcceptedAt;
  String? customerLocationSetAt;
  String? packagePickedUpAt; // New
  String? deliveryStartedAt; // New
  String? arrivedAtLocationAt; // New
  String? deliveredAt;
  String? cancelledAt;
  String? createdAt;
  String? updatedAt;

  // Cancellation Details
  String? cancelledBy; // New
  String? cancellationReason; // New

  // Nested Objects
  OrderUser? customer;
  OrderUser? rider;
  OrganizationModel? organization; // New

  OrderModel({
    this.id,
    this.orderNumber,
    this.orgId,
    this.packageDescription,
    this.customerId,
    this.riderId,
    this.riderCurrentLocation,
    this.riderCurrentLat,
    this.riderCurrentLng,
    this.customerLocationLabel,
    this.customerLocationLat,
    this.customerLocationLng,
    this.status,
    this.deliveryPin,
    this.assignedAt,
    this.riderAcceptedAt,
    this.customerLocationSetAt,
    this.packagePickedUpAt,
    this.deliveryStartedAt,
    this.arrivedAtLocationAt,
    this.deliveredAt,
    this.cancelledAt,
    this.cancelledBy,
    this.cancellationReason,
    this.createdAt,
    this.updatedAt,
    this.customer,
    this.rider,
    this.organization,
  });

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    orderNumber = json['orderNumber'];
    orgId = json['orgId'];
    packageDescription = json['packageDescription'];
    customerId = json['customerId'];
    riderId = json['riderId'];
    riderCurrentLocation = json['riderCurrentLocation'];
    riderCurrentLat = _parseDouble(json['riderCurrentLat']);
    riderCurrentLng = _parseDouble(json['riderCurrentLng']);
    customerLocationLabel = json['customerLocationLabel'];
    customerLocationLat = _parseDouble(json['customerLocationLat']);
    customerLocationLng = _parseDouble(json['customerLocationLng']);
    status = json['status'];
    deliveryPin = json['deliveryPin']?.toString();
    // Dates
    assignedAt = json['assignedAt'];
    riderAcceptedAt = json['riderAcceptedAt'];
    customerLocationSetAt = json['customerLocationSetAt'];
    packagePickedUpAt = json['packagePickedUpAt'];
    deliveryStartedAt = json['deliveryStartedAt'];
    arrivedAtLocationAt = json['arrivedAtLocationAt'];
    deliveredAt = json['deliveredAt'];
    cancelledAt = json['cancelledAt'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

    // Cancellation
    cancelledBy = json['cancelledBy'];
    cancellationReason = json['cancellationReason'];

    // Parse Nested Objects
    customer = json['customer'] != null
        ? OrderUser.fromJson(json['customer'])
        : null;
    rider = json['rider'] != null ? OrderUser.fromJson(json['rider']) : null;
    organization = json['organization'] != null
        ? OrganizationModel.fromJson(json['organization'])
        : null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}

class OrderUser {
  String? id;
  String? email;
  String? name;
  String? phoneNumber;
  String? currentLocation;
  bool? isActive; // New field for riders
  List<LocationModel>? locations;

  OrderUser({
    this.id,
    this.email,
    this.name,
    this.phoneNumber,
    this.currentLocation,
    this.isActive,
    this.locations,
  });

  OrderUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    currentLocation = json['currentLocation'];
    isActive = json['isActive'];

    if (json['locations'] != null) {
      locations = <LocationModel>[];
      json['locations'].forEach((v) {
        locations!.add(LocationModel.fromJson(v));
      });
    }
  }
}

class OrganizationModel {
  String? id;
  String? name;
  String? address;
  OwnerModel? owner;

  OrganizationModel({this.id, this.name, this.address, this.owner});

  OrganizationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    owner = json['owner'] != null ? OwnerModel.fromJson(json['owner']) : null;
  }
}

class OwnerModel {
  String? id;
  String? name;
  String? email;

  OwnerModel({this.id, this.name, this.email});

  OwnerModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }
}

class WaitlistModel {
  String? id;
  String? status;
  DateTime? expiresAt;
  DateTime? createdAt;
  OrderModel? order;

  WaitlistModel({
    this.id,
    this.status,
    this.expiresAt,
    this.createdAt,
    this.order,
  });

  WaitlistModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    status = json['status']?.toString();
    expiresAt = json['expiresAt'] != null
        ? DateTime.tryParse(json['expiresAt'])
        : null;
    createdAt = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'])
        : null;

    if (json['order'] != null) {
      // ✅ THE FIX: Merge the root-level organization and customer into the order JSON
      // so OrderModel can parse them properly!
      Map<String, dynamic> orderJson = Map<String, dynamic>.from(json['order']);
      orderJson['organization'] = json['organization'];
      orderJson['customer'] = json['customer'];

      order = OrderModel.fromJson(orderJson);
    } else {
      order = OrderModel.fromJson(json);
    }
  }
}
