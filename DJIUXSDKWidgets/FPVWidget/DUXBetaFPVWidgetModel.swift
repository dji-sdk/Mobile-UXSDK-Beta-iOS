//
//  DUXBetaFPVWidgetModel.swift
//  DJIUXSDKWidgets
//
//  MIT License
//  
//  Copyright © 2018-2020 DJI
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
import DJISDK

/**
 * Data model for the DUXBetaFPVWidgetModel used to define
 * the underlying logic and communication.
*/
@objcMembers public class DUXBetaFPVWidgetModel: DUXBetaBaseWidgetModel {
    
    /// The camera name displayed in the fpv widget.
    dynamic public var displayedCameraName: String = ""
    
    /// The camera side displayed in the fpv widget.
    dynamic public var displayedCameraSide: String?
    
    /// The current camera index displayed in the fpv widget.
    dynamic public var preferredCameraIndex = 0 {
        didSet {
            cleanup()
            setup()
            updateBandwidthSettings()
        }
    }
    
    /// The model name of the aircraft.
    dynamic public var aircraftModel: String?
    
    /// The camera name value needed to compute the displayed camera name.
    dynamic public var cameraName: String = ""
    
    /// The camera mode value needed to compute the displayed camera side.
    dynamic public var cameraMode: DJICameraMode = .unknown
    
    /// The camera photo aspect ratio needed to compute the gridline frame.
    dynamic public var photoAspectRatio: DJICameraPhotoAspectRatio = .ratioUnknown
    
    /// The video resolution and frame information needed to compute the gridline frame.
    dynamic public var videoResolutionAndFrameRate: DJICameraVideoResolutionAndFrameRate?
    
    /// The percentage allocation for left camera needed to compute the current camera index.
    dynamic public var bandwidthAllocationForLeftCamera: CGFloat = 0.0
    
    /// The index of the current camera.
    dynamic public var currentCameraIndex: DUXBetaFPVWidgetCameraIndex = .unknown
    
    /// The frame used to draw the gridlines.
    dynamic public var gridFrame: CGRect = .zero
    
    /// The frame needed to compute the gridline frame.
    dynamic public var containerFrame =  CGRect.zero {
        didSet {
            updateDrawingRect()
        }
    }
    
    /// The video feed currently displayed in the FPV.
    dynamic public var videoFeed: DJIVideoFeed? {
        didSet {
            updateDisplayedValues()
        }
    }
    
    override public func inSetup() {
        if let key = DJIProductKey(param: DJIProductParamModelName) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.aircraftModel).toString)
        }
        if let key = DJICameraKey(index: preferredCameraIndex, andParam: DJICameraParamDisplayName) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.cameraName).toString)
        }
        if let key = DJIAirLinkKey(index: 0,
                                   subComponent: DJIAirLinkLightbridgeLinkSubComponent,
                                   subComponentIndex: 0,
                                   andParam: DJILightbridgeLinkParamBandwidthAllocationForLeftCamera) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.bandwidthAllocationForLeftCamera).toString)
        }
        if let key = DJICameraKey(index: preferredCameraIndex, andParam: DJICameraParamMode) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.cameraMode).toString)
        }
        if let key = DJICameraKey(index: preferredCameraIndex, andParam: DJICameraParamPhotoAspectRatio) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.photoAspectRatio).toString)
        }
        if let key = DJICameraKey(index: preferredCameraIndex, andParam: DJICameraParamVideoResolutionAndFrameRate) {
            bindSDKKey(key, (\DUXBetaFPVWidgetModel.videoResolutionAndFrameRate).toString)
        }
        
        bindRKVOModel(self, #selector(updateDisplayedValues), (\DUXBetaFPVWidgetModel.aircraftModel).toString)
        bindRKVOModel(self, #selector(updateCurrentCameraIndex), (\DUXBetaFPVWidgetModel.cameraName).toString)
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
    
    @objc public func updateDisplayedValues() {
        guard let displayName0Key = DJICameraKey(index: 0, andParam: DJICameraParamDisplayName) else { return }
        guard let displayName1Key = DJICameraKey(index: 1, andParam: DJICameraParamDisplayName) else { return }
        
        let displayName0 = DJISDKManager.keyManager()?.getValueFor(displayName0Key)?.stringValue ?? ""
        let displayName1 = DJISDKManager.keyManager()?.getValueFor(displayName1Key)?.stringValue ?? ""
        
        
        var displayName = displayName0
        var displaySide = DUXBetaFPVWidgetCameraSide.unknown
        
        guard let physicalSource = videoFeed?.physicalSource else { return }
        
        if aircraftModel == DJIAircraftModelNameA3 ||
           aircraftModel == DJIAircraftModelNameN3 ||
           aircraftModel == DJIAircraftModelNameMatrice600 ||
           aircraftModel == DJIAircraftModelNameMatrice600Pro {
            if physicalSource == .mainCamera {
                displayName = displayName0
            } else if physicalSource == .EXT {
                displayName = "\(DJIVideoFeedPhysicalSource.EXT)"
            } else if physicalSource == .HDMI {
                displayName = "\(DJIVideoFeedPhysicalSource.HDMI)"
            } else if physicalSource == .AV {
                displayName = "\(DJIVideoFeedPhysicalSource.AV)"
            }
        } else if aircraftModel == DJIAircraftModelNameMatrice210 ||
                  aircraftModel == DJIAircraftModelNameMatrice210RTK ||
                  aircraftModel == DJIAircraftModelNameMatrice210V2 ||
                  aircraftModel == DJIAircraftModelNameMatrice210RTKV2 {
            if physicalSource == .leftCamera {
                displayName = displayName0
                displaySide = .port
            } else if physicalSource == .rightCamera {
                displayName = displayName1
                displaySide = .starboard
            } else if physicalSource == .fpvCamera {
                displayName = NSLocalizedString("FPV Camera", comment: "FPV Camera")
            } else if physicalSource == .mainCamera {
                displayName = displayName0
            }
        } else if aircraftModel == DJIAircraftModelNameInspire2 ||
                  aircraftModel == DJIAircraftModelNameMatrice200V2 {
            if physicalSource == .mainCamera {
                displayName = displayName0
            } else if physicalSource == .fpvCamera {
                displayName = NSLocalizedString("FPV Camera", comment: "FPV Camera")
            }
        }
        displayName = displayName.replacingOccurrences(of: "-Visual", with: "")
        
        displayedCameraName = displayName
        displayedCameraSide = displaySide.rawValue
    }
    
    @objc public func updateCurrentCameraIndex() {
        if let product = DJISDKManager.product() as? DJIAircraft, let count = product.cameras?.count, count > 1 {
            if bandwidthAllocationForLeftCamera > 0.05 {
                if videoFeed == DJISDKManager.videoFeeder()?.primaryVideoFeed {
                    currentCameraIndex = .index_0
                } else {
                    currentCameraIndex = .index_1
                }
            } else {
                if cameraName == DJICameraDisplayNameMavic2EnterpriseDualVisual {
                    currentCameraIndex = .index_0
                } else if cameraName == DJICameraDisplayNameMavic2EnterpriseDualThermal {
                    currentCameraIndex = .index_2
                } else if videoFeed == DJISDKManager.videoFeeder()?.primaryVideoFeed {
                    currentCameraIndex = .index_1
                } else {
                    currentCameraIndex = .index_0
                }
            }
        } else if let physicalSource = videoFeed?.physicalSource, physicalSource != .fpvCamera {
            currentCameraIndex = .index_0
        } else {
            currentCameraIndex = .unknown
        }
    }
    
    @objc func updateDrawingRect() {
        var drawingRect = CGRect.zero
        
        switch cameraMode {
        case .shootPhoto:
            drawingRect = drawingRectForPhotoMode()
        case .recordVideo:
            drawingRect = drawingRectForVideoMode(withResolution: videoResolutionAndFrameRate?.resolution)
        case .broadcast:
            drawingRect = drawingRectForBroadcastMode()
        default:
            break
        }

        gridFrame = drawingRect
    }
    
    public func drawingRectForPhotoMode() -> CGRect {
        switch photoAspectRatio {
        case .ratio4_3:
            return adjustedWidth(withRatio: 4.0/3.0)
        case .ratio3_2:
            let ratio: CGFloat = 2.0/3.0
            let height = containerFrame.width * ratio
            if containerFrame.height > height {
                return adjustedHeight(withRatio: ratio)
            } else {
                return adjustedWidth(withRatio: 3.0/2.0)
            }
        case .ratio16_9:
            return adjustedWidth(withRatio: 16.0/9.0)
        default:
            return CGRect.zero
        }
    }
    
    public func drawingRectForVideoMode(withResolution resolution: DJICameraVideoResolution?) -> CGRect {
        guard let videoResolution = resolution else {
            return CGRect.zero
        }
        
        switch videoResolution {
        case .resolution640x512:
            return adjustedHeight(withRatio: 512.0/640.0)
        case .resolution640x480:
            return adjustedHeight(withRatio: 480.0/640.0)
        case .resolution1280x720:
            fallthrough
        case .resolution1920x1080:
            fallthrough
        case .resolution2704x1520:
            fallthrough
        case .resolution2720x1530:
            fallthrough
        case .resolution2688x1512:
            fallthrough
        case .resolution3840x2160:
            fallthrough
        case .resolution4608x2592:
            fallthrough
        case .resolution5280x2972:
            fallthrough
        case .resolution5760x3240:
            fallthrough
        case .resolutionMax:
            let ratio: CGFloat = 16.0/9.0
            let width = containerFrame.height * ratio
            if width < containerFrame.width {
                return adjustedWidth(withRatio: ratio)
            } else {
                return adjustedHeight(withRatio: 9.0/16.0)
            }
        case .resolution2048x1080:
            return adjustedHeight(withRatio: 1080.0/2048.0)
        case .resolution4096x2160:
            return adjustedHeight(withRatio: 9.0/16.0)
        case .resolution3840x1572:
            fallthrough
        case .resolution5280x2160:
            return adjustedHeight(withRatio: 1572.0/3840.0)
        case .resolution4608x2160:
            return adjustedHeight(withRatio: 2160.0/4608.0)
        case .resolution6016x3200:
            return adjustedHeight(withRatio: 3200.0/6016.0)
        default:
            return CGRect.zero
        }
    }
    
    public func drawingRectForBroadcastMode() -> CGRect {
        return adjustedHeight(withRatio: 9.0/16.0)
    }
    
    public func adjustedWidth(withRatio ratio: CGFloat) -> CGRect {
        let adjustedWidth = containerFrame.height * ratio
        let widthOffset = (containerFrame.width - adjustedWidth)/2
        return CGRect(x: widthOffset, y: 0, width: adjustedWidth, height: containerFrame.height)
    }
    
    public func adjustedHeight(withRatio ratio: CGFloat) -> CGRect {
        let adjustedHeight = containerFrame.width * ratio
        let heightOffset = (containerFrame.height - adjustedHeight)/2
        return CGRect(x: 0, y: heightOffset, width: containerFrame.width, height: adjustedHeight)
    }
    
    fileprivate func updateBandwidthSettings() {
        if let productName = DJISDKManager.product()?.model, productName == DJIAircraftModelNameMatrice210 || productName == DJIAircraftModelNameMatrice210RTK {
            guard let bandwidthAllocationForLeftCameraKey = DJIAirLinkKey(index: 0,
                                                                          subComponent: DJIAirLinkLightbridgeLinkSubComponent,
                                                                          subComponentIndex: 0,
                                                                          andParam: DJILightbridgeLinkParamBandwidthAllocationForLeftCamera) else { return }
            
            let leftCameraBandwidthValue = preferredCameraIndex == 0 ? 1 : 0
            DJISDKManager.keyManager()?.setValue(NSNumber(value: leftCameraBandwidthValue), for: bandwidthAllocationForLeftCameraKey, withCompletion: { (error) in
                if let err = error {
                    print(err.localizedDescription)
                }
            })
            
            guard let bandwidthAllocationForMainCameraKey = DJIAirLinkKey(index: 0,
                                                                          subComponent: DJIAirLinkLightbridgeLinkSubComponent,
                                                                          subComponentIndex: 0,
                                                                          andParam: DJILightbridgeLinkParamBandwidthAllocationForMainCamera) else { return }
            DJISDKManager.keyManager()?.setValue(NSNumber(value: 0.5), for: bandwidthAllocationForMainCameraKey, withCompletion: { (error) in
                if let err = error {
                    print(err.localizedDescription)
                }
            })
        }
    }
}

@objc public enum DUXBetaFPVWidgetCameraIndex: NSInteger {
    case unknown = -1
    case index_0
    case index_1
    case index_2
}

enum DUXBetaFPVWidgetCameraSide: String {
    case unknown = ""
    case port = "Port-side"
    case starboard = "Starboard-side"
}
