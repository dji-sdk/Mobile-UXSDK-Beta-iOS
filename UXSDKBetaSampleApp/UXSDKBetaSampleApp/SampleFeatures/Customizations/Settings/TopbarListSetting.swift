//
//  TopbarListSetting.swift
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

class TopbarListSetting: DUXBetaListItemTitleWidget {
    var widgetNames: [String?] = []
    
    var current: Int = -1 {
        didSet {
            applyCustomizations()
        }
    }
    
    var topbarWidget: DUXBetaTopBarWidget? {
        didSet {
            computeWidgetNames()
        }
    }
    
    public var connectedTintColor: UIColor? {
        didSet {
            applyConnectedTintColor()
        }
    }
    
    public var disconnectedTintColor: UIColor? {
        didSet {
            applyDisconnectedTintColor()
        }
    }
    
    public var inactiveTintColor: UIColor? {
        didSet {
            applyInactiveTintColor()
        }
    }
    
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
            self?.current = selectionIndex
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
                
        trailingMarginConstraint.isActive = false
        trailingMarginConstraint = trailingTitleGuide.rightAnchor.constraint(equalTo: view.rightAnchor)
        trailingMarginConstraint.isActive = true
    }
    
    func applyCustomizations() {
        applyInactiveTintColor()
        applyConnectedTintColor()
        applyDisconnectedTintColor()
    }
    
    func applyConnectedTintColor() {
        if let color = connectedTintColor {
            if isSelected(widgetName: topbarWidget?.systemStatusWidget.duxbeta_className()) {
                topbarWidget?.systemStatusWidget.setTextColor(color, forSystemStatusWarning:.good)
            }
            if isSelected(widgetName: topbarWidget?.flightModeWidget.duxbeta_className()) {
                topbarWidget?.flightModeWidget.iconTintColorConnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.simulatorIndicatorWidget.duxbeta_className()) {
                topbarWidget?.simulatorIndicatorWidget.setTintColor(color, for: .active)
            }
            
            if isSelected(widgetName: topbarWidget?.airSenseWidget.duxbeta_className()) {
                topbarWidget?.airSenseWidget.setTintColor(color, forWarning: .init(0))
            }
            
            if isSelected(widgetName: topbarWidget?.gpsSignalWidget.duxbeta_className()) {
                topbarWidget?.gpsSignalWidget.iconTintColorConnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.visionWidget.duxbeta_className()) {
                topbarWidget?.visionWidget.iconBackgroundColor = color
            }
            
            if isSelected(widgetName: topbarWidget?.remoteControllerSignalWidget.duxbeta_className()) {
                topbarWidget?.remoteControllerSignalWidget.connectedTintColor = color
            }
            
            if isSelected(widgetName: topbarWidget?.videoSignalWidget.duxbeta_className()) {
                topbarWidget?.videoSignalWidget.iconTintColorConnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.batteryWidget.duxbeta_className()) {
                topbarWidget?.batteryWidget.setTintColor(color, for: DUXBetaBatteryStatus.normal)
            }
        }
    }
    
    func applyDisconnectedTintColor() {
        if let color = disconnectedTintColor {
            if isSelected(widgetName: topbarWidget?.systemStatusWidget.duxbeta_className()) {
                topbarWidget?.systemStatusWidget.setTextColor(color, forSystemStatusWarning:.offline)
            }
            
            if isSelected(widgetName: topbarWidget?.flightModeWidget.duxbeta_className()) {
                topbarWidget?.flightModeWidget.iconTintColorDisconnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.simulatorIndicatorWidget.duxbeta_className()) {
                topbarWidget?.simulatorIndicatorWidget.setTintColor(color, for: .disconnected)
            }
            
            if isSelected(widgetName: topbarWidget?.airSenseWidget.duxbeta_className()) {
                topbarWidget?.airSenseWidget.setTintColor(color, forWarning: .init(0))
            }
            
            if isSelected(widgetName: topbarWidget?.gpsSignalWidget.duxbeta_className()) {
                topbarWidget?.gpsSignalWidget.iconTintColorDisconnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.visionWidget.duxbeta_className()) {
                topbarWidget?.visionWidget.disconnectedIconColor = color
            }
            
            if isSelected(widgetName: topbarWidget?.remoteControllerSignalWidget.duxbeta_className()) {
                topbarWidget?.remoteControllerSignalWidget.disconnectedTintColor = color
            }
            
            if isSelected(widgetName: topbarWidget?.videoSignalWidget.duxbeta_className()) {
                topbarWidget?.videoSignalWidget.iconTintColorDisconnected = color
            }
            
            if isSelected(widgetName: topbarWidget?.batteryWidget.duxbeta_className()) {
                topbarWidget?.batteryWidget.setTintColor(color, for: DUXBetaBatteryStatus.unknown)
            }
        }
    }
    
    func applyInactiveTintColor() {
        if let color = inactiveTintColor {
            if isSelected(widgetName: topbarWidget?.systemStatusWidget.duxbeta_className()) {
                topbarWidget?.systemStatusWidget.setTextColor(color, forSystemStatusWarning:.error)
            }
            topbarWidget?.simulatorIndicatorWidget.setTintColor(color, for: .inactive)
        }
    }
    
    func computeWidgetNames() {
        widgetNames.append(topbarWidget?.systemStatusWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.flightModeWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.simulatorIndicatorWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.airSenseWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.gpsSignalWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.visionWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.remoteControllerSignalWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.videoSignalWidget.duxbeta_className())
        widgetNames.append(topbarWidget?.batteryWidget.duxbeta_className())
        widgetNames.append(NSLocalizedString("All", comment: "All"))
    }
    
    func isSelected(widgetName: String?) -> Bool {
        if current == -1 {
            return false
        }
        if current == widgetNames.count - 1 {
            return true
        }
        if widgetNames[current] == widgetName {
            return true
        }
        return false
    }
}
