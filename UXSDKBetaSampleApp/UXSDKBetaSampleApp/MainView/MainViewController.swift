//
//  MainViewController.swift
//  UXSDKSampleApp
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

class MainViewController: UIViewController, UITextFieldDelegate, LogCenterListener {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var registered: UILabel!
    @IBOutlet weak var register: UIButton!
    @IBOutlet weak var connected: UILabel!
    @IBOutlet weak var connect: UIButton!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var useBridgeSwitch: UISwitch!
    @IBOutlet weak var bridgeIDField: UITextField!
    @IBOutlet weak var debugLogView: UITextView!
    
    //Internal outlets, remove before release.
    @IBOutlet weak var simulatorButton:UIButton!
    
    fileprivate var _isSimulatorActive: Bool = false
    public var isSimulatorActive: Bool {
        get {
            return _isSimulatorActive
        }
        set {
            _isSimulatorActive = newValue
            self.simulatorButton.setTitle(_isSimulatorActive ? "Stop Simulator" : "Start Simulator", for: UIControl.State.normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(productCommunicationDidChange), name: Notification.Name(rawValue: "ProductCommunicationServiceStateDidChange"), object: nil)
        self.bridgeIDField.delegate = self
        LogCenter.default.add(listener: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.version.text = "\(DJISDKManager.sdkVersion())"
        self.bridgeIDField.text = self.appDelegate.productCommManager.bridgeAppIP
        self.useBridgeSwitch.isOn = self.appDelegate.productCommManager.useBridge
    }
    
    @IBAction func registerAction() {
        self.appDelegate.productCommManager.registerWithProduct()
    }
    
    @IBAction func connectAction() {
        self.appDelegate.productCommManager.connectToProduct()
    }
    
    @IBAction func useBridgeAction(_ sender: UISwitch) {
        self.appDelegate.productCommManager.useBridge = sender.isOn
        self.appDelegate.productCommManager.disconnectFromProduct()
    }
    
    @IBAction func pushWidgetList(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WidgetSplitViewController") as? UISplitViewController {
            guard let navCon = vc.viewControllers.first as? UINavigationController else {
                return
            }
            guard let widgetsListViewController = navCon.topViewController as? WidgetsListViewController else {
                return
            }
            guard let singleWidgetViewController = vc.viewControllers.last as? SingleWidgetViewController else {
                return
            }
            widgetsListViewController.delegate = singleWidgetViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func productCommunicationDidChange() {
        if self.appDelegate.productCommManager.registered {
            self.registered.text = "YES"
            self.register.isHidden = true
        } else {
            self.registered.text = "NO"
            self.register.isHidden = false
        }
        
        if self.appDelegate.productCommManager.connected {
            self.connected.text = "YES"
            self.connect.isHidden = true
            
            guard let produtNameKey = DJIProductKey(param: DJIProductParamModelName) else {
                NSLog("Failed to create product name key")
                return;
            }
            
            let currentProductNameValue = DJISDKManager.keyManager()?.getValueFor(produtNameKey)
            
            if currentProductNameValue != nil {
                self.productName.text = currentProductNameValue?.stringValue
            } else {
                self.productName.text = "N/A"
            }
            
            DJISDKManager.keyManager()?.startListeningForChanges(on: produtNameKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    self.productName.text = newValue?.stringValue
                } else {
                    self.productName.text = "N/A"
                }
            })
            
            if let isSimulatorActiveKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsSimulatorActive) {
                DJISDKManager.keyManager()?.startListeningForChanges(on: isSimulatorActiveKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                    if newValue?.boolValue != nil {
                        self.isSimulatorActive = (newValue?.boolValue)!
                    }
                })
                DJISDKManager.keyManager()?.getValueFor(isSimulatorActiveKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
                    if value?.boolValue != nil {
                        self.isSimulatorActive = (value?.boolValue)!
                    }
                })
            }
            
        } else {
            self.connected.text = "NO"
            self.connect.isHidden = false
            self.productName.text = "N/A"
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.bridgeIDField {
            self.appDelegate.productCommManager.bridgeAppIP = textField.text!
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - LogCenterListener
    
    func logCenterContentDidChange() {
        self.debugLogView.text = LogCenter.default.fullLog()
    }
}
