class LoginResponse {
  bool? success;
  String? message;
  Data? data;

  LoginResponse({this.success, this.message, this.data});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class RegisterResponse {
  bool? success;
  String? message;
  Data? data;

  RegisterResponse({this.success, this.message, this.data});

  RegisterResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }
}

class Data {
  User? user;
  String? accessToken;
  int? expiresIn;
  bool? requiresRegistrationCompletion;

  Data({this.user, this.accessToken, this.expiresIn, this.requiresRegistrationCompletion});

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    accessToken = json['accessToken'];
    expiresIn = json['expiresIn'];
    requiresRegistrationCompletion = json['requiresRegistrationCompletion'];
  }
}

class User {
  String? id;
  String? email;
  String? name;
  String? role;
  String? phoneNumber;
  String? orgId;
  bool? emailVerified;
  bool? registrationCompleted;
  String? createdAt;
  List<LocationModel>? locations;
  String? currentLocation;

  User({
    this.id,
    this.email,
    this.name,
    this.role,
    this.orgId,
    this.emailVerified,
    this.registrationCompleted,
    this.phoneNumber,
    this.createdAt,
    this.locations,
    this.currentLocation,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    orgId = json['orgId'];
    emailVerified = json['emailVerified'];
    registrationCompleted = json['registrationCompleted'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    if (json['locations'] != null) {
      locations = <LocationModel>[];
      json['locations'].forEach((v) {
        locations!.add(LocationModel.fromJson(v));
      });
    }
  }
}

class LocationModel {
  String? label;
  String? preciseLocation;

  LocationModel({this.label, this.preciseLocation});

  LocationModel.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    preciseLocation = json['preciseLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['preciseLocation'] = preciseLocation;
    return data;
  }
}