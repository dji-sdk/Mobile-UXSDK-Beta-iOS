//
//  GlobalPreferencesManager.swift
//  DJIUXSDK
//
//  MIT License
//  
//  Copyright © 2018-2019 DJI
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

@objc(DUXBetaMeasureUnitType) public enum MeasureUnitType: Int {
    case Metric = 1, Imperial = 2, Unknown = 3
}

enum GlobalPreference: RawRepresentable {
    typealias RawValue = String
    
    case MeasureUnitType, AFCEnabled, Unknown
    
    static let Prefix = "DUXBetaGlobalPreference"
    
    var rawValue: GlobalPreference.RawValue {
        switch self {
            case .MeasureUnitType:
                return GlobalPreference.Prefix + "MeasureUnitType"
            case .AFCEnabled:
                return GlobalPreference.Prefix + "AFCEnabled"
            case .Unknown:
                return ""
        }
    }
    
    init?(rawValue: RawValue) {
        switch rawValue {
            case GlobalPreference.Prefix + "MeasureUnitType":
                self = .MeasureUnitType
            case GlobalPreference.Prefix + "AFCEnabled":
                self = .AFCEnabled
            default:
                self = .Unknown
        }
    }
}

// To create a custom storage mechanism, implement this protocol then call setSharedGlobalPreferences:
// on DUXBetaSingleton to replace the default implementation with a custom one
@objc public protocol GlobalPreferences {
    func set(measureUnitType:MeasureUnitType)
    func measureUnitType() -> MeasureUnitType
    
    func set(AFCEnabled:Bool)
    func afcEnabled() -> Bool
}

public class DefaultGlobalPreferences: NSObject, GlobalPreferences {
    var userDefaults:UserDefaults
    
    public init(userDefaults:UserDefaults) {
        self.userDefaults = userDefaults
    }
    
    public override init() {
        self.userDefaults = UserDefaults.standard
    }
    
    public func set(measureUnitType:MeasureUnitType) {
        userDefaults.set(measureUnitType.rawValue,
                         forKey: GlobalPreference.MeasureUnitType.rawValue)
    }
    
    // Returns unknown by default or if value cannot be cast to a known unit type
    public func measureUnitType() -> MeasureUnitType {
        let rawMeasureUnitType = userDefaults.integer(forKey: GlobalPreference.MeasureUnitType.rawValue)
        if let convertedMeasureUnitType = MeasureUnitType(rawValue: rawMeasureUnitType) {
            return convertedMeasureUnitType
        } else {
            return .Unknown
        }
    }
    
    public func set(AFCEnabled:Bool) {
        userDefaults.set(AFCEnabled, forKey: GlobalPreference.AFCEnabled.rawValue)
    }
    
    
    public func afcEnabled() -> Bool {
        return userDefaults.bool(forKey: GlobalPreference.AFCEnabled.rawValue)
    }
}
