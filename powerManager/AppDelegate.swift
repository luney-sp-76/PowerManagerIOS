//
//  AppDelegate.swift
//  powerManager
//
//  Created by Paul on 29/12/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //    let window = UIWindow?
    //    private let server: Server =
    //
    var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
     
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.shouldToolbarUsesTextFieldTintColor = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
       
       
        let db = Firestore.firestore()
        
        print(db)
        
        return true
        //        let feedVC =  (window.rootViewController as?
        //            UINavigationController)?.viewControllers.first as? ViewController
        //            feedVC?.server = server
        //        }
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.powerManger.refresh", using: nil) { task in
//            self.handleAppRefresh(task: task as! BGAppRefreshTask)
//        }
    }
    
    
    //    func applicationDidEnterBackground(_ application: UIApplication) {
    //        scheduleAppRefresh()
    //    }
    //
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.powerManager.refresh")
//        request.earliestBeginDate = Date(timeIntervalSinceNow:  15 * 60)
//        do {
//            try BGTaskScheduler.shared.submit(request)
//
//        } catch {
//            print("Could not schedule app refresh: \(error)")
//        }
//    }
    
//    // Fetch latest feed data from HomeAssistant
//    func handleAppRefresh(task: BGAppRefreshTask) {
//        // Schedule a new refresh task.
//        scheduleAppRefresh()
//
//        // Create an operation that performs the main part of the background task.
//        let operation = RefreshAppContentsOperation()
//
//        // Provide the background task with an expiration handler that cancels the operation.
//        task.expirationHandler = {
//            operation.cancel()
//        }
//
//        // Inform the system that the background task is complete
//        // when the operation completes.
//        operation.completionBlock = {
//            task.setTaskCompleted(success: !operation.isCancelled)
//        }
//
//        // Start the operation.
//        operationQueue.addOperation(operation)
//    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
}

