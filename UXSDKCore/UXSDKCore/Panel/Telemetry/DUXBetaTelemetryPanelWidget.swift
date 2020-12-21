//
//  DUXBetaTelemetryPanelWidget.swift
//  UXSDKCore
//
//  MIT License
//  
//  Copyright © 2020 DJI
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

@objcMembers public class DUXBetaTelemetryPanelWidget: DUXBetaFreeformPanelWidget {
    
    /// Pane ID of the DUXBetaAMSLAltitudeWidget
    public var amslAltitudeWidgetPaneID: Int = 0

    /// Pane ID of the DUXBetaAGLAltitudeWidget
    public var aglAltitudeWidgetPaneID: Int = 0

    /// Pane ID of the HorizontalVelocityWidget
    public var horizontalVelocityWidgetPaneID: Int = 0

    /// Pane ID of the DistanceRCWidget
    public var distanceRCWidgetPaneID: Int = 0

    /// Pane ID of the DistanceHomeWidget
    public var distanceHomeWidgetPaneID: Int = 0

    /// Pane ID of the VerticalVelocityWidget
    public var verticalVelocityWidgetPaneID: Int = 0

    /// Pane ID of the VPSWidget
    public var vpsWidgetPaneID: Int = 0

    /// Pane ID of the LocationWidget
    public var locationWidgetPaneID: Int = 0
    
    /// The standard widgetSizeHint indicating the minimum size for this widget and preferred aspect ratio.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: minWidgetSize.width/minWidgetSize.height, minimumWidth: minWidgetSize.width, minimumHeight: minWidgetSize.height)}
        set {
        }
    }
    
    var minWidgetSize = CGSize(width: 380.0, height: 124.0)
    
    fileprivate var amslAltitudeWidget: DUXBetaAMSLAltitudeWidget = DUXBetaAMSLAltitudeWidget()
    fileprivate var aglAltitudeWidget: DUXBetaAGLAltitudeWidget = DUXBetaAGLAltitudeWidget()
    fileprivate var horizontalVelocityWidget: DUXBetaHorizontalVelocityWidget = DUXBetaHorizontalVelocityWidget()
    fileprivate var distanceRCWidget: DUXBetaDistanceRCWidget = DUXBetaDistanceRCWidget()
    fileprivate var distanceHomeWidget: DUXBetaDistanceHomeWidget = DUXBetaDistanceHomeWidget()
    fileprivate var verticalVelocityWidget: DUXBetaVerticalVelocityWidget = DUXBetaVerticalVelocityWidget()
    fileprivate var vpsWidget: DUXBetaVPSWidget = DUXBetaVPSWidget()
    fileprivate var locationWidget: DUXBetaLocationWidget = DUXBetaLocationWidget()
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Generate panel structure
        let rowList = splitPane(rootPane(), along: .vertical, proportions: [0.25, 0.25, 0.25, 0.25])
        let columnList1 = splitPane(rowList[1], along: .horizontal, proportions: [0.33, 0.33, 0.33])
        let columnList2 = splitPane(rowList[2], along: .horizontal, proportions: [0.33, 0.33, 0.33])
        
        // Populate panel ids
        amslAltitudeWidgetPaneID = rowList[0]
        aglAltitudeWidgetPaneID = columnList1[0]
        horizontalVelocityWidgetPaneID = columnList1[1]
        distanceRCWidgetPaneID = columnList1[2]
        distanceHomeWidgetPaneID = columnList2[0]
        verticalVelocityWidgetPaneID = columnList2[1]
        vpsWidgetPaneID = columnList2[2]
        locationWidgetPaneID = rowList[3]
        
        // Populate panel with telemetry widgets
        let margins = UIEdgeInsets(top: 2.0, left: 10.0, bottom: 2.0, right: 2.0)
        addWidget(amslAltitudeWidget, toPane: amslAltitudeWidgetPaneID, position: .leading, margins: margins)
        addWidget(aglAltitudeWidget, toPane: aglAltitudeWidgetPaneID, position: .leading, margins: margins)
        addWidget(horizontalVelocityWidget, toPane: horizontalVelocityWidgetPaneID, position: .leading, margins: margins)
        addWidget(distanceRCWidget, toPane: distanceRCWidgetPaneID, position: .leading, margins: margins)
        addWidget(distanceHomeWidget, toPane: distanceHomeWidgetPaneID, position: .leading, margins: margins)
        addWidget(verticalVelocityWidget, toPane: verticalVelocityWidgetPaneID, position: .leading, margins: margins)
        addWidget(vpsWidget, toPane: vpsWidgetPaneID, position: .leading, margins: margins)
        addWidget(locationWidget, toPane: locationWidgetPaneID, position: .leading, margins: margins)
        
        view.widthAnchor.constraint(equalTo: view.heightAnchor, multiplier: widgetSizeHint.preferredAspectRatio).isActive = true
    }
}
