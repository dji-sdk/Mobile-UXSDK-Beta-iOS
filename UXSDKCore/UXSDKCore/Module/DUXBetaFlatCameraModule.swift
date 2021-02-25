//
//  DUXBetaFlatCameraModule.swift
//  UXSDKCore
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

import Foundation

/**
 * Abstraction for getting and setting camera mode and photo mode.
 */
@objcMembers public class DUXBetaFlatCameraModule: DUXBetaBaseModule {
    /// The computed camera mode.
    dynamic public var currentCameraMode: DJICameraMode = .unknown
    /// The computed camera shoot mode.
    dynamic public var currentShootPhotoMode: DJICameraShootPhotoMode = .unknown
    
    /// The camera mode.
    dynamic public var cameraMode: DJICameraMode = .unknown
    /// The camera flat mode.
    dynamic public var flatMode: DJIFlatCameraMode = .unknown
    /// Boolean value indicating if camera flat mode is supported.
    dynamic public var isFlatModeSupported: Bool = false
    /// The camera shoot mode.
    dynamic public var shootPhotoMode: DJICameraShootPhotoMode = .unknown
    /// Index of the camera the widget model is communicating with
    dynamic public var cameraIndex: Int = 0 {
        willSet {
            cleanup()
        }
        didSet {
            setup()
        }
    }
    
    fileprivate var flatModeKey: DJICameraKey?
    fileprivate var cameraModeKey: DJICameraKey?
    fileprivate var shootPhotoModeKey: DJICameraKey?
    fileprivate var isFlatModeSupportedKey: DJICameraKey?
    
    /**
     * Implementation of the setup method that binds the necessary keys.
     */
    public override func setup() {
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamMode) {
            cameraModeKey = key
            bindSDKKey(key, (\DUXBetaFlatCameraModule.cameraMode).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamShootPhotoMode) {
            shootPhotoModeKey = key
            bindSDKKey(key, (\DUXBetaFlatCameraModule.shootPhotoMode).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamFlatMode) {
            flatModeKey = key
            bindSDKKey(key, (\DUXBetaFlatCameraModule.flatMode).toString)
        }
        if let key = DJICameraKey(index: cameraIndex, andParam: DJICameraParamIsFlatModeSupported) {
            isFlatModeSupportedKey = key
            bindSDKKey(key, (\DUXBetaFlatCameraModule.isFlatModeSupported).toString)
        }
        
        bindRKVOModel(self, #selector(updateCameraMode),
                      (\DUXBetaFlatCameraModule.flatMode).toString,
                      (\DUXBetaFlatCameraModule.cameraMode).toString,
                      (\DUXBetaFlatCameraModule.isFlatModeSupported).toString)
        
        bindRKVOModel(self, #selector(updateShootPhotoMode),
                      (\DUXBetaFlatCameraModule.flatMode).toString,
                      (\DUXBetaFlatCameraModule.shootPhotoMode).toString,
                      (\DUXBetaFlatCameraModule.isFlatModeSupported).toString)
    }
    
    /**
    * Implementation of the cleanup method that removes the key bindings.
    */
    public override func cleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    /**
     * Set photo mode.
     *
     * - Parameters:
     *      - shootPhotoMode: Camera shoot photo mode.
     *      - completion: Completion block called when performing a set on a key.
     */
    public func setPhotoMode(shootPhotoMode: DJICameraShootPhotoMode, withCompletion completion: @escaping DJIKeyedSetCompletionBlock) {
        guard let flatModeKey = flatModeKey else { return }
        guard let cameraModeKey = cameraModeKey else { return }
        
        if isFlatModeSupported {
            DJISDKManager.keyManager()?.setValue(NSNumber(value: shootPhotoMode.flatMode.rawValue),
                                                 for: flatModeKey,
                                                 withCompletion: completion)
        } else {
            DJISDKManager.keyManager()?.setValue(NSNumber(value: shootPhotoMode.rawValue),
                                                 for: cameraModeKey,
                                                 withCompletion: completion)
        }
    }
    
    /**
     * Set camera mode.
     *
     * - Parameters:
     *      - cameraMode: Camera mode.
     *      - completion: Completion block called when performing a set on a key.
     */
    public func setCameraMode(cameraMode: DJICameraMode, withCompletion completion: @escaping DJIKeyedSetCompletionBlock) {
        guard let flatModeKey = flatModeKey else { return }
        guard let cameraModeKey = cameraModeKey else { return }
        
        if isFlatModeSupported {
            if cameraMode == .shootPhoto {
                DJISDKManager.keyManager()?.setValue(NSNumber(value: DJIFlatCameraMode.photoSingle.rawValue),
                                                     for: flatModeKey,
                                                     withCompletion: completion)
            } else {
                DJISDKManager.keyManager()?.setValue(NSNumber(value: DJIFlatCameraMode.videoNormal.rawValue),
                                                     for: flatModeKey,
                                                     withCompletion: completion)
            }
        } else {
            DJISDKManager.keyManager()?.setValue(NSNumber(value: cameraMode.rawValue), for: cameraModeKey, withCompletion: completion)
        }
    }
    
    @objc func updateCameraMode() {
        if isFlatModeSupported {
            currentCameraMode = flatMode.isPictureMode ? .shootPhoto : .recordVideo
        } else {
            currentCameraMode = cameraMode
        }
    }
    
    @objc func updateShootPhotoMode() {
        if isFlatModeSupported {
            currentShootPhotoMode = flatMode.photoShootMode
        } else {
            currentShootPhotoMode = shootPhotoMode
        }
    }
}

/**
 * Extension that bridges DJIFlatCameraMode to DJICameraShootPhotoMode
 */
public extension DJIFlatCameraMode {
    
    var isPictureMode: Bool {
        return
            self == .photoTimeLapse ||
            self == .photoAEB ||
            self == .photoSingle ||
            self == .photoBurst ||
            self == .photoHDR ||
            self == .photoInterval ||
            self == .photoHyperLight ||
            self == .photoEHDR
    }
    
    var photoShootMode: DJICameraShootPhotoMode {
        switch self {
        case .photoSingle:
            return DJICameraShootPhotoMode.single
        case .photoHDR:
            return DJICameraShootPhotoMode.HDR
        case .photoBurst:
            return DJICameraShootPhotoMode.burst
        case .photoAEB:
            return DJICameraShootPhotoMode.AEB
        case .photoInterval:
            return DJICameraShootPhotoMode.interval
        case .photoPanorama:
            return DJICameraShootPhotoMode.panorama
        case .photoEHDR:
            return DJICameraShootPhotoMode.EHDR
        case .photoHyperLight:
            return DJICameraShootPhotoMode.hyperLight
        default:
            return DJICameraShootPhotoMode.unknown
        }
    }
}

/**
 * Extension that bridges DJICameraShootPhotoMode to DJIFlatCameraMode
 */
public extension DJICameraShootPhotoMode {
    
    var flatMode: DJIFlatCameraMode {
        switch self {
        case .single:
            return DJIFlatCameraMode.photoSingle
        case .HDR:
            return DJIFlatCameraMode.photoHDR
        case .burst:
            return DJIFlatCameraMode.photoBurst
        case .AEB:
            return DJIFlatCameraMode.photoAEB
        case .interval:
            return DJIFlatCameraMode.photoInterval
        case .panorama:
            return DJIFlatCameraMode.photoPanorama
        case .EHDR:
            return DJIFlatCameraMode.photoEHDR
        case .hyperLight:
            return DJIFlatCameraMode.photoHyperLight
        default:
            return DJIFlatCameraMode.unknown
        }
    }
}
