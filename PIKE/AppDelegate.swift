//
//  AppDelegate.swift
//
//  Created by Devin Lee on 12/23/16.
//  Copyright © 2016 Devin Lee. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.registerForRemoteNotifications()
        
        if #available(iOS 10.0, *){
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
                
                if granted {
                } else {
                }
            })
        } else { /* For older systems */
            let notificationSettings = UIUserNotificationSettings(
                types: [.badge, .sound, .alert], categories: nil)
            application.registerUserNotificationSettings(notificationSettings)
        }
        FirebaseApp.configure()

        return true
    }
   
    func resetBadge () {
        let badgeReset = CKModifyBadgeOperation(badgeValue: 0)
        badgeReset.modifyBadgeCompletionBlock = { (error) -> Void in
            if error == nil {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(badgeReset)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        resetBadge()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        DispatchQueue.main.async { () -> Void in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "performReload"), object: nil)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        resetBadge()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String:NSObject])
        
        if cloudKitNotification.notificationType == CKNotificationType.query {
            DispatchQueue.main.async( execute: { () -> Void in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "performReload"), object: nil)
            })
        }
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

