//
//  GlobalPreferencesManager.swift
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

@objc(DUXBetaMeasureUnitType) public enum MeasureUnitType: Int {
    case None = 0, Metric, Imperial, Unknown
    
    init(_ unitTypeParameter: UnitTypeParameter) {
        switch unitTypeParameter {
        case .Metric:
            self = .Metric
        case .Imperial:
            self = .Imperial
        default:
            self = .Unknown
        }
    }
}

@objc(DUXBetaFPVCenterViewType) public enum FPVCenterViewType: Int {
    case None = 0, Standard, Cross, NarrowCross, Frame, FrameAndCross, Square, SquareAndCross, Unknown
}

@objc(DUXBetaFPVCenterViewColor) public enum FPVCenterViewColor: Int {
    case None = 0, White, Yellow, Red, Green, Blue, Black, Unknown
}

@objc(DUXBetaFPVGridViewType) public enum FPVGridViewType: Int {
    case None = 0, Parallel, ParallelDiagonal, Unknown
}

enum GlobalPreference: RawRepresentable {
    typealias RawValue = String

    case MeasureUnitType, AFCEnabled, FPVCenterViewType, FPVCenterViewColor, FPVGridViewType, Unknown
    
    static let Prefix = "DUXBetaGlobalPreference"
    
    var rawValue: GlobalPreference.RawValue {
        switch self {
            case .MeasureUnitType:
                return GlobalPreference.Prefix + "MeasureUnitType"
            case .AFCEnabled:
                return GlobalPreference.Prefix + "AFCEnabled"
            case .FPVCenterViewType:
                return GlobalPreference.Prefix + "FPVCenterViewType"
            case .FPVCenterViewColor:
                return GlobalPreference.Prefix + "FPVCenterViewColor"
            case .FPVGridViewType:
                return GlobalPreference.Prefix + "FPVGridViewType"
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
            case GlobalPreference.Prefix + "FPVCenterViewType":
                self = .FPVCenterViewType
            case GlobalPreference.Prefix + "FPVCenterViewColor":
                self = .FPVCenterViewColor
            case GlobalPreference.Prefix + "FPVGridViewType":
                self = .FPVGridViewType
            default:
                self = .Unknown
        }
    }
}

// To create a custom storage mechanism, implement this protocol then call setSharedGlobalPreferences:
// on DUXBetaSingleton to replace the default implementation with a custom one
@objc public protocol GlobalPreferences {
    /// Dynamic value for KVO of the measurementUnitType
    dynamic var measurementUnitType: MeasureUnitType { get set }
    
    func set(AFCEnabled:Bool)
    func afcEnabled() -> Bool
    
    func set(centerViewType: FPVCenterViewType)
    func centerViewType() -> FPVCenterViewType
    
    func set(centerViewColor: FPVCenterViewColor)
    func centerViewColor() -> FPVCenterViewColor

    func set(gridViewType: FPVGridViewType)
    func gridViewType() -> FPVGridViewType
    
    func set(value: NSValue, forKey: String)
    func value(forKey key: String) -> Any?

    func set(_ value: Bool, forKey defaultName: String)
    func bool(forKey key: String) -> Bool
}

@objcMembers open class DefaultGlobalPreferences: NSObject, GlobalPreferences {
    var userDefaults:UserDefaults
    
    /// public KVO compatible measuementunit. On set, will update the global setting also.
    dynamic public var measurementUnitType: MeasureUnitType =  .Unknown {
        willSet {
            userDefaults.set(newValue.rawValue, forKey: GlobalPreference.MeasureUnitType.rawValue)
        }
    }
    public init(userDefaults:UserDefaults) {
        self.userDefaults = userDefaults
        super.init()
        measurementUnitType = initMeasurementUnitType()
        
    }
    
    public override init() {
        self.userDefaults = UserDefaults.standard
        super.init()
        measurementUnitType = initMeasurementUnitType()
    }
        
    /// Init method for measurementUnitType which is loaded from defaults when the preferences are created.
    public func initMeasurementUnitType() -> MeasureUnitType {
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
    
    public func set(centerViewType: FPVCenterViewType) {
        userDefaults.set(centerViewType.rawValue, forKey: GlobalPreference.FPVCenterViewType.rawValue)
    }
    
    public func centerViewType() -> FPVCenterViewType {
        let rawCenterViewType = userDefaults.integer(forKey: GlobalPreference.FPVCenterViewType.rawValue)
        if let centerViewType = FPVCenterViewType(rawValue: rawCenterViewType) {
            return centerViewType
        }
        return .Unknown
    }
    
    public func set(centerViewColor: FPVCenterViewColor) {
        userDefaults.set(centerViewColor.rawValue, forKey: GlobalPreference.FPVCenterViewColor.rawValue)
    }
    
    public func centerViewColor() -> FPVCenterViewColor {
        let rawCenterViewColor = userDefaults.integer(forKey: GlobalPreference.FPVCenterViewColor.rawValue)
        if let centerViewColor = FPVCenterViewColor(rawValue: rawCenterViewColor) {
            return centerViewColor
        }
        return .Unknown
    }
    
    public func set(gridViewType:FPVGridViewType) {
        userDefaults.set(gridViewType.rawValue, forKey: GlobalPreference.FPVGridViewType.rawValue)
    }
    
    public func gridViewType() -> FPVGridViewType {
        let rawGridViewType = userDefaults.integer(forKey: GlobalPreference.FPVGridViewType.rawValue)
        if let gridViewType = FPVGridViewType(rawValue: rawGridViewType) {
            return gridViewType
        }
        return .Unknown
    }
    
    public func set(value: NSValue, forKey: String) {
        userDefaults.set(value, forKey: forKey)
    }
    
    public override func value(forKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }

    public func set(_ value: Bool, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }

    public func bool(forKey key: String) -> Bool {
        return userDefaults.bool(forKey: key)
        
    }

}
