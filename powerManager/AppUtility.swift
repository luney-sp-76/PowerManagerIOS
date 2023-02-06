//
//  AppUtility.swift
//  powerManager
//
//  Credited to https://stackoverflow.com/questions/28938660/how-to-lock-orientation-of-one-view-controller-to-portrait-mode-only-in-swift#41811798
//
import UIKit

struct AppUtility {

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
    
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
   
        self.lockOrientation(orientation)
    
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    ///returns a string that can be checked by string.contains(string)
    static func selectDeviceFromEntityString(entity: String) -> String {
        if !entity.isEmpty{
            let str = entity
            let startIndex = str.index(str.startIndex, offsetBy: 7)
            let endIndex = str.index(str.startIndex, offsetBy: 17)
            let substringEndIndex = min(endIndex, str.endIndex)
            let substring = str[startIndex..<substringEndIndex]
            let substringAsString = String(substring)
            //print(substringAsString)
            return String(substring)
            
        }
        return " "
       
    }

}
