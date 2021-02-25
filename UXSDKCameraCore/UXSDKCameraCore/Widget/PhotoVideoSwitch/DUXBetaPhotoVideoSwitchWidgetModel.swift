//
//  DUXBetaPhotoVideoSwitchWidgetModel.swift
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2021 DJI
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

import UXSDKCore


/**
 * Enum representing the state of the DUXBetaPhotoVideoSwitchWidgetModel.
 */
@objc public enum DUXBetaPhotoVideoSwitchState: UInt {
    /**
     * Product is currently disconnected.
     */
    case ProductDisconnected
    
    /**
     * Camera is currently disconnected.
     */
    case CameraDisconnected
    
    /**
     * Camera cannot toggle between photo/video modes.
     */
    case Disabled
    
    /**
     * Camera is in shoot photo mode mode.
     */
    case PhotoMode
    
    /**
     * Camera is in record video mode.
     */
    case VideoMode
    
}

/**
 * Data model for the DUXBetaPhotoVideoSwitchWidget used to define
 * the underlying logic and communication.
*/
@objcMembers public class DUXBetaPhotoVideoSwitchWidgetModel: DUXBetaBaseWidgetModel {
    
    // MARK: - Public Properties
    
    /// The state of the DUXBetaPhotoVideoSwitchWidgetModel.
    dynamic public var state: DUXBetaPhotoVideoSwitchState = .ProductDisconnected
    /// Index of the camera the widget model is communicating with
    dynamic public var cameraIndex: Int = 0 {
        willSet {
            inCleanup()
        }
        didSet {
            cameraModeModule.cameraIndex = cameraIndex
            inSetup()
        }
    }
    
    /// The abstraction that bridges between camera mode and camera flat mode.
    dynamic public var cameraModeModule = DUXBetaFlatCameraModule()
    
    // MARK: - Module Properties
    
    /// Variable that indicates if the camera is connected.
    var isCameraConnected: Bool = false
    /// Variable that indicates if the camera is currently recording.
    var isRecording: Bool = false
    /// Variable that indicates if the camera is in single photo mode.
    var isShootingSinglePhoto: Bool = false
    /// Variable that indicates if the camera is in interval photo mode.
    var isShootingIntervalPhoto: Bool = false
    /// Variable that indicates if the camera is in panorama photo mode.
    var isShootingPanoramaPhoto: Bool = false
    /// Variable that indicates if the camera is in burst photo mode.
    var isShootingBurstPhoto: Bool = false
    /// Variable that indicates if the camera is in RAW burst photo mode.
    var isShootingRAWBurstPhoto: Bool = false
    
    // MARK: - Private Properties
    
    fileprivate var enabled: Bool {
        return isProductConnected &&
                isCameraConnected &&
                !isRecording &&
                !isShootingSinglePhoto &&
                !isShootingIntervalPhoto &&
                !isShootingBurstPhoto &&
                !isShootingRAWBurstPhoto &&
                !isShootingPanoramaPhoto
    }
    
    // MARK: - Public Methods
    
    public override init() {
        super.init()
        
        add(cameraModeModule)
    }
    
    /**
     * Override of parent inSetup method that binds properties to keys
     * and attaches method callbacks on properties updates.
     */
    override public func inSetup() {
        if let key = DJICameraKey(index: cameraIndex, andParam: DJIParamConnection) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isCameraConnected).toString)
        }
        
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsRecording) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isRecording).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsShootingSinglePhoto) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isShootingSinglePhoto).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsShootingIntervalPhoto) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isShootingIntervalPhoto).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsShootingBurstPhoto) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isShootingBurstPhoto).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsShootingRAWBurstPhoto) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isShootingRAWBurstPhoto).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsShootingPanoramaPhoto) {
            bindSDKKey(key, (\DUXBetaPhotoVideoSwitchWidgetModel.isShootingPanoramaPhoto).toString)
        }
        
        bindRKVOModel(self, #selector(updateState),
                      (\DUXBetaPhotoVideoSwitchWidgetModel.isProductConnected).toString,
                      (\DUXBetaPhotoVideoSwitchWidgetModel.isCameraConnected).toString,
                      (\DUXBetaPhotoVideoSwitchWidgetModel.cameraModeModule.flatMode).toString,
                      (\DUXBetaPhotoVideoSwitchWidgetModel.cameraModeModule.cameraMode).toString,
                      (\DUXBetaPhotoVideoSwitchWidgetModel.cameraModeModule.isFlatModeSupported).toString)
    }
    
    /**
     * Override of parent inCleanup method that unbinds properties from keys
     * and detaches methods callbacks.
    */
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    /// Method that switches between photo mode and video mode
    /// - Parameter completion: Completion block called when set mode is done.
    public func toggleCameraMode(withCompletion completion: @escaping DJIKeyedSetCompletionBlock) {
        if cameraModeModule.cameraMode == .shootPhoto {
            cameraModeModule.setCameraMode(cameraMode: .recordVideo, withCompletion: completion)
        } else {
            cameraModeModule.setCameraMode(cameraMode: .shootPhoto, withCompletion: completion)
        }
    }

    // MARK: - Private Methods

    func updateState() {
        var nextState: DUXBetaPhotoVideoSwitchState = .ProductDisconnected
        
        if isProductConnected {
            if enabled {
                if cameraModeModule.cameraMode == .shootPhoto {
                    nextState = .PhotoMode
                } else {
                    nextState = .VideoMode
                }
            } else if !isCameraConnected {
                nextState = .CameraDisconnected
            } else {
                nextState = .Disabled
            }
        }
        
        state = nextState
    }
}
