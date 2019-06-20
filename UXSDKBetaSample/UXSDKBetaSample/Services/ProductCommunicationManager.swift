//
//  ProductCommunicationManager.swift
//  DJIUXSDK
//
// Copyright © 2018-2019 DJI
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import UIKit
import DJISDK

class ProductCommunicationManager: NSObject, DJISDKManagerDelegate {
    public weak var appDelegate = UIApplication.shared.delegate as? AppDelegate
    public var connectedProduct: DJIBaseProduct!
    var bridgeAppIP = "0.0.0.0" {
        didSet {
            UserDefaults.standard.set(bridgeAppIP, forKey: "bridgeAppIP")
        }
    }
    var useBridge = false {
        didSet {
            if useBridge == false {
                DJISDKManager.disableBridgeMode()
            }
        }
    }
    
    var registered = false
    var connected = false
    
    override init() {
        super.init()        
        #if arch(i386) || arch(x86_64)
            self.useBridge = true
        #endif
        if let bridgeIP = UserDefaults.standard.string(forKey: "bridgeAppIP") {
            self.bridgeAppIP = bridgeIP
        }
    }
        
    public func connectToProduct() {
        if useBridge {
            LogCenter.default.add("Connecting to Product using DebugID: \(bridgeAppIP)")
            DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
        } else {
            LogCenter.default.add("Connecting to product")
            let startedResult = DJISDKManager.startConnectionToProduct()
            
            if startedResult {
                LogCenter.default.add("Connecting to product started successfully")
            } else {
                LogCenter.default.add("Connecting to product failed to start")
            }
        }
    }
    
    public func disconnectProduct() {
        DJISDKManager.stopConnectionToProduct()
        
        // This is a little cheat because sdkmanager is not properly disconnecting the product.
        self.connected = false
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
        LogCenter.default.add("Disconnected from product");
    }
    
    func registerWithProduct() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let path = Bundle.main.path(forResource: "Info", ofType: "plist") {
                if let dict = NSDictionary(contentsOfFile: path) as? Dictionary<String, AnyObject> {
                    let appKey = dict["DJISDKAppKey"] != nil ? dict["DJISDKAppKey"] as! String : "NilValue for AppKey"
                    LogCenter.default.add("Registering Product with ID: \(appKey)")
                }
            }
            DJISDKManager.registerApp(with: self)
        }
    }
    
    //MARK: - DJISDKManagerDelegate
    func appRegisteredWithError(_ error: Error?) {
        if useBridge {
            if error == nil {
                self.registered = true
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
            }
            LogCenter.default.add("Ignoring Registration Results because using bridge")
            self.connectToProduct()
        } else {
            if error != nil {
                LogCenter.default.add("Error Registrating App: \(error!)")
            } else {
                self.registered = true
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
                LogCenter.default.add("Registration Succeeded")
                self.connectToProduct()
            }
        }
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        LogCenter.default.add("Product trying to connect")
        if product != nil {
            self.connected = true
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
            LogCenter.default.add("Product connected successfully")
            self.connectedProduct = product
        }
    }
    
    func productDisconnected() {
        LogCenter.default.add("Disconnected from product");
        self.connected = false
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "ProductCommunicationManagerStateDidChange")))
    }
}
