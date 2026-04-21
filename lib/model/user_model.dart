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

  Data({
    this.user,
    this.accessToken,
    this.expiresIn,
    this.requiresRegistrationCompletion,
  });

  Data.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    accessToken = json['accessToken'];
    expiresIn = json['expiresIn'];
    requiresRegistrationCompletion = json['requiresRegistrationCompletion'];
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

  // NEW FIELDS
  bool? isOtonavRecommended;
  bool? isActive;
  num? averageRating;
  JobAnalytics? jobAnalytics;
  List<Map<String, dynamic>>? organizations;

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
    this.averageRating,
    this.isOtonavRecommended,
    this.jobAnalytics,
    this.organizations,
    this.isActive,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    name = json['name'];
    role = json['role'];
    orgId = json['orgId'];
    emailVerified = json['emailVerified'];
    registrationCompleted =
        json['registrationCompleted'] ??
        json['isProfileComplete'];
    phoneNumber = json['phoneNumber'];
    createdAt = json['createdAt'];
    currentLocation = json['currentLocation'];
    isOtonavRecommended = json['isOtonavRecommended'];
    averageRating = json['averageRating'];
    isActive = json['isActive'] ?? '';

    if (json['jobAnalytics'] != null) {
      jobAnalytics = JobAnalytics.fromJson(json['jobAnalytics']);
    }

    if (json['locations'] != null) {
      locations = <LocationModel>[];
      json['locations'].forEach((v) {
        locations!.add(LocationModel.fromJson(v));
      });
    }

    if (json['organizations'] != null) {
      organizations = <Map<String, dynamic>>[];
      json['organizations'].forEach((v) {
        organizations!.add(v);
      });
    }
  }

  String get primaryOrgName {
    if (organizations != null && organizations!.isNotEmpty) {
      String firstOrg = organizations![0]['name'] ?? "Independent Rider";
      if (organizations!.length > 1) {
        return "$firstOrg (+${organizations!.length - 1} more)";
      }
      return firstOrg;
    }
    return "Independent Rider";
  }



}


class DailyBreakdown {
  DateTime? date;
  int orders;
  int completed;
  int cancelled;

  DailyBreakdown.fromJson(Map<String, dynamic> json)
      : date = json['date'] != null ? DateTime.tryParse(json['date']) : null,
        orders = json['orders'] ?? 0,
        completed = json['completed'] ?? 0,
        cancelled = json['cancelled'] ?? 0;
}

class RecentOrder {
  String? id;
  String? orderNumber;
  String? status;
  DateTime? createdAt;
  String? packageDescription;

  RecentOrder.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        orderNumber = json['orderNumber'],
        status = json['status'],
        packageDescription = json['packageDescription'],
        createdAt = json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null;
}

class JobAnalytics {
  Map<String, dynamic> summary;
  List<RecentOrder> recentOrders;
  List<DailyBreakdown> dailyBreakdown;
  num averageRecentRating;
  num performanceScore;

  JobAnalytics.fromJson(Map<String, dynamic> json)
      : summary = json['summary'] ?? {},
        averageRecentRating = json['averageRecentRating'] ?? 0,
        performanceScore = json['performanceScore'] ?? 0,
        recentOrders = (json['recentOrders'] as List<dynamic>?)
            ?.map((e) => RecentOrder.fromJson(e))
            .toList() ?? [],
        dailyBreakdown = (json['dailyBreakdown'] as List<dynamic>?)
            ?.map((e) => DailyBreakdown.fromJson(e))
            .toList() ?? [];
}