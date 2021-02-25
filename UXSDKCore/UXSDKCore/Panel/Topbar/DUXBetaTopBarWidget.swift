//
//  DUXBetaTopBarWidget.swift
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

/**
 * DUXBetaTopBarWidget is the container for the top bar widgets.
 *
 * - DUXBetaSystemStatusWidget
 * - DUXBetaFlightModeWidget
 * - DUXBetaSimulatorIndicatorWidget
 * - DUXBetaAirSenseWidget
 * - DUXBetaGPSSignalWidget
 * - DUXBetaVisionWidget
 * - DUXBetaRemoteControllerSignalWidget
 * - DUXBetaVideoSignalWidget
 * - DUXBetaBatteryWidget
 * - DUXBetaConnectionWidget
 * 
*/
@objcMembers public class DUXBetaTopBarWidget: DUXBetaBarPanelWidget {
    
    public let systemStatusWidget = DUXBetaSystemStatusWidget()
    public let flightModeWidget = DUXBetaFlightModeWidget()
    public let simulatorIndicatorWidget = DUXBetaSimulatorIndicatorWidget()
    public let airSenseWidget = DUXBetaAirSenseWidget()
    public let gpsSignalWidget = DUXBetaGPSSignalWidget()
    public let visionWidget = DUXBetaVisionWidget()
    public let remoteControllerSignalWidget = DUXBetaRemoteControllerSignalWidget()
    public let videoSignalWidget = DUXBetaVideoSignalWidget()
    public let batteryWidget = DUXBetaBatteryWidget()
    public let connectionWidget = DUXBetaConnectionWidget()
    
    /**
     * Override of the standard viewdDidLoad method.
     * Adds the default rigtht and left side widgets.
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add default left-side widget
        addLeftWidgetArray([systemStatusWidget])
        
        
        // Add default right-side widgets
        addWidgetArray([flightModeWidget,
                        simulatorIndicatorWidget,
                        airSenseWidget,
                        gpsSignalWidget,
                        visionWidget,
                        remoteControllerSignalWidget,
                        videoSignalWidget,
                        batteryWidget,
                        connectionWidget])
    }
    
    /**
     * Override of the parent method because we always want to have
     * the panel working with this configuration.
     */
    public override func defaultConfigurationSetup() {
        // Enforce default configuration as an horizontal bar
        let config = DUXBetaPanelWidgetConfiguration(type:.bar, variant:.horizontal)
        let _ = configure(config)
    }
    
    /**
     * Override of the parent method where we create
     * a specific constraint for the leftbar stackview.
     */
    public override func spacingConstraint(forOrientation orientation: DUXBetaPanelVariant,
                                           andWorkBar workBar: UIView,
                                           withSize size: CGSize,
                                           andConstant constant: CGFloat) -> NSLayoutConstraint {
        if (orientation == .horizontal) && (workBar == leftBar) {
            return workBar.trailingAnchor.constraint(equalTo: rightBar.leadingAnchor)
        }

        return super.spacingConstraint(forOrientation: orientation,
                                       andWorkBar: workBar,
                                       withSize: size,
                                       andConstant: constant)
    }
}
