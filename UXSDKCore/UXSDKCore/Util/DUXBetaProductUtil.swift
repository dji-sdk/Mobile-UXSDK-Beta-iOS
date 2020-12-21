//
//  ProductUtil.swift
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/**
 * Utility class for prduct information.
 */
@objcMembers public class ProductUtil: NSObject {
    
    /**
     * Determine whether a product is connected.
     */
    public static func isProductAvailable() -> Bool {
        return DJISDKManager.product() != nil
    }
    
    /**
     * Determine whether the connected product is a Mavic Mini.
     *
     * - Returns: `true` if the connected product is a Mavic Mini. `false` if the
     * connected product is not a Mavic Mini.
     */
    public static func isMavicMini() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMavicMini
    }
    
    /**
     * Determine whether the connected product is part of the Mavic 2 series.
     *
     * - Returns: `true` if the connected product is part of the Mavic 2 series. `false` if the
     * connected product is not part of the Mavic 2 series.
     */
    public static func isMavic2Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMavic2
                || model == DJIAircraftModelNameMavic2Pro
                || model == DJIAircraftModelNameMavic2Zoom
                || model == DJIAircraftModelNameMavic2Enterprise
                || model == DJIAircraftModelNameMavic2EnterpriseDual
    }
    
    /**
     * Determine whether the connected product has a Hasselblad camera.
     *
     * - Returns: `true` if the connected product has a Hasselblad camera. `false` if there is
     * no product connected or if the connected product does not have a Hasselblad camera.
     */
    public static func isHasselbladCamera() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMavic2Pro
    }
    
    /**
     * Determine whether the connected product is a Mavic 2 Enterprise Series.
     *
     * - Returns: `true` if the connected product is a Mavic 2 Enterprise. `false` if the connected
     * product is not a Mavic 2 Enterprise or if there is no product connected.
     */
    public static func isMavic2EnterpriseSeries() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMavic2Enterprise
                || model == DJIAircraftModelNameMavic2EnterpriseDual
    }
    
    /**
     * Determine whether the connected product product is a Matrice 600.
     *
     * - Returns: `true` if the connected product is a Matrice 600. `false` if the connected
     * product is not a Matrice 600 or if there is no product connected.
     */
    public static func isMatrice600Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMatrice600
                || model == DJIAircraftModelNameMatrice600Pro
    }
    
    /**
     * Determine whether the connected product is part of the Matrice 200 series.
     *
     * - Returns: `true` if the connected product is part of the Matrice 200 series. `false` if the connected
     * product is not part of the Matrice 200 series or if there is no product connected.
     */
    public static func isMatrice200Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMatrice200
                || model == DJIAircraftModelNameMatrice210
                || model == DJIAircraftModelNameMatrice210RTK
                || model == DJIAircraftModelNameMatrice200V2
                || model == DJIAircraftModelNameMatrice210V2
                || model == DJIAircraftModelNameMatrice210RTKV2
                || model == DJIAircraftModelNameMatrice300RTK
    }
    
    /**
     * Determine whether the connected product is part of the Phantom 3 series.
     *
     * - Returns: `true` if the connected product is part of the Phantom 3 series. `false` if the connected
     * product is not part of the Phantom 3 series or if there is no product connected.
     */
    public static func isPhantom3Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return  model == DJIAircraftModelNamePhantom3Standard
                || model == DJIAircraftModelNamePhantom3Advanced
                || model == DJIAircraftModelNamePhantom3Professional
    }
    
    /**
     * Determine whether the connected product is part of the Inspire 1 series.
     *
     * - Returns: `true` if the connected product is part of the Phantom 3 series. `false` if the connected
     * product is not part of the Inspire 1 series or if there is no product connected.
     */
    public static func isInspire1Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameInspire1
                || model == DJIAircraftModelNameInspire1Pro
                || model == DJIAircraftModelNameInspire1RAW
    }
    
    /**
     * Determine whether the connected product is part of the Phantom 4 series.
     *
     * - Returns: `true` if the connected product is part of the Phantom 4 series. `false` if the connected
     * product is not part of the Phantom 4 series or if there is no product connected.
     */
    public static func isPhantom4Series() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNamePhantom4
                || model == DJIAircraftModelNamePhantom4Advanced
                || model == DJIAircraftModelNamePhantom4Pro
                || model == DJIAircraftModelNamePhantom4ProV2
                || model == DJIAircraftModelNamePhantom4RTK
                || model == DJIAircraftModelNameP4Multispectral
    }
    
    /**
     * Determine whether the connected product supports external video input.
     *
     * - Returns: `true` if the connected product supports external video input. `false` if there is
     * no product connected or if the connected product does not support external video input.
     */
    public static func isExtPortSupportedProduct() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMatrice600
                || model == DJIAircraftModelNameMatrice600Pro
                || model == DJIAircraftModelNameA3
                || model == DJIAircraftModelNameN3
    }

    /**
     * Determine whether the connected product has vision sensors.
     *
     * - Returns: `true` if the connected product has vision sensors. `false` if there is
     * no product connected or the connected product does not have vision sensors.
     */
    public static func isVisionSupportedProduct() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return !isMatrice600Series()
                && !isPhantom3Series()
                && !isInspire1Series()
                && !isMavicMini()
                && model != DJIAircraftModelNameMatrice100
    }
    
    /**
     * Determine whether the connected product has support for APAS (Advanced Pilot Assistance Support).
     *
     * - Returns: `true` if the connected product supports APAS. `false` if there is
     * no product connected or if the connected product does not support APAS.
     */
    public static func isAPASSupportedProduct() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMavic2
                || model == DJIAircraftModelNameMavic2Pro
                || model == DJIAircraftModelNameMavic2Zoom
                || model == DJIAircraftModelNameMavicAir
    }
    
    /**
     * Determine whether the connected product has support for RTK.
     *
     * - Returns: `true` if the connected product supports RTK. `false` if there is
     * no product connected or if the connected product does not support RTK.
     */
    public static func isRTKSupportedProduct() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNamePhantom4RTK
                || model == DJIAircraftModelNameMatrice210RTK
                || model == DJIAircraftModelNameMatrice210RTKV2
                || model == DJIAircraftModelNameMatrice300RTK
    }
    
    /**
     * Determine whether the connected product has support for Color WaveForm.
     *
     * - Returns: `true` if the connected product supports Color WaveForm. `false` if there is
     * no product connected or if the connected product does not support Color WaveForm.
     */
    public static func isColorWaveFormSupportedProduct() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }
        
        return model == DJIAircraftModelNameMatrice200
                || model == DJIAircraftModelNameMatrice210
                || model == DJIAircraftModelNameMatrice210RTK
                || model == DJIAircraftModelNameInspire2
    }
    
    /**
     * Determine whether the connected product is connected by WiFi only without an RC.
     *
     * - Returns: `true` if the product is connected by WiFi. `false` otherwise.
     */
    public static func isProductWiFiConnected() -> Bool {
        guard isProductAvailable() else {
            return false
        }
        
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            return aircraft.remoteController == nil
        }
        
        return false
    }
    
    /**
     * Some product models have controllers which have different remote control low battery warning battery threshholds
     * from the majority of the controllers. This method tests for those models.
     *
     * - Returns: 'true' if the connected product has a remote controller with a lower battery warning threshhold
     *             than standard controllers.
     */
    public static func productHasSpecialLowRCBatteryThreshold() -> Bool {
        guard let model = DJISDKManager.product()?.model else {
            return false
        }

        return model == DJIAircraftModelNameMavicPro
            || model == DJIAircraftModelNameMavic2
            || model == DJIAircraftModelNameMavic2Enterprise
    }
}
