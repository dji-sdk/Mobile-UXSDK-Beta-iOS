//
//  DUXBetaBroadcaster.swift
//  DJIUXSDK
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
import Dispatch

enum Parameter: Hashable {
    case PeakingThreshold, DecoderStatus, AFCEnabled, SendWarningMessage, Attitude, Unknown
    
    public init(videoParameter:VideoParameter) {
        switch videoParameter {
            case .DecoderStatus:
                self = .DecoderStatus
            case .PeakingThreshold:
                self = .PeakingThreshold
            default:
                self = .Unknown
        }
    }
    
    public init(cameraParameter:CameraParameter) {
        switch cameraParameter {
            case .AFCEnabled:
                self = .AFCEnabled
            default:
                self = .Unknown
        }
    }
    
    public init(warningMessageParameter:WarningMessageParameter) {
        switch warningMessageParameter {
            case .SendWarningMessage:
                self = .SendWarningMessage
            default:
                self = .Unknown
        }
    }
    
    public init(voiceNotificationParameter:VoiceNotificationParameter) {
        switch voiceNotificationParameter {
            case .Attitude:
                self = .Attitude
            default:
                self = .Unknown
        }
    }
    
    func cameraParameter() -> CameraParameter {
        switch self {
            case .AFCEnabled:
                return .AFCEnabled
            default:
                return .Unknown
        }
    }
    
    func videoParameter() -> VideoParameter {
        switch self {
            case .DecoderStatus:
                return .DecoderStatus
            case .PeakingThreshold:
                return .PeakingThreshold
            default:
                return .Unknown
        }
    }
    
    func warningMessageParameter() -> WarningMessageParameter {
        switch self {
            case .SendWarningMessage:
                return .SendWarningMessage
            default:
                return .Unknown
        }
    }
    
    func voiceNotificationParameter() -> VoiceNotificationParameter {
        switch self {
            case .Attitude:
                return .Attitude
            default:
                return .Unknown
        }
    }
}

protocol Key: Hashable {
    var param: Parameter {get set}
    var index: Int {get set}
}

class ConcreteKey: Key {
    init(index:Int, parameter:Parameter) {
        self.param = parameter
        self.index = index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.param)
        hasher.combine(self.index)
    }
    
    var hashValue: Int {
        return (self.param.hashValue ^ self.index.hashValue)
    }
    
    public static func == (lhs: ConcreteKey, rhs: ConcreteKey) -> Bool {
        return lhs.index == rhs.index && lhs.param == rhs.param
    }
    
    var param: Parameter
    var index: Int
}

enum Type {
    case object, unsignedInteger, signedInteger
}

// ExternalKey bridges to the Key / ConcreteKey types that cannot be used in obj-c
@objc(DUXBetaKey) public class ExternalKey : NSObject {
    var concreteKey:ConcreteKey {
        get {
            return ConcreteKey(index:self.index, parameter:self.internalParameter)
        }
    }
    
    public let index:Int
    
    let internalParameter:Parameter
    
    init(index:Int, param:Parameter) {
        self.index = index
        self.internalParameter = param
    }
    
    init(concreteKey:ConcreteKey) {
        self.index = concreteKey.index
        self.internalParameter = concreteKey.param
    }
}

// **************How add a new global key**************
// We use Swift enums inside the global key system and Objective-C compatible enums in public APIs
// This is to take advantage of Swift enum specific features in the future
// One example is Swift enums can have methods, which makes our bridging code between Swift-Obj-C very clean
// Swift enums get additional compile-time checks that can help us avoid simple bugs in the future
// See Parameter enum above for an example
// Steps
// 1. Does your key need a new public enum type?
// We already have types for Video and Camera enums, others may be added as needed.
// Make sure your new class includes Unknown to support fallible conversion
// 2. Add your enum (either to your new enum type or to an existing one)
// 3. Add your enum to the Parameter enum type, make sure it is mapped correctly by one of
// the initializers (there's one for each public enum type)
// 4. Make sure it is mapped by the appropriate conversion method back to the public type
// 5. You're done!

@objc(DUXBetaCameraParameter) public enum CameraParameter : UInt {
    case AFCEnabled     = 1,
         Unknown        = 2
}

@objc(DUXBetaCameraKey) public class CameraKey : ExternalKey {
    public var param:CameraParameter {
        return self.internalParameter.cameraParameter()
    }
    
    @objc public init(index: Int, parameter: CameraParameter) {
        super.init(index: index,
                   param: Parameter(cameraParameter: parameter))
    }
}

@objc(DUXBetaVideoParameter) public enum VideoParameter : UInt {
    case DecoderStatus      = 1,
         PeakingThreshold   = 2,
         Unknown            = 3
}

@objc(DUXBetaVideoKey) public class VideoKey : ExternalKey {
    @objc public init(index: Int, parameter: VideoParameter) {
        super.init(index: index,
                   param: Parameter(videoParameter: parameter))
    }
    
    public var param:VideoParameter {
        return self.internalParameter.videoParameter()
    }
}

@objc(DUXBetaWarningMessageParameter) public enum WarningMessageParameter : UInt {
    case SendWarningMessage = 1,
         Unknown            = 2
}

@objc(DUXBetaWarningMessageKey) public class WarningMessageKey : ExternalKey {
    @objc public init(index: Int, parameter: WarningMessageParameter) {
        super.init(index: index,
                   param: Parameter(warningMessageParameter: parameter))
    }
    
    public var param:WarningMessageParameter {
        return self.internalParameter.warningMessageParameter()
    }
}

@objc(DUXBetaVoiceNotificationParameter) public enum VoiceNotificationParameter : UInt {
    case Attitude = 1,
         Unknown  = 3
}

@objc(DUXBetaVoiceNotificationKey) public class VoiceNotificationKey : ExternalKey {
    @objc public init(index: Int, parameter: VoiceNotificationParameter) {
        super.init(index: index,
                   param: Parameter(voiceNotificationParameter: parameter))
    }
    
    public var param:VoiceNotificationParameter {
        return self.internalParameter.voiceNotificationParameter()
    }
}

public class ModelValue: NSObject {
    @objc public var value:NSObject
    let type:Type
    
    @objc public init(value:NSObject) {
        self.value = value
        self.type = .object
    }
    
    @objc public init(unsignedInteger:UInt) {
        self.value = NSNumber(value: unsignedInteger)
        self.type = .unsignedInteger
    }
    
    @objc public init(integer:Int) {
        self.value = NSNumber(value: integer)
        self.type = .signedInteger
    }
}

typealias ModelValueCompletionBlock = (ModelValue?) -> Void

class FlatStore: NSObject {
    var underlyingStore:[ConcreteKey:ModelValue] = [:]
    var queue:DispatchQueue = DispatchQueue(label: "DUXBetaFlatStoreSerialQueue")
    
    func update(modelValue:ModelValue?, for key:ConcreteKey) {
        self.queue.async {
            self.underlyingStore[key] = modelValue
        }
    }
    
    func availableModelValueFor(key: ConcreteKey) -> ModelValue? {
        var modelValue: ModelValue?;
        
        self.queue.sync {
            modelValue = self.underlyingStore[key]
        }
        
        return modelValue
    }
    
    // @escaping always for async execution, always
    func modelValueFor(key: ConcreteKey, completion: @escaping ModelValueCompletionBlock) {
        self.queue.async {
            completion(self.underlyingStore[key])
        }
    }
}

protocol BroadcastObserver:Hashable {
    func broadcast(updatedValue:ModelValue?, priorValue:ModelValue?, for key:ConcreteKey)
}

class ClosureBroadcastObserver<U: ConcreteKey>: BroadcastObserver {
    public static func == (lhs: ClosureBroadcastObserver, rhs: ClosureBroadcastObserver) -> Bool {
        return lhs.reference == rhs.reference
    }
    
    init(reference: NSObject, updateBlock:ObservableKeyedStoreUpdateBlock?) {
        self.reference = reference
        self.updateBlock = updateBlock
    }
    
    var reference: NSObject
    var updateBlock:ObservableKeyedStoreUpdateBlock?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.reference)
    }
    
    var hashValue: Int {
        return self.reference.hashValue
    }
    
    func broadcast(updatedValue:ModelValue?, priorValue:ModelValue?, for key:ConcreteKey) {
        if let updateBlock = self.updateBlock {
            updateBlock(updatedValue, priorValue, ExternalKey(concreteKey: key))
        }
    }
}

class Broadcaster<ObserverType: BroadcastObserver, KeyType: ConcreteKey> {
    var observers:[KeyType:Set<ObserverType>] = [:]
    let workingQueue:DispatchQueue = DispatchQueue(label: "BroadcasterWorkingQueue")
    
    // Queue where broadcasts occur, main thread by default
    var preferredBroadcastQueue:DispatchQueue? = DispatchQueue.main
    
    func add(observer:ObserverType, for key:KeyType) {
        self.workingQueue.async {
            if var observers = self.observers[key] {
                observers.insert(observer)
            } else {
                var set = Set<ObserverType>()
                set.insert(observer)
                self.observers[key] = set
            }
        }
    }
    
    func add(observer:ObserverType, for key:KeyType, broadcastAvailableValue:Bool) {
        self.workingQueue.async {
            if var observers = self.observers[key] {
                observers.insert(observer)
            } else {
                var set = Set<ObserverType>()
                set.insert(observer)
                self.observers[key] = set
            }
        }
    }
    
    func remove(observer:ObserverType, for key:KeyType) {
        self.workingQueue.async {
            if var observersForKey = self.observers[key] {
                observersForKey.remove(observer)
            }
        }
    }
    
    func removeAllInstancesOf(observer:ObserverType) {
        self.workingQueue.async {
            var updatedObservers:[KeyType:Set<ObserverType>] = [:]
            
            for (key, value) in self.observers {
                updatedObservers[key] = value.filter { (broadcastObserver:ObserverType) -> Bool in
                    return broadcastObserver != observer
                }
            }
            
            self.observers = updatedObservers
        }
    }
    
    func removeAllObservers() {
        self.workingQueue.async {
            self.observers.removeAll()
        }
    }
    
    func broadcast(updatedValue:ModelValue?, priorValue:ModelValue?, for key:KeyType) {
        self.workingQueue.async {
            if let keyObservers = self.observers[key] {
                for observer in keyObservers {
                    self.preferredBroadcastQueue?.async {
                        observer.broadcast(updatedValue: updatedValue, priorValue: priorValue, for: key)
                    }
                }
            }
        }
    }
}

public typealias ObservableKeyedStoreUpdateBlock = (ModelValue?, ModelValue?, ExternalKey) -> ()

@objc public protocol ObservableKeyedStore {
    @objc(addObserver:forKey:broadcastAvailableValue:withUpdateBlock:)
    func add(observer: NSObject?, for key:ExternalKey, broadcastAvailableValue:Bool, updateBlock:@escaping ObservableKeyedStoreUpdateBlock)
    
    @objc(removeObserver:forKey:)
    func remove(observer: NSObject?, for key:ExternalKey)
    
    func removeAllInstancesOf(observer:NSObject?)
    
    func removeAllObservers()
    
    @objc(availableValueForKey:)
    func availableValueFor(key: ExternalKey) -> ModelValue?
    
    @objc(setModelValue:forKey:)
    func set(modelValue:ModelValue?, for key:ExternalKey)
}

public class ObservableInMemoryKeyedStore : NSObject, ObservableKeyedStore {
    let store:FlatStore = FlatStore()
    let broadcaster:Broadcaster<ClosureBroadcastObserver, ConcreteKey> = Broadcaster()
    
    @objc(addObserver:forKey:broadcastAvailableValue:withUpdateBlock:)
    public func add(observer: NSObject?, for key:ExternalKey, broadcastAvailableValue:Bool, updateBlock:@escaping ObservableKeyedStoreUpdateBlock) {
        if let nonNilObserver = observer {
            let broadcastObserver = ClosureBroadcastObserver(reference: nonNilObserver, updateBlock: updateBlock)
            self.broadcaster.add(observer: broadcastObserver, for: key.concreteKey, broadcastAvailableValue:broadcastAvailableValue)
        }
    }
    
    @objc(removeObserver:forKey:)
    public func remove(observer: NSObject?, for key:ExternalKey) {
        if let nonNilObserver = observer {
            let broadcastObserver = ClosureBroadcastObserver(reference: nonNilObserver, updateBlock: nil)
            self.broadcaster.remove(observer: broadcastObserver, for: key.concreteKey)
        }
    }
    
    public func removeAllInstancesOf(observer:NSObject?) {
        if let nonNilObserver = observer {
            let broadcastObserver = ClosureBroadcastObserver(reference: nonNilObserver, updateBlock: nil)
            self.broadcaster.removeAllInstancesOf(observer: broadcastObserver)
        }
    }
    
    public func removeAllObservers() {
        self.broadcaster.removeAllObservers()
    }
    
    @objc(availableValueForKey:)
    public func availableValueFor(key: ExternalKey) -> ModelValue? {
        return self.store.availableModelValueFor(key: key.concreteKey)
    }
    
    @objc(setModelValue:forKey:)
    public func set(modelValue:ModelValue?, for key:ExternalKey) {
        self.store.update(modelValue: modelValue, for: key.concreteKey)
        self.broadcaster.broadcast(updatedValue: modelValue, priorValue: self.store.availableModelValueFor(key: key.concreteKey), for: key.concreteKey)
    }
}
