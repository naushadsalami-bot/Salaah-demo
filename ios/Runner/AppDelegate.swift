import Flutter
 import UIKit
 import Firebase
 import FirebaseMessaging
 import UserNotifications

 @main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
   override func application(
     _ application: UIApplication,
     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
   ) -> Bool {
     //  Firebase configure
     FirebaseApp.configure()

     // iOS Notifications
     UNUserNotificationCenter.current().delegate = self
     application.registerForRemoteNotifications()

     //  FCM delegate
     Messaging.messaging().delegate = self

     GeneratedPluginRegistrant.register(with: self)
     return super.application(application, didFinishLaunchingWithOptions: launchOptions)
   }

   // APNs token Firebase ko dena
   override func application(
     _ application: UIApplication,
     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
   ) {
     Messaging.messaging().apnsToken = deviceToken
   }
 }
