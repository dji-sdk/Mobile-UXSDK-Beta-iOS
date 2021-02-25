//
//  DUXBetaMockDJIFlyZoneInformation.swift
//  UXSDKUnitTests
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

import UIKit
import DJISDK

@objc public class DUXBetaMockDJIFlyZoneInformation: DJIFlyZoneInformation {
    var overridenNameProperty: String?
    
    override public var name: String {
        get {
            return overridenNameProperty!
        }
        set {
            overridenNameProperty = newValue
        }
    }
    
    var overridenTypeProperty: DJIFlyZoneType = .unknown
    
    override public var type: DJIFlyZoneType {
        get {
            return overridenTypeProperty
        }
        set {
            overridenTypeProperty = newValue
        }
    }
    
    var overridenFlyZoneIDProperty: UInt?
    
    override public var flyZoneID: UInt {
        get {
            return overridenFlyZoneIDProperty!
        }
        set {
            overridenFlyZoneIDProperty = newValue
        }
    }
    
    var overridenCategoryProperty: DJIFlyZoneCategory = .unknown
    
    override public var category: DJIFlyZoneCategory {
        get {
            return overridenCategoryProperty
        }
        set {
            overridenCategoryProperty = newValue
        }
    }
    
    var overridenStartTimeProperty: String?
    
    override public var startTime: String {
        get {
            return overridenStartTimeProperty!
        }
        set {
            overridenStartTimeProperty = newValue
        }
    }
    
    var overridenEndTimeProperty: String?
    
    override public var endTime: String {
        get {
            return overridenEndTimeProperty!
        }
        set {
            overridenEndTimeProperty = newValue
        }
    }
    
    var overridenUnlockStartTimeProperty: String = "NoDate"
    
    override public var unlockStartTime: String {
        get {
            return overridenUnlockStartTimeProperty
        }
        set {
            overridenUnlockStartTimeProperty = newValue
        }
    }
    
    var overridenUnlockEndTimeProperty: String = "NoDate"
    
    override public var unlockEndTime: String {
        get {
            return overridenUnlockEndTimeProperty
        }
        set {
            overridenUnlockEndTimeProperty = newValue
        }
    }
}
