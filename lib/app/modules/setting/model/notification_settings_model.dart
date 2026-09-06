class NotificationSettingsModel {
  final int? id;
  final String? user;
  final bool generalNotifications;
  final bool sound;
  final bool doNotDisturb;
  final bool vibrate;
  final bool lockScreen;
  final String? createdAt;
  final String? updatedAt;

  NotificationSettingsModel({
    this.id,
    this.user,
    this.generalNotifications = true,
    this.sound = true,
    this.doNotDisturb = false,
    this.vibrate = true,
    this.lockScreen = true,
    this.createdAt,
    this.updatedAt,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'] as int?,
      user: json['user'] as String?,
      generalNotifications: json['general_notifications'] == true,
      sound: json['sound'] == true,
      doNotDisturb: json['do_not_disturb'] == true,
      vibrate: json['vibrate'] == true,
      lockScreen: json['lock_screen'] == true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'general_notifications': generalNotifications,
      'sound': sound,
      'do_not_disturb': doNotDisturb,
      'vibrate': vibrate,
      'lock_screen': lockScreen,
    };
  }

  NotificationSettingsModel copyWith({
    int? id,
    String? user,
    bool? generalNotifications,
    bool? sound,
    bool? doNotDisturb,
    bool? vibrate,
    bool? lockScreen,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationSettingsModel(
      id: id ?? this.id,
      user: user ?? this.user,
      generalNotifications: generalNotifications ?? this.generalNotifications,
      sound: sound ?? this.sound,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
      vibrate: vibrate ?? this.vibrate,
      lockScreen: lockScreen ?? this.lockScreen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
