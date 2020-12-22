//
//  WidgetsListViewController.swift
//  UXSDKSampleApp
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
                                                    "AGL Widget" : "Widget displays the above ground level altitude.",
                                                    "AMSL Widget" : "Widget displays the above mean sea level altitude.",
                                                    "Battery Widget" : "Widget that displays aircraft battery level.",
                                                    "Compass Widget" : "Widget that displays the position of the aircraft in relation to the home point and pilot location.",
                                                    "Connection Widget" : "Widget that reflects the connected to aircraft state.",
                                                    "Distance Home Widget" : "The widget that displays the distance between the current location of the aicraft and the recorded home point.",
                                                    "Distance Remote Control Widget" : "The widget that displays the distance between the current location of the aicraft and the remote controller location.",
                                                    "Flight Mode Widget" : "Widget to show the current flight mode of the aircraft.",
                                                    "FPV Widget" : "Widget that shows the video feed from the camera.",
                                                    "GPS Signal Widget" : "Widget that displays the drone's connection strength to GPS.",
                                                    "Horizontal Velocity Widget" : "Widget displays the horizontal velocity of the aircraft.",
                                                    "Location Widget" : "The widget that displays the distance between the current location of the aicraft and the remote controller location.",
                                                    "Map Widget" : "Widget that displays the aircraft's state and information on the map this includes aircraft location, home location, aircraft trail path, aircraft heading, and No Fly Zones.",
                                                    "Remaining Flight Time Widget" : "Widget that shows the remaining flight time information for the aircraft.",
                                                    "Remote Control Signal Widget" : "Widget that displays the drone's connection strength with the remote controller.",
                                                    "Return Home Widget" : "Widget that performs actions related to returning home.",
                                                    "RTK Widget" : "Composed widget used to display a switch that will enable or disable RTK and the state of RTK base station with a table of RTK positioning values.",
                                                    "Simulator Indicator Widget" : "Widget that displays the state of the simulator indicator.",
                                                    "System Status Widget" : "Widget that displays a string message indicating the system status of the aircraft.",
                                                    "System Status List Widget" : "Composed widget used to construct and display a standardized system status list.",
                                                    "Vertical Velocity Widget" : "Widget displays the vertical velocity of the aircraft.",
                                                    "Video Signal Widget" : "Widget that displays the incoming video strength from the aircraft.",
                                                    "Vision Widget" : "Widget to display the vision status/collision avoidance status of the aircraft. Its state depends on sensors availability, flight mode, and aircraft type.",
                                                    "VPS Widget" : "Widget that displays the status of the vision positioning system as well as the height of the aircraft as received from the vision positioning system if available.",
                                                    "Take Off Widget" : "Widget that performs actions related to takeoff and landing.",
                                                    "Telemetry Panel Widget" : "Compound widget that aggregates flight telemetry information about the aircraft into a panel.",
                                                    "Top Bar Panel" : "Composed widget that acts as the container for the top bar widgets."
    ]
    
    static var widgetClosures: [() -> DUXBetaBaseWidget] {
        let airSenseWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaAirSenseWidget()
        }
        
        let aglWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaAGLAltitudeWidget()
        }
        
        let amslSenseWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaAMSLAltitudeWidget()
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
        
        let distanceHomeWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaDistanceHomeWidget()
        }
        
        let distanceRCWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaDistanceRCWidget()
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
        
        let horizontalVelocityWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaHorizontalVelocityWidget()
        }
        
        let locationWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaLocationWidget()
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
        
        let returnHomeWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaReturnHomeWidget()
        }
        
        let rtkWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaRTKWidget()
        }
        
        let simulatorIndicatorWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaSimulatorIndicatorWidget()
        }
        
        let systemStatusWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaSystemStatusWidget()
        }
        
        let systemStatusPanelWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaSystemStatusListWidget()
        }
        
        let verticalVelocityWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVerticalVelocityWidget()
        }
        
        let videoSignalWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVideoSignalWidget()
        }
        
        let visionWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVisionWidget()
        }
        
        let vpsWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaVPSWidget()
        }
        
        let takeoffWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaTakeOffWidget()
        }
        
        let telemetryWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaTelemetryPanelWidget()
        }
        
        let topBarWidgetClosure: () -> DUXBetaBaseWidget = {
            return DUXBetaTopBarWidget()
        }
        
        return [
            airSenseWidgetClosure,
            aglWidgetClosure,
            amslSenseWidgetClosure,
            batteryWidgetClosure,
            compassWidgetClosure,
            connectionWidgetClosure,
            distanceHomeWidgetClosure,
            distanceRCWidgetClosure,
            flightModeWidgetClosure,
            fpvWidgetClosure,
            gpsSignalWidgetClosure,
            horizontalVelocityWidgetClosure,
            locationWidgetClosure,
            mapWidgetClosure,
            remainingFlightTimeWidgetClosure,
            remoteControlSignalWidgetClosure,
            returnHomeWidgetClosure,
            rtkWidgetClosure,
            simulatorIndicatorWidgetClosure,
            systemStatusWidgetClosure,
            systemStatusPanelWidgetClosure,
            verticalVelocityWidgetClosure,
            videoSignalWidgetClosure,
            visionWidgetClosure,
            vpsWidgetClosure,
            takeoffWidgetClosure,
            telemetryWidgetClosure,
            topBarWidgetClosure
        ]
    }
    
    static let widgetMetadata:[(String, Bool)] = [
        ("AirSense Widget", false),
        ("AGL Widget", false),
        ("AMSL Widget", false),
        ("Battery Widget", false),
        ("Compass Widget", false),
        ("Connection Widget", false),
        ("Distance Home Widget", false),
        ("Distance RC Widget", false),
        ("Flight Mode Widget", false),
        ("FPV Widget", false),
        ("GPS Signal Widget", false),
        ("Horizontal Velocity Widget", false),
        ("Location Widget", false),
        ("Map Widget", false),
        ("Remaining Flight Time Widget", false),
        ("Remote Control Signal Widget", false),
        ("Return Home Widget", false),
        ("RTK Widget", false),
        ("Simulator Indicator Widget", false),
        ("System Status Widget", false),
        ("System Status List Widget", false),
        ("Vertical Velocity Widget", false),
        ("Video Signal Widget", false),
        ("Vision Widget", false),
        ("VPS Widget", false),
        ("Take Off Widget", false),
        ("Telemetry Panel Widget", false),
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
        if let singleWidgetViewController = delegate as? SingleWidgetViewController {
            let title = WidgetsListViewController.widgetMetadata[indexPath.row].0
            singleWidgetViewController.widgetSelected(widget, shouldShowCustomizationView: shouldShowCustomizationView)
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
