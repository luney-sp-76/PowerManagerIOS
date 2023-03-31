//
//  AppUtility.swift
//  powerManager
//
//  Credited to https://stackoverflow.com/questions/28938660/how-to-lock-orientation-of-one-view-controller-to-portrait-mode-only-in-swift#41811798
//
import UIKit
import Foundation

struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {

        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation

        }
    }

//    static func lockOrientation(_ orientation: UIInterfaceOrientationMask){
//        if let delegate = UIApplication.shared.delegate as? AppDelegate {
//            delegate.orientationLock = UIInterfaceOrientationMask(rawValue: orientation.rawValue)
//        }
//    }
   /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {

        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
//    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
//
//        self.lockOrientation(orientation)
//
//        UIDevice.current.setValue(NSNumber(integerLiteral: rotateOrientation.rawValue), forKey: "orientation")
//        UINavigationController.attemptRotationToDeviceOrientation()
//    }
    
    ///returns a string that can be checked by string.contains(string)
    static func selectDeviceFromEntityString(entity: String) -> String {
        if !entity.isEmpty{
            let str = entity
            print(str)
            let startIndex = str.index(str.startIndex, offsetBy: 7)
            let endIndex = str.index(str.startIndex, offsetBy: 15)
            let substringEndIndex = min(endIndex, str.endIndex)
            let substring = str[startIndex..<substringEndIndex]
            //let substringAsString = String(substring)
            //print(substringAsString)
            return String(substring)
            
        }
        return " "
       
    }
    
    ///func checks the length of a string is between the maximum and minimum lengths requested if it is too short the function adds spaces at the start and end to bring it up to the maximum length
    static func shortenString(string: String, maxLength: Int, minLength: Int) -> String {
        if string.count <= maxLength && string.count >= minLength {
            return string
        }
            
        let index = string.index(string.startIndex, offsetBy: maxLength)
        let substring = string[..<index]
        let nextSpaceIndex = substring.lastIndex(of: " ")
        let finalString = string[..<nextSpaceIndex!]
            
        let numberOfSpaces = maxLength - finalString.count
        let leftSpaces = Array(repeating: " ", count: numberOfSpaces / 2).joined()
        let rightSpaces = Array(repeating: " ", count: (numberOfSpaces + 1) / 2).joined()
            
        return leftSpaces + finalString + rightSpaces
    }
    ///update when the target is iOS 16 or above for [Orientation] BUG IN CLIENT OF UIKIT: Setting UIDevice.orientation is not supported. Please use UIWindowScene.requestGeometryUpdate(_:)
//    static func changeOrientation(to orientation: UIInterfaceOrientation) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//
//        var transform = CGAffineTransform.identity
//
//        switch orientation {
//            case .portrait:
//                transform = CGAffineTransform(rotationAngle: .pi / 2)
//            case .landscapeLeft:
//                transform = CGAffineTransform(rotationAngle: .pi)
//            case .landscapeRight:
//                transform = CGAffineTransform(rotationAngle: 0)
//            default:
//                break
//        }
//
//        let geometryPreferences = UIWindowScene.GeometryPreferences(
//            bounds: windowScene.screen.bounds,
//            transform: transform
//        )
//
//        windowScene.requestGeometryUpdate(geometryPreferences)
//    }


}
