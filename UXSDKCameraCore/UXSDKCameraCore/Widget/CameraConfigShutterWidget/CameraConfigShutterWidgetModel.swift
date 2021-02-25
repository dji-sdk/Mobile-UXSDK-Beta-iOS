//
//  CameraConfigShutterWidgetModel.swift
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

import Foundation

/**
 * DUXBetaCameraConfigShutterWidgetModel is used to display the shutter speed. It monitors product connection and shutter speed
 */
@objcMembers public class DUXBetaCameraConfigShutterWidgetModel: DUXBetaBaseWidgetModel {
    /// Public key for binding the shutter speed
    dynamic public var shutterSpeed: DJICameraShutterSpeed = .speedUnknown
    
    /// Standard inSetup method which just binds to DJICameraKey.DJICameraParamShutterSpeed
    override public func inSetup() {
        if let key = DJICameraKey(param: DJICameraParamShutterSpeed) {
            bindSDKKey(key, (\DUXBetaCameraConfigShutterWidgetModel.shutterSpeed).toString)
        }
    }
    
    override public func inCleanup() {
        unbindSDK(self)
        unbindRKVOModel(self)
    }
}
