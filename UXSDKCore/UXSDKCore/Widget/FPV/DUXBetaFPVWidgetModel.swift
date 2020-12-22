//
//  DUXBetaFPVWidgetModel.swift
//  UXSDKCore
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
    
    /// The boolean value controlling the visibility of the gridlines based on camera type.
    dynamic public var canShowGrid: Bool = true
    
    /// The video feed currently displayed in the FPV.
    dynamic public var videoFeed: DJIVideoFeed? {
        didSet {
            updateDisplayedValues()
        }
    }
    
    /// The abstraction that bridges between camera mode and camera flat mode.
    dynamic public var cameraModeModule = DUXBetaFlatCameraModule()
    
    public override init() {
        super.init()
        
        add(cameraModeModule)
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
        guard let displayName4Key = DJICameraKey(index: 4, andParam: DJICameraParamDisplayName) else { return }
        guard let physicalSource = videoFeed?.physicalSource else { return }
        
        let displayName0 = DJISDKManager.keyManager()?.getValueFor(displayName0Key)?.stringValue ?? ""
        let displayName1 = DJISDKManager.keyManager()?.getValueFor(displayName1Key)?.stringValue ?? ""
        let displayName4 = DJISDKManager.keyManager()?.getValueFor(displayName4Key)?.stringValue ?? ""

        computeDisplayedValues(index0Name: displayName0, index1Name: displayName1, index4Name: displayName4, cameraSource: physicalSource)
    }
    
    @objc public func computeDisplayedValues(index0Name displayName0: String, index1Name displayName1: String, index4Name displayName4: String, cameraSource physicalSource: DJIVideoFeedPhysicalSource) {
        canShowGrid = true
        var displayName = displayName0
        var displaySide = DUXBetaFPVWidgetCameraSide.unknown
        
        if ProductUtil.isExtPortSupportedProduct() {
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
                  aircraftModel == DJIAircraftModelNameMatrice210RTKV2 ||
                  aircraftModel == DJIAircraftModelNameMatrice300RTK {
            if physicalSource == .leftCamera {
                displayName = displayName0
                displaySide = .port
            } else if physicalSource == .rightCamera {
                displayName = displayName1
                displaySide = .starboard
            } else if physicalSource == .topCamera {
                displayName = displayName4
                displaySide = .top
            } else if physicalSource == .fpvCamera {
                canShowGrid = false
                displayName = NSLocalizedString("FPV Camera", comment: "FPV Camera")
            } else if physicalSource == .mainCamera {
                displayName = displayName0
            }
        } else if aircraftModel == DJIAircraftModelNameInspire2 ||
                  aircraftModel == DJIAircraftModelNameMatrice200V2 {
            if physicalSource == .mainCamera {
                displayName = displayName0
            } else if physicalSource == .fpvCamera {
                canShowGrid = false
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
    case top = "Top-side"
    case port = "Port-side"
    case starboard = "Starboard-side"
}
