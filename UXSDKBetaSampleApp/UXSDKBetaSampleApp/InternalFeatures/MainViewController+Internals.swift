//
//  MainViewController+Internals.swift
//  UXSDKSampleApp
//
//  MIT License
//  
//  Copyright © 2020-2021 DJI
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

extension MainViewController {
    @IBAction func pushInternalWidgetList(_ sender: Any) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "InternalWidgetSplitViewController") as? UISplitViewController {
            guard let navCon = vc.viewControllers.first as? UINavigationController else {
                return
            }
            guard let widgetsListViewController = navCon.topViewController as? InternalWidgetsListViewController else {
                return
            }
            guard let singleWidgetViewController = vc.viewControllers.last as? InternalSingleWidgetViewController else {
                return
            }
            widgetsListViewController.delegate = singleWidgetViewController
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func startSimulatorAction() {
        //Portola Valley 37.343250, -122.218549
        //Palo Alto 37.460484, -122.115312
        //Shenzhen 22.5726, 113.8124499
        let droneCoordinates = CLLocationCoordinate2DMake(37.343250, -122.218549)
        
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            if self.isSimulatorActive {
                aircraft.flightController?.simulator?.stop(completion: nil)
            } else {
                aircraft.flightController?.simulator?.start(withLocation: droneCoordinates,
                                                            updateFrequency: 20,
                                                            gpsSatellitesNumber: 12,
                                                            withCompletion: { (error) in
                                                                if (error != nil) {
                                                                    let alertController = UIAlertController(title: "Simulator Error",
                                                                                                            message: error.debugDescription,
                                                                                                            preferredStyle: .alert)
                                                                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                                    alertController.addAction(action)
                                                                    self.present(alertController,
                                                                                 animated: true,
                                                                                 completion: nil)
                                                                }
                                                                aircraft.flightController?.simulator?.setFlyZoneLimitationEnabled(true, withCompletion: nil)
                })
            }
        }
    }
}
