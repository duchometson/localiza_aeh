import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

import 'package:rxdart/rxdart.dart';


class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<ReceiveNotification> didReceivedLocalNotificationSuvjest = BehaviorSubject<ReceiveNotification>();
  InitializationSettings initializationsSettings;
  NotificationService._() {
    init();
  }

  init() async {
    if(Platform.isIOS) {
      _requestIOSPermission();
    }
  }
  initializePlatformSpecifics() {
    AndroidInitializationSettings initializeSettingsAndroid = AndroidInitializationSettings("notif_icon");
    IOSInitializationSettings initializeSettingIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (id,title,body,payload) async{
        ReceiveNotification receiveNotification = ReceiveNotification(id: id, title: title, body: body, payload: payload);
        didReceivedLocalNotificationSuvjest.add(receiveNotification);
      }
    );

    initializationsSettings = InitializationSettings(initializeSettingsAndroid, initializeSettingIOS);
  }
  _requestIOSPermission() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        .requestPermissions(
          alert: true,
          badge: true,
          sound: true,
    );
  }

  setOnNotification(Function onNotificationClick) async {
    await flutterLocalNotificationsPlugin.initialize(initializationsSettings,
        onSelectNotification: (String payload) async {
      onNotificationClick(payload);
        });
  }

  setListenersForLowerVersions(Function onNotification ) {
    didReceivedLocalNotificationSuvjest.listen((receiveNotification) {
      onNotification(receiveNotification);
    });
  }

  Future<void> scheduleNotification() async {
    //var scheduleNotification = DateTime.now().duration

    AndroidNotificationDetails androidChannelSpecifics = AndroidNotificationDetails(
        "CHANNEL_ID", "AvisoEncomenda", "CHANNEL_DESCRIPTION", importance: Importance.Max, priority: Priority.High);

    IOSNotificationDetails iosChannelsSpecifics = IOSNotificationDetails();

    NotificationDetails plataformChannelSpecifics = NotificationDetails( androidChannelSpecifics, iosChannelsSpecifics);

    await flutterLocalNotificationsPlugin.show(1, "Localiza Aeh", "Atualização de Encomenda!", plataformChannelSpecifics, payload: "test payload");
  }

  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

}

NotificationService notificationService = NotificationService._();

class ReceiveNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceiveNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload});
}