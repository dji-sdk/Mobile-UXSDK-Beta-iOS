//
//  UIDevice+DUXBetaHelper.swift
//  UXSDKCore
//
//  MIT License
//
//  Copyright © 2018-2020 DJI
//
//  Permission is hereby granted free of charge to any person obtaining a copy
//  of this software and associated documentation files (the "Software") to deal
//  in the Software without restriction including without limitation the rights
//  to use copy modify merge publish distribute sublicense and/or sell
//  copies of the Software and to permit persons to whom the Software is
//  furnished to do so subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND EXPRESS OR
//  IMPLIED INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM DAMAGES OR OTHER
//  LIABILITY WHETHER IN AN ACTION OF CONTRACT TORT OR OTHERWISE ARISING FROM
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit

@objc public enum DUXBetaDeviceScreenType: Int {
    case Unknown = 0
    case resolution_480x320     //iphone3gs,iphone4s,iphone4
    case resolution_568x320     //iphone5,iphone5s,iphoneSE
    case resolution_667x375     //iphone6,iphone6se
    case resolution_736x414     //iphone6s
    case resolution_1024x768    //ipad1,2,ipad mini,ipad3,4,air ipad mini retina
    case resolution_812x375     //iphoneX iphoneXs
    case resolution_896x414     //iphoneXR iphone Xs Max
    case resolution_1080x810    //ipad 7th
    case resolution_1180x820    //ipad Air 4th
    case resolution_1112x834    //ipad air 3, ipad pro 10.5
    case resolution_1366x1024   //ipad pro, ipad pro 12.9
    case resolution_834x1194    //ipad pro 11
}

@objc public extension UIDevice {
    
    static var duxbeta_systemVersion: Float = -1
    static var duxbeta_screenType = DUXBetaDeviceScreenType.Unknown
    
    @objc static var duxbeta_isLandscape: Bool {
        return UIApplication.shared.statusBarOrientation == .landscapeRight || UIApplication.shared.statusBarOrientation == .landscapeLeft
    }
    
    @objc static var duxbeta_currentSystemVersion: Float {
        if UIDevice.duxbeta_systemVersion < 0, let version = Float(UIDevice.current.systemVersion) {
            UIDevice.duxbeta_systemVersion = version
        }
        return UIDevice.duxbeta_systemVersion
    }
    
    @objc static var duxbeta_currentScreenType: DUXBetaDeviceScreenType {
        if UIDevice.duxbeta_screenType == .Unknown {
            let screenBounds = UIScreen.main.bounds
            
            if screenBounds.height*320 == screenBounds.width*480 || screenBounds.width*320 == screenBounds.height*480 {
                UIDevice.duxbeta_screenType = .resolution_480x320
            } else if screenBounds.height*320 == screenBounds.width*568 || screenBounds.width*320 == screenBounds.height*568 {
                UIDevice.duxbeta_screenType = .resolution_568x320
            } else if screenBounds.height*667 == screenBounds.width*375 || screenBounds.width*667 == screenBounds.height*375 {
                UIDevice.duxbeta_screenType = .resolution_667x375
            } else if screenBounds.height*736 == screenBounds.width*414 || screenBounds.width*736 == screenBounds.height*414 {
                UIDevice.duxbeta_screenType = .resolution_736x414
            } else if screenBounds.height*812 == screenBounds.width*375 || screenBounds.width*812 == screenBounds.height*375 {
                UIDevice.duxbeta_screenType = .resolution_812x375
            } else if screenBounds.height*896 == screenBounds.width*414 || screenBounds.width*896 == screenBounds.height*414 {
                UIDevice.duxbeta_screenType = .resolution_896x414
            } else if screenBounds.height*768 == screenBounds.width*1024 || screenBounds.width*768 == screenBounds.height*1024 {
                UIDevice.duxbeta_screenType = .resolution_1024x768
            } else if screenBounds.height*1080 == screenBounds.width*810 || screenBounds.width*1080 == screenBounds.height*810 {
                UIDevice.duxbeta_screenType = .resolution_1080x810
            } else if screenBounds.height*1180 == screenBounds.width*820 || screenBounds.width*1180 == screenBounds.height*820 {
                UIDevice.duxbeta_screenType = .resolution_1180x820
            } else if screenBounds.height*1112 == screenBounds.width*834 || screenBounds.width*1112 == screenBounds.height*834 {
                UIDevice.duxbeta_screenType = .resolution_1112x834
            } else if screenBounds.height*1366 == screenBounds.width*1024 || screenBounds.width*1366 == screenBounds.height*1024 {
                UIDevice.duxbeta_screenType = .resolution_1366x1024
            } else if screenBounds.height*834 == screenBounds.width*1194 || screenBounds.width*834 == screenBounds.height*1194 {
                UIDevice.duxbeta_screenType = .resolution_834x1194
            }
        }
        
        return UIDevice.duxbeta_screenType
    }
    
    @objc static var duxbeta_isiPad: Bool {
        let screenType = UIDevice.duxbeta_currentScreenType
        return screenType == .resolution_1080x810 || screenType == .resolution_1180x820 || screenType == .resolution_1024x768 || screenType == .resolution_1024x768 || screenType == .resolution_1112x834 || screenType == .resolution_1366x1024 || screenType == .resolution_834x1194
    }
    
    @objc static var duxbeta_isiPhone4: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_480x320
    }
    
    @objc static var duxbeta_isiPhone5: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_568x320
    }
    
    @objc static var duxbeta_isiPhone6: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_667x375
    }
    
    @objc static var duxbeta_isiPhone6Plus: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_736x414
    }
    
    @objc static var duxbeta_isiPhoneXOrigin: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_812x375
    }
    
    @objc static var duxbeta_isiPhoneXR: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_896x414 && UIScreen.main.scale == 2
    }
    
    @objc static var duxbeta_isiPhoneXMax: Bool {
        return UIDevice.duxbeta_currentScreenType == .resolution_896x414 && UIScreen.main.scale == 3
    }
    
    @objc static var duxbeta_isiPhoneX: Bool {
        return UIDevice.duxbeta_isiPhoneXOrigin || UIDevice.duxbeta_isiPhoneXR || UIDevice.duxbeta_isiPhoneXMax
    }
    
    @objc static func duxbeta_autoiPhoneXScale(offset: CGFloat) -> CGFloat {
        return UIDevice.duxbeta_isiPhoneXR || UIDevice.duxbeta_isiPhoneXMax ? floor(896.0/812.0 * offset) : offset
    }
    
    @objc static var duxbeta_logicWidthPotrait: CGFloat {
        if UIDevice.duxbeta_isiPad { return 768 }
        if UIDevice.duxbeta_isiPhone5 { return 320 }
        if UIDevice.duxbeta_isiPhone6 { return 375 }
        if UIDevice.duxbeta_isiPhoneX {
            if UIDevice.duxbeta_isiPhoneXR || UIDevice.duxbeta_isiPhoneXMax { return 414 }
            else { return 375 }
        }
        return 414
    }
    
    @objc static var duxbeta_logicHeightPotrait: CGFloat {
        if UIDevice.duxbeta_isiPad { return 1024 }
        if UIDevice.duxbeta_isiPhone5 { return 568 }
        if UIDevice.duxbeta_isiPhone6 { return 667 }
        if UIDevice.duxbeta_isiPhoneX {
            if UIDevice.duxbeta_isiPhoneXR || UIDevice.duxbeta_isiPhoneXMax { return 896 }
            else { return 812 }
        }
        return 736
    }
    
    @objc static var duxbeta_logicHeightLandscape: CGFloat {
        return UIDevice.duxbeta_logicWidthPotrait
    }
    
    @objc static var duxbeta_logicWidthLandscape: CGFloat {
        return UIDevice.duxbeta_logicHeightPotrait
    }
    
    @objc static var duxbeta_widthScale: CGFloat {
        if UIDevice.duxbeta_isiPad { return 0.4 }
        if UIDevice.duxbeta_isiPhone5 { return 0.7 }
        if UIDevice.duxbeta_isiPhone6 { return 0.6 }

        return 0.6
    }
}
