class NotificationManage {
  // Private constructor
  NotificationManage._privateConstructor();

  // Single instance
  static final NotificationManage _instance = NotificationManage._privateConstructor();

  // Factory constructor
  factory NotificationManage() {
    return _instance;
  }

  bool _notiValue = true;

  bool get getnotiValue => _notiValue;

  set setnotiValue(bool value) {
    _notiValue = value;
  }
}
