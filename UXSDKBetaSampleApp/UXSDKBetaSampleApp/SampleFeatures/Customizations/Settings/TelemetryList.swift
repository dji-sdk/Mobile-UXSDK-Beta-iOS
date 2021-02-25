//
//  TelemetryListSetting.swift
//  UXSDKBetaSampleApp
//
//  MIT License
//  
//  Copyright © 2021 DJI
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
import DJIUXSDK

class TelemetryListSetting: DUXBetaListItemTitleWidget {
    
    var current: Int = -1
    
    var widgets: [DUXBetaBaseTelemetryWidget] = []
    var widgetNames: [String] = []
    
    var telemetryPanel: DUXBetaTelemetryPanelWidget? {
        didSet {
            updateWidgetList()
        }
    }
    
    var selectedWidgets: [DUXBetaBaseTelemetryWidget] = [] {
        didSet {
            applyCustomizations()
        }
    }
    var visibilityValue: Bool? {
        didSet {
            applyVisibility()
        }
    }
    var textColorValue: UIColor? {
        didSet {
            applyTextColor()
        }
    }
    
    var backgroundColorValue: UIColor? {
        didSet {
            applyBackgroundColor()
        }
    }
    var textSizeValue: CGFloat? {
        didSet {
            applyFontSize()
        }
    }
    
    var onSelection: (([DUXBetaBaseWidget]?) -> ())?
    
    override func hasDetailList() -> Bool {
        return true
    }
    
    override func detailListType() -> DUXBetaListType {
        .selectOne
    }
    
    override func detailsTitle() -> String {
        return NSLocalizedString("Select Widget", comment: "Select Widget")
    }
    
    override func oneOfListOptions() -> [String : Any] {
        return ["current" : current, "list" : widgetNames]
    }
    
    override func selectionUpdate() -> (Int) -> Void {
        return { [weak self] selectionIndex in
            guard let self = self else { return }
            self.current = selectionIndex
            if selectionIndex == self.widgets.count {
                self.selectedWidgets = self.widgets
            } else {
                self.selectedWidgets = [self.widgets[selectionIndex]]
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        trailingMarginConstraint.isActive = false
        trailingMarginConstraint = trailingTitleGuide.rightAnchor.constraint(equalTo: view.rightAnchor)
        trailingMarginConstraint.isActive = true
    }
    
    func updateWidgetList() {
        if let panel = telemetryPanel {
            if let widget = telemetryPanel?.widgetInPane(panel.amslAltitudeWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.aglAltitudeWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.horizontalVelocityWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.distanceRCWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.distanceHomeWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.verticalVelocityWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.vpsWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            if let widget = telemetryPanel?.widgetInPane(panel.locationWidgetPaneID) as? DUXBetaBaseTelemetryWidget {
                widgetNames.append(widget.duxbeta_className())
                widgets.append(widget)
            }
            
            widgetNames.append(NSLocalizedString("All", comment: "All"))
        }
    }
    
    func applyCustomizations() {
        applyFontSize()
        applyTextColor()
        applyVisibility()
        applyBackgroundColor()
    }
    
    func applyVisibility() {
        guard let visibilityValue = visibilityValue else { return }
        for widget in self.selectedWidgets {
            widget.labelVisibility = visibilityValue
            widget.unitVisibility = visibilityValue
            widget.valueVisibility = visibilityValue
            widget.imageVisibility = visibilityValue
        }
    }
    
    func applyTextColor() {
        guard let textColorValue = textColorValue else { return }
        for widget in self.selectedWidgets {
            widget.labelTextColor = textColorValue
            widget.unitTextColor = textColorValue
            widget.valueTextColor = textColorValue
            widget.imageTintColor = textColorValue
        }
    }
    
    func applyBackgroundColor() {
        guard let backgroundColorValue = backgroundColorValue else { return }
        for widget in self.selectedWidgets {
            widget.labelBackgroundColor = backgroundColorValue
            widget.unitBackgroundColor = backgroundColorValue
            widget.valueBackgroundColor = backgroundColorValue
            widget.imageBackgroundColor = backgroundColorValue
        }
    }
    
    func applyFontSize() {
        guard let textSizeValue = textSizeValue else { return }
        for widget in self.selectedWidgets {
            widget.labelFont = UIFont.systemFont(ofSize: textSizeValue)
            widget.unitFont = UIFont.systemFont(ofSize: textSizeValue)
            widget.valueFont = UIFont.systemFont(ofSize: textSizeValue)
        }
    }
}
