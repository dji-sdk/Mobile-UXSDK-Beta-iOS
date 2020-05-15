//
//  WidgetsListViewController.swift
//  DJIUXSDK
//
// Copyright © 2018-2020 DJI
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
import DJIUXSDKBeta

protocol WidgetSelectionDelegate: class {
    func widgetSelected(_ newWidget: DUXBetaBaseWidget?, shouldShowCustomizationView:Bool)
}

class WidgetsListViewController: UITableViewController {
    
    weak var delegate: WidgetSelectionDelegate?
    
    static let widgetDescriptions:[String:String] = [
                                                    "AirSense Widget" : "Widget that indicates danger level posed by manned aircraft according to ADSB signals received.",
                                                    "Altitude Widget" : "Widget that shows the current altitude of the aircraft.",
                                                    "Battery Widget" : "Widget that displays aircraft battery level.",
                                                    "Compass Widget" : "Widget that displays the position of the aircraft in relation to the home point and pilot location.",
                                                    "Connection Widget" : "Widget that reflects the connected to aircraft state.",
                                                    "Dashboard Widget" : "Compound widget that aggregates important information about the aircraft into a dashboard.",
                                                    "Flight Mode Widget" : "Widget to show the current flight mode of the aircraft.",
                                                    "FPV Widget" : "Widget that shows the video feed from the camera.",
                                                    "GPS Signal Widget" : "Widget that displays the drone's connection strength to GPS.",
                                                    "Map Widget" : "Widget that displays the aircraft's state and information on the map this includes aircraft location, home location, aircraft trail path, aircraft heading, and No Fly Zones.",
                                                    "Remaining Flight Time Widget" : "Widget that shows the remaining flight time information for the aircraft.",
                                                    "Remote Control Signal Widget" : "Widget that displays the drone's connection strength with the remote controller.",
                                                    "Simulator Indicator Widget" : "Widget that displays the state of the simulator indicator.",
                                                    "System Status Widget" : "Widget that displays a string message indicating the system status of the aircraft.",
                                                    "System Status List Widget" : "Composed widget used to construct and display a standardized system status list.",
                                                    "Video Signal Widget" : "Widget that displays the incoming video strength from the aircraft",
                                                    "Vision Widget" : "Widget to display the vision status/collision avoidance status of the aircraft. Its state depends on sensors availability, flight mode, and aircraft type.",
                                                    "Top Bar Panel" : "Composed widget that acts as the container for the top bar widgets."
    ]
    
    static var widgetClosures: [() -> DUXBetaBaseWidget] {
        let airSenseWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaAirSenseWidget()
        }
        
        let altitudeWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaAltitudeWidget()
        }
        
        let batteryWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaBatteryWidget()
        }
        
        let compassWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaCompassWidget()
        }
        
        let connectionWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaConnectionWidget()
        }
        
        let dashboardWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaDashboardWidget()
        }
        
        let flightModeWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaFlightModeWidget()
        }
        
        let fpvWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaFPVWidget()
        }
        
        let gpsSignalWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaGPSSignalWidget()
        }
        
        let mapWidgetClosure: () -> DUXBetaBaseWidget = {
            let mapWidget = DUXBetaMapWidget()
            mapWidget.showFlyZoneLegend = false
            return mapWidget
        }
        
        let remainingFlightTimeWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaRemainingFlightTimeWidget()
        }
        
        let remoteControlSignalWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaRemoteControllerSignalWidget()
        }
        
        let simulatorIndicatorWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaSimulatorIndicatorWidget()
        }
        
        let systemStatusWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaSystemStatusWidget()
        }
        
        let systemStatusPanelWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXSystemStatusListWidget()
        }
        
        let videoSignalWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVideoSignalWidget()
        }
        
        let visionWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVisionWidget()
        }
        
        let topBarWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXTopBarWidget()
        }
        
        return [
            airSenseWidgetClosure,
            altitudeWidgetClosure,
            batteryWidgetClosure,
            compassWidgetClosure,
            connectionWidgetClosure,
            dashboardWidgetClosure,
            flightModeWidgetClosure,
            fpvWidgetClosure,
            gpsSignalWidgetClosure,
            mapWidgetClosure,
            remainingFlightTimeWidgetClosure,
            remoteControlSignalWidgetClosure,
            simulatorIndicatorWidgetClosure,
            systemStatusWidgetClosure,
            systemStatusPanelWidgetClosure,
            videoSignalWidgetClosure,
            visionWidgetClosure,
            topBarWidgetClosure
        ]
    }
    
    static let widgetMetadata:[(String, Bool)] = [
        ("AirSense Widget", false),
        ("Altitude Widget", false),
        ("Battery Widget", false),
        ("Compass Widget", false),
        ("Connection Widget", false),
        ("Dashboard Widget", false),
        ("Flight Mode Widget", false),
        ("FPV Widget", false),
        ("GPS Signal Widget", false),
        ("Map Widget", true),
        ("Remaining Flight Time Widget", false),
        ("Remote Control Signal Widget", false),
        ("Simulator Indicator Widget", false),
        ("System Status Widget", false),
        ("System Status List Widget", false),
        ("Video Signal Widget", false),
        ("Vision Widget", false),
        ("Top Bar Panel Widget", false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func close () {
        self.dismiss(animated: true) { }
    }
    
    // MARK: UITableViewDelegate
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let widgetClosure = WidgetsListViewController.widgetClosures[indexPath.row]
        let widget = widgetClosure()
        let shouldShowCustomizationView = WidgetsListViewController.widgetMetadata[indexPath.row].1
        delegate?.widgetSelected(widget, shouldShowCustomizationView: shouldShowCustomizationView)
        if let singleWidgetViewController = delegate as? SingleWidgetViewController {
            let title = WidgetsListViewController.widgetMetadata[indexPath.row].0
            singleWidgetViewController.shouldShowCustomizationView = shouldShowCustomizationView
            singleWidgetViewController.title = title
            singleWidgetViewController.widgetDescriptionLabel.text = WidgetsListViewController.widgetDescriptions[title]
            splitViewController?.showDetailViewController(singleWidgetViewController, sender: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WidgetsListViewController.widgetClosures.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetsListCellIdentifier", for: indexPath)
        let title = WidgetsListViewController.widgetMetadata[indexPath.row].0
        cell.textLabel?.text = title
        return cell
    }
}
