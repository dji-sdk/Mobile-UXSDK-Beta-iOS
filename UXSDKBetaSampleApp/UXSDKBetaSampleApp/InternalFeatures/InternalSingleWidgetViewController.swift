//
//  InternalSingleWidgetViewController.swift
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
import DJIUXSDK

class InternalSingleWidgetViewController: UIViewController, DUXBetaWidgetCloseButtonProtocol, DUXBetaAccessLockerControlWidgetDelegate, DUXBetaBatteryWidgetDelegate {
    
    @IBOutlet var noWidgetSelectedLabel: UILabel!
    @IBOutlet var infoView: UIView!
    @IBOutlet var pinchToResizeLabel: UILabel!
    @IBOutlet var aspectRatioLabel: UILabel!
    @IBOutlet var currentSizeLabel: UILabel!
    
    var videoView: UIView!
    
    private var pinchStartHeight: CGFloat = 0.0
    private var heightConstraint: NSLayoutConstraint?
    
    private var _widget: DUXBetaBaseWidget? = nil
    var widget: DUXBetaBaseWidget? {
        set {
            // Cleanup old widget from parent
            _widget?.removeFromParent()
            _widget?.view.removeFromSuperview()
            if (self.videoView != nil) {
                self.videoView.removeFromSuperview()
            }
            _widget = newValue
            if let nonNilWidget = _widget {
                if (noWidgetSelectedLabel != nil){
                    noWidgetSelectedLabel.isHidden = true
                }
                if (infoView != nil) {
                    infoView.isHidden = false
                }
                if (pinchToResizeLabel != nil){
                    pinchToResizeLabel.isHidden = false
                }

                nonNilWidget.install(in: self)
                self.configureConstraints()
                
                if nonNilWidget.isKind(of: DUXBetaAccessLockerControlWidget.self) {
                    if let accessLockerControlWidget = nonNilWidget as? DUXBetaAccessLockerControlWidget {
                        accessLockerControlWidget.delegate = self
                    }
                }
                
                if nonNilWidget.isKind(of: DUXBetaBatteryWidget.self) {
                    if let batteryWidget = nonNilWidget as? DUXBetaBatteryWidget {
                        batteryWidget.delegate = self
                    }
                }
                
                if nonNilWidget.isKind(of: DUXBetaRemainingFlightTimeWidget.self) {
                    if let remainingTimeWidget = nonNilWidget as? DUXBetaRemainingFlightTimeWidget {
                        remainingTimeWidget.view.widthAnchor.constraint(equalTo: remainingTimeWidget.view.heightAnchor, multiplier: remainingTimeWidget.widgetSizeHint.preferredAspectRatio).isActive = true
                    }
                }
                
                if nonNilWidget.isKind(of: DUXBetaRTKWidget.self) {
                    if let rtkWidget = nonNilWidget as? DUXBetaRTKWidget {
                        // Show RTK Widget
                        rtkWidget.view.isHidden = false;
                    }
                }
                
                //Don't set border for battery widget initially so you can see the borders around dual battery voltage labels
                if !(nonNilWidget.isKind(of: DUXBetaBatteryWidget.self) || nonNilWidget.isKind(of: DUXBetaRTKSatelliteStatusWidget.self) || nonNilWidget.isKind(of: DUXBetaRTKWidget.self)) {
                    recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: true, level: 0)
                }
                
                aspectRatioLabel.text = String(format: "%.1f", nonNilWidget.widgetSizeHint.preferredAspectRatio)
                currentSizeLabel.text = String(format: "[%.1f, %.1f]", nonNilWidget.view.frame.size.width, nonNilWidget.view.frame.size.height)
                if nonNilWidget.isKind(of: DUXBetaHistogramWidget.self) {
                    if let histogramWidget = nonNilWidget as? DUXBetaHistogramWidget {
                        histogramWidget.delegate = self
                    }
                }
                if nonNilWidget.isKind(of: DUXBetaColorWaveFormWidget.self) {
                    if let colorWaveFormWidget = nonNilWidget as? DUXBetaColorWaveFormWidget {
                        colorWaveFormWidget.delegate = self
                    }
                }
            } else {
                noWidgetSelectedLabel.isHidden = false
                infoView.isHidden = true
                pinchToResizeLabel.isHidden = true
                aspectRatioLabel.text = "W: 0.0, H: 0.0, Ratio: 1.0"
                currentSizeLabel.text = "W: 40.0, H: 40.0"
            }
        }
        get { return _widget }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let widget = self.widget {
            currentSizeLabel.text = String(format: "W: %.1f, H: %.1f", widget.view.frame.size.width, widget.view.frame.size.height)
        }
    }
    
    public func configureFPV() {
        self.videoView = UIView()
        if let nonNillWidgetView = widget?.view {
            self.view.insertSubview(self.videoView, belowSubview: nonNillWidgetView)
            self.videoView.backgroundColor = UIColor.black
            self.videoView.translatesAutoresizingMaskIntoConstraints = false
            self.videoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            self.videoView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            self.videoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            self.videoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }
    }
    
    public func configureBarPanel() {
        let testOrientation: DUXBetaPanelVariant = .horizontal
        var panelWidth: CGFloat = 400.0
        var panelHeight: CGFloat = 20.0
        if (testOrientation == .vertical) {
            panelWidth = 30.0
            panelHeight = 300.0
        }
        if let panelWidget = widget as? DUXBetaBarPanelWidget {
            panelWidget.view.widthAnchor.constraint(equalToConstant: panelWidth).isActive = true
            panelWidget.view.heightAnchor.constraint(equalToConstant: panelHeight).isActive = true
            let configSettings = DUXBetaPanelWidgetConfiguration(type: .bar, variant: testOrientation)
            let _ = panelWidget.configure(configSettings);

            let remoteControllerSignalWidget = DUXBetaRemoteControllerSignalWidget()
            panelWidget.addWidgetArray([DUXBetaVisionWidget(), DUXBetaFlightModeWidget(), DUXBetaGPSSignalWidget(), remoteControllerSignalWidget, DUXBetaVideoSignalWidget() ] )
            
            panelWidget.view.constraints.forEach { (constraint) in
                if (testOrientation == .horizontal) {
                    if constraint.firstAttribute == .height {
                        constraint.constant = constraint.constant * 2.0
                    }
                } else {
                    if constraint.firstAttribute == .width {
                        constraint.constant = constraint.constant * 2.0
                    }
                }
            }
        }
    }
    
    public func configureToolbarPanel() {
        if let panelWidget = widget as? DUXBetaToolbarPanelWidget {
            let configSettingsMain = DUXBetaPanelWidgetConfiguration(type:.toolbar, variant:.right)
                    .configureToolbar(dimension:64.0)
                    .configureTitlebar(visible: true, withCloseBox: true, title: "Top Title")

            let configSettingsSubpanel = DUXBetaPanelWidgetConfiguration(type:.toolbar, variant:.top)
                    .configureToolbar(dimension:64.0)
                    .configureTitlebar(visible: true, withCloseBox: false, title: "Inner Tool Bar")

            _ = panelWidget.configure(configSettingsMain)
            
            configSettingsMain.panelToolbarColor = UIColor.yellow
    
            enum DUXBetaToolbarPanelTestSelection : Int {
                case templates
                case widgets
            }
            
            var whichTest: DUXBetaToolbarPanelTestSelection = .widgets
            
            switch whichTest {
            case .templates:
                let aTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaRTKWidget",
                                                             icon: UIImage.duxbeta_image(withAssetNamed: "ColorMonitorYNor"),
                                                            title:"RTK")
                let bTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaSpotlightControlWidget",
                                                             icon: UIImage.duxbeta_image(withAssetNamed: "BeaconActive"),
                                                             title:"Spotlight")
                panelWidget.addPanelToolsArray([aTemplate, bTemplate])
                panelWidget.view.heightAnchor.constraint(equalToConstant:300).isActive = true;
                panelWidget.view.widthAnchor.constraint(equalToConstant:400).isActive = true;

                let cTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaRTKWidget",
                                                             icon: UIImage.duxbeta_image(withAssetNamed: "ColorMonitorYNor"),
                                                             title:"Second RTK")
                panelWidget.insert(itemTemplate:cTemplate, atIndex:1)

                Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { timer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        let dTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaRTKWidget",
                                                                     icon: UIImage.duxbeta_image(withAssetNamed: "ColorMonitorYNor"),
                                                                    title:"RTK3")
                        panelWidget.insert(itemTemplate: dTemplate, atIndex: 1)
                        panelWidget.removeAllWidgets()
                    }
                }
            case .widgets:
                let level2PanelA = DUXBetaToolbarPanelWidget(variant:configSettingsSubpanel.widgetVariant).configure(configSettingsSubpanel)
                level2PanelA.toolbarImage = UIImage.duxbeta_image(withAssetNamed: "ColorMonitorYNor")
                level2PanelA.toolbarItemName = "Subbar"
                
                panelWidget.addWidgetArray([level2PanelA, DUXBetaRTKSatelliteStatusWidget(), DUXBetaSpotlightControlWidget(), DUXBetaSpeakerControlWidget()])
            
                Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { timer in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
                        panelWidget.insert(widget: DUXBetaSpotlightControlWidget(), atIndex: 1)
                        panelWidget.removeWidget(atIndex: 2)

                    }
                }
            }
        }
    }

    public func configureListPanel() {
        if let listPanel = widget as? DUXBetaListPanelWidget {
            _ = listPanel.configure( DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
                .configureTitlebar(visible: true, withCloseBox: true, title: "My First List"))

            var constraint = listPanel.view.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true

            constraint = listPanel.view.widthAnchor.constraint(greaterThanOrEqualToConstant: listPanel.widgetSizeHint.minimumWidth*1.5)
            constraint.priority = .required
            constraint.isActive = true

            constraint = listPanel.view.heightAnchor.constraint(greaterThanOrEqualToConstant: listPanel.widgetSizeHint.minimumHeight)
            constraint.priority = .required
            constraint.isActive = true

            let widget1 = DUXBetaListItemEditTextButtonWidget(.onlyEdit)
            widget1.setEditText("125")
            widget1.setButtonTitle("Push Me")
            widget1.hintText = "(25-500m)"
            widget1.setTitle("Test Edit", andIconName: "ChecklistHeightLimit")
            
            let widget1_5 = DUXBetaListItemEditTextButtonWidget(.editAndButton)
            widget1_5.setEditText("75")
            widget1_5.setButtonTitle("Push Me")
            widget1_5.hintText = "(25-500m)"
            widget1_5.setTitle("Test Edit", andIconName: "ChecklistHeightLimit")

            
            let widget2 = DUXBetaListItemLabelButtonWidget(.buttonOnly)
            widget2.setButtonTitle("Push Me")
            widget2.setTitle("Test Button", andIconName: "ChecklistHeightLimit")
            
            let widget3 = DUXBetaListItemLabelButtonWidget(.labelOnly)
            widget3.setLabelText("Normal")
            widget3.setTitle("Test Button", andIconName: "ChecklistHeightLimit")

            let widget4 = DUXBetaListItemLabelButtonWidget(.labelAndButton)
            widget4.setButtonTitle("Push You")
            widget4.setLabelText("Good")
            widget4.setTitle("Test Button", andIconName: "ChecklistHeightLimit")

            listPanel.addWidgetArray([widget1,
                                      widget1_5,
                                      widget2,
                                      widget3,
                                      widget4
                                    ])
        }
    }
    
    public func configureListItemRadiosButtonWidget() {
        if let radioWidget = widget as? DUXBetaListItemRadioButtonWidget {
            radioWidget.setOptionTitles(["One", "Two", "Three" ])
        }
    }
    
    public func configureGenericOptionSwitchWidget() {
        if let switchWidget = widget as? DUXBetaListItemTrivialSwitchWidget {
            let genericKey = DJIFlightControllerKey(param:DJIFlightControllerParamNoviceModeEnabled)
            switchWidget.setTitle("Enable Novice Mode", andKey:genericKey!)
        }
    }

    func configureConstraints() {
        if let widget = self.widget {
            
            widget.view.translatesAutoresizingMaskIntoConstraints = false
            
            widget.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            if let rtkWidget = widget as? DUXBetaRTKWidget {
                rtkWidget.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            } else {
                widget.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            }
            
            
            var constraint = widget.view.widthAnchor.constraint(lessThanOrEqualTo: self.view.widthAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true
            
            if let _ = widget as? DUXBetaPanelWidget {
                // No height/width constraint. The DUXBetaPanelWidget sets it's own and is hyper flexible
                // The DUXBetaToolbarPanelWidget may need constraints set depending on how it is constructed.
                // More analysis and documentation to come
            }
            constraint = widget.view.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.95)
            constraint.priority = .required
            constraint.isActive = true
            
            if let _ = widget as? DUXBetaPanelWidget {
                // No absolute constraints for the DUXBetaPanelWidget
            } else {
                // This is required for pinch to resize to work
                if !(widget.isKind(of: DUXBetaRTKSatelliteStatusWidget.self) || widget.isKind(of: DUXBetaRTKWidget.self)) {
                    self.heightConstraint = widget.view.heightAnchor.constraint(equalToConstant: widget.widgetSizeHint.minimumHeight)
                    self.heightConstraint?.priority = .required
                    self.heightConstraint?.isActive = true
                }
            }
        }
    }
    
    @IBAction func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if let hc = self.heightConstraint {
            if (recognizer.state == .began) {
                self.pinchStartHeight = hc.constant
            }
            hc.constant = self.pinchStartHeight * recognizer.scale
            self.view.setNeedsLayout()
        }
    }
    
    @IBAction func doubleTap(recognizer: UITapGestureRecognizer) {
        if let nonNilWidget = _widget {
            if nonNilWidget.view.layer.borderWidth == 0 {
                recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: true, level: 0)
            } else {
                recursivelySetBorderForView(view: nonNilWidget.view, borderEnabled: false, level: 0)
            }
        }
    }
    private let colors: [UIColor] = [UIColor.red,
                                     UIColor.green,
                                     UIColor.blue,
                                     UIColor.orange,
                                     UIColor.yellow,
                                     UIColor.magenta,
                                     UIColor.cyan,
                                     UIColor.purple,
                                     UIColor.brown]
    func recursivelySetBorderForView(view: UIView, borderEnabled: Bool, level: Int) {
        if !view.layer.isKind(of: CATransformLayer.self) {
            if (borderEnabled) {
                view.layer.borderColor = colors[level % colors.count].cgColor
                view.layer.borderWidth = 1
            } else {
                view.layer.borderColor = UIColor.clear.cgColor
                view.layer.borderWidth = 0
            }
        }
    
        for sv in view.subviews {
            recursivelySetBorderForView(view: sv, borderEnabled: borderEnabled, level: level + 1)
        }
    }
    
    func closeButtonPressed(for widget: DUXBetaBaseWidget!) {
        self.widget?.removeFromParent()
        self.widget?.view.removeFromSuperview()
    }
    
    func currentScreenChanged(to newScreen: DUXBetaBaseWidget) {
        if let widget = self.widget {
            widget.view.removeConstraints(widget.view.constraints)
        }
        self.configureConstraints()
    }
    
    func batteryWidgetChangedDisplayState(_ newState: DUXBetaBatteryWidgetDisplayState) {
        if let widget = self.widget {
            widget.view.removeConstraints(widget.view.constraints)
        }
        self.configureConstraints()
    }
}

extension InternalSingleWidgetViewController: InternalWidgetSelectionDelegate {
    func widgetSelected(_ newWidget: DUXBetaBaseWidget?) {
        widget = newWidget
    }
}
