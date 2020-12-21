//
//  DefaultLayoutViewController.swift
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

/**
 This is a version of the FullDefaultLayoutViewController from the old SDKTestApp with
 some major changes. This class is not derived from DUXBetaDefaultLayoutViewController.
 The plan is for this to be a flat development class where widgets can be placed and positioned
 as needed. It is an experimental playground during development. Once a more solidified layout
 is defined, we can create a new class to finalize into.
 As we define widgets for the OS release, we will be experimenting and finding better patterns
 for placement. At this point we don't want to define strict layout hierarchies yet.
 */
import UIKit
import DJIUXSDKBeta

class DefaultLayoutViewController : UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let rootView = UIView()
    var topBar: DUXBetaBarPanelWidget?
    var remainingFlightTimeWidget: DUXBetaRemainingFlightTimeWidget?
    var fpvWidget: DUXBetaFPVWidget?
    var compassWidget: DUXBetaCompassWidget?
    var telemetryPanel: DUXBetaTelemetryPanelWidget?
    var systemStatusListPanel: DUXBetaListPanelWidget?
    var fpvCustomizationPanel: DUXBetaListPanelWidget?
    var currentMainViewWidget : DUXBetaBaseWidget?

    override var prefersStatusBarHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(rootView)
        
        view.backgroundColor = UIColor.uxsdk_black()
        
        rootView.translatesAutoresizingMaskIntoConstraints = false
        let statusBarInsets = UIApplication.shared.keyWindow!.safeAreaInsets
        var edgeInsets: UIEdgeInsets
        if #available(iOS 11, * ) {
            edgeInsets = view.safeAreaInsets
            edgeInsets.top += statusBarInsets.top
            edgeInsets.left += statusBarInsets.left
            edgeInsets.bottom += statusBarInsets.bottom
            edgeInsets.right += statusBarInsets.right
        } else {
            edgeInsets = UIEdgeInsets(top: statusBarInsets.top, left: statusBarInsets.left, bottom: statusBarInsets.bottom, right: statusBarInsets.right)
        }
        
        rootView.topAnchor.constraint(equalTo:view.topAnchor, constant:edgeInsets.top).isActive = true
        rootView.leftAnchor.constraint(equalTo:view.leftAnchor, constant:edgeInsets.left).isActive = true
        rootView.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant:-edgeInsets.bottom).isActive = true
        rootView.rightAnchor.constraint(equalTo:view.rightAnchor, constant:-edgeInsets.right).isActive = true

        setupTopBar()
        setupFPVWidget()
        setupTelemetryPanel()
        setupRemainingFlightTimeWidget()
        setupRTKWidget()
        setupLeftPanel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DUXBetaStateChangeBroadcaster.instance().unregisterListener(self)
        
        super.viewDidDisappear(animated)
    }
    
    @IBAction func close () {
        dismiss(animated: true) {
            DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
        }
    }
        
    // Method for setting up the top bar. We may want to refactor this into another file at some point
    // but for now, let's use this as out basic playground file. We are designing for lower complexity
    // if possible than having multiple view containers defined in other classes and getting attached.
    func setupTopBar() {
        let topBarWidget = DUXBetaTopBarWidget()
        
        let logoBtn = UIButton()
        logoBtn.translatesAutoresizingMaskIntoConstraints = false
        logoBtn.setImage(UIImage.init(named: "Close"), for: .normal)
        logoBtn.imageView?.contentMode = .scaleAspectFit
        logoBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(logoBtn)
                
        let customizationsBtn = UIButton()
        customizationsBtn.translatesAutoresizingMaskIntoConstraints = false
        customizationsBtn.setImage(UIImage.init(named: "Wrench"), for: .normal)
        customizationsBtn.imageView?.contentMode = .scaleAspectFit
        customizationsBtn.addTarget(self, action: #selector(setupFPVCustomizationPanel), for: .touchUpInside)
        view.addSubview(customizationsBtn)
        
        topBarWidget.install(in: self)
        
        let margin: CGFloat = 5.0
        let height: CGFloat = 28.0
        NSLayoutConstraint.activate([
            logoBtn.leftAnchor.constraint(equalTo: rootView.leftAnchor),
            logoBtn.topAnchor.constraint(equalTo: rootView.topAnchor, constant: margin),
            logoBtn.heightAnchor.constraint(equalToConstant: height - 2 * margin),
          
            topBarWidget.view.trailingAnchor.constraint(equalTo: customizationsBtn.leadingAnchor),
            topBarWidget.view.leadingAnchor.constraint(equalTo: logoBtn.trailingAnchor),
            topBarWidget.view.topAnchor.constraint(equalTo: rootView.topAnchor),
            topBarWidget.view.heightAnchor.constraint(equalToConstant: height),
            
            customizationsBtn.topAnchor.constraint(equalTo: rootView.topAnchor, constant: margin),
            customizationsBtn.heightAnchor.constraint(equalToConstant: height - 2 * margin),
            customizationsBtn.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])
        
        topBar = topBarWidget
        topBar?.topMargin = margin
        topBar?.rightMargin = margin
        topBar?.bottomMargin = margin
        topBar?.leftMargin = margin

        DUXBetaStateChangeBroadcaster.instance().registerListener(self, analyticsClassName: "SystemStatusUIState") { [weak self] (analyticsData) in
            DispatchQueue.main.async {
                if let weakSelf = self {
                    if let list = weakSelf.systemStatusListPanel {
                        list.closeTapped()
                        weakSelf.systemStatusListPanel = nil
                    } else {
                        weakSelf.setupSystemStatusList()
                    }
                }
            }
        }
    }
    
    func setupRemainingFlightTimeWidget() {
        let remainingFlightTimeWidget = DUXBetaRemainingFlightTimeWidget()
        
        remainingFlightTimeWidget.install(in: self)
        
        NSLayoutConstraint.activate([
            remainingFlightTimeWidget.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            remainingFlightTimeWidget.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            remainingFlightTimeWidget.view.centerYAnchor.constraint(equalTo: topBar?.view.bottomAnchor ?? rootView.topAnchor, constant: 3.0)
        ])

        self.remainingFlightTimeWidget = remainingFlightTimeWidget
    }
    
    func setupLeftPanel() {
        let leftBarWidget = DUXBetaFreeformPanelWidget()
        var configuration = DUXBetaPanelWidgetConfiguration(type: .freeform, variant: .freeform)
        configuration = configuration.configureColors(background: .uxsdk_clear())
        _ = leftBarWidget.configure(configuration)
        
        leftBarWidget.install(in: self)

        NSLayoutConstraint.activate([
            leftBarWidget.view.topAnchor.constraint(equalTo: topBar?.view.bottomAnchor ?? rootView.topAnchor),
            leftBarWidget.view.bottomAnchor.constraint(equalTo: telemetryPanel?.view.topAnchor ?? rootView.bottomAnchor),
            leftBarWidget.view.leftAnchor.constraint(equalTo: (compassWidget?.view ?? rootView).leftAnchor),
            leftBarWidget.view.rightAnchor.constraint(equalTo: rootView.leftAnchor, constant: 64.0)
        ])
        
        let newPanes = leftBarWidget.splitPane(leftBarWidget.rootPane(), along: .vertical, proportions: [0.25, 0.25, 0.25, 0.25])

        DUXBetaTakeOffWidget().install(in: leftBarWidget, pane: newPanes[1], position: .centered)
        DUXBetaReturnHomeWidget().install(in: leftBarWidget, pane: newPanes[2], position: .centered)
    }
    
    func setupSystemStatusList() {
        let listPanel = DUXBetaSystemStatusListWidget()
        listPanel.onCloseTapped( { [weak self] listPanel in
            guard let self = self else { return }
            if listPanel == self.systemStatusListPanel {
                self.systemStatusListPanel = nil
            }
        })
        listPanel.install(in: self) // Very important to use this method
        
        listPanel.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        listPanel.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        listPanel.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier:0.6).isActive = true
        listPanel.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        systemStatusListPanel = listPanel
    }
    
    func setupMainViewConstraints(widget: DUXBetaBaseWidget) {
        NSLayoutConstraint.activate([
            widget.view.topAnchor.constraint(equalTo: topBar?.view.bottomAnchor ?? view.topAnchor),
            widget.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            widget.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            widget.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func setupFPVWidget() {
        let fpvWidget = DUXBetaFPVWidget()
        
        fpvWidget.install(in: self)
        
        setupMainViewConstraints(widget: fpvWidget)
        
        self.fpvWidget = fpvWidget
        currentMainViewWidget = fpvWidget

    }
    
    func setupRTKWidget() {
        let rtkWidget = DUXBetaRTKWidget()
        rtkWidget.view.translatesAutoresizingMaskIntoConstraints = false
        rtkWidget.install(in: self)
        
        if let topBar = topBar {
            rtkWidget.view.topAnchor.constraint(equalTo: topBar.view.bottomAnchor).isActive = true
        } else {
            rtkWidget.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 44.0).isActive = true
        }
        if let telemetryPanel = telemetryPanel {
            if UIDevice.current.userInterfaceIdiom == .phone {
                rtkWidget.view.bottomAnchor.constraint(equalTo: telemetryPanel.view.bottomAnchor).isActive = true
            } else {
                rtkWidget.view.bottomAnchor.constraint(equalTo: telemetryPanel.view.topAnchor).isActive = true
            }
        } else {
            rtkWidget.view.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
        }
        rtkWidget.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func setupTelemetryPanel() {
        let compassWidget = DUXBetaCompassWidget()
        let telemetryPanel = DUXBetaTelemetryPanelWidget()
        var configuration = DUXBetaPanelWidgetConfiguration(type: .freeform, variant: .freeform)
        configuration = configuration.configureColors(background: .uxsdk_clear())
        _ = telemetryPanel.configure(configuration)
        
        let leftMarginLayoutGuide = UILayoutGuide.init()
        view.addLayoutGuide(leftMarginLayoutGuide)
        
        let bottomMarginLayoutGuide = UILayoutGuide.init()
        view.addLayoutGuide(bottomMarginLayoutGuide)
        
        compassWidget.install(in: self)
        telemetryPanel.install(in: self)
        
        let backgroundView = telemetryPanel.backgroundViewForPane(0)
        backgroundView?.backgroundColor = .uxsdk_blackAlpha50()
        backgroundView?.layer.cornerRadius = 5.0
        
        NSLayoutConstraint.activate([
            leftMarginLayoutGuide.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.015),
            leftMarginLayoutGuide.leftAnchor.constraint(equalTo: view.leftAnchor),
            leftMarginLayoutGuide.rightAnchor.constraint(equalTo: compassWidget.view.leftAnchor),
            
            bottomMarginLayoutGuide.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.04),
            bottomMarginLayoutGuide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomMarginLayoutGuide.topAnchor.constraint(equalTo: compassWidget.view.bottomAnchor),
            
            compassWidget.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.116),
            compassWidget.view.widthAnchor.constraint(equalTo: compassWidget.view.heightAnchor, multiplier: compassWidget.widgetSizeHint.preferredAspectRatio),
            
            telemetryPanel.view.leftAnchor.constraint(equalTo: compassWidget.view.rightAnchor),
            telemetryPanel.view.centerYAnchor.constraint(equalTo: compassWidget.view.centerYAnchor),
            telemetryPanel.view.heightAnchor.constraint(equalTo: compassWidget.view.heightAnchor, multiplier: 1.2),
            telemetryPanel.view.widthAnchor.constraint(equalTo: telemetryPanel.view.heightAnchor,
                                                     multiplier: telemetryPanel.widgetSizeHint.preferredAspectRatio)
        ])
        
        self.compassWidget = compassWidget
        self.telemetryPanel = telemetryPanel
    }
    
    @objc func setupFPVCustomizationPanel() {
        if let _ = fpvCustomizationPanel {
            fpvCustomizationPanel?.closeTapped()
        }
        
        let listPanel = DUXBetaListPanelWidget()
        _ = listPanel.configure(DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: "FPV Customizations"))

        listPanel.onCloseTapped({ [weak self] inPanel in
            guard let self = self else { return }
            self.fpvCustomizationPanel = nil;
        })
        listPanel.install(in: self)
        
        NSLayoutConstraint.activate([
            listPanel.view.heightAnchor.constraint(greaterThanOrEqualToConstant: listPanel.widgetSizeHint.minimumHeight),
            listPanel.view.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.7),
            listPanel.view.widthAnchor.constraint(greaterThanOrEqualToConstant: listPanel.widgetSizeHint.minimumWidth),
            listPanel.view.topAnchor.constraint(equalTo: topBar?.view.bottomAnchor ?? view.topAnchor),
            listPanel.view.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])

        let cameraNameVisibility = FPVCameraNameVisibilityWidget()
        cameraNameVisibility.setTitle("Camera Name Visibility", andIconName: nil)
        cameraNameVisibility.fpvWidget = fpvWidget
        
        let cameraSideVisibility = FPVCameraSideVisibilityWidget()
        cameraSideVisibility.setTitle("Camera Side Visibility", andIconName: nil)
        cameraSideVisibility.fpvWidget = fpvWidget
        
        let gridlinesVisibility = FPVGridlineVisibilityWidget()
        gridlinesVisibility.setTitle("Gridlines Visibility", andIconName: nil)
        gridlinesVisibility.fpvWidget = fpvWidget
        
        let gridlinesType = FPVGridlineTypeWidget()
        gridlinesType.setTitle("Gridlines Type", andIconName: nil)
        gridlinesType.fpvWidget = fpvWidget
        
        let centerImageVisibility = FPVCenterViewVisibilityWidget()
        centerImageVisibility.setTitle("CenterPoint Visibility", andIconName: nil)
        centerImageVisibility.fpvWidget = fpvWidget
        
        let centerImageType = FPVCenterViewTypeWidget()
        centerImageType.setTitle("CenterPoint Type", andIconName: nil)
        centerImageType.fpvWidget = fpvWidget
        
        let centerImageColor = FPVCenterViewColorWidget()
        centerImageColor.setTitle("CenterPoint Color", andIconName: nil)
        centerImageColor.fpvWidget = fpvWidget
        
        let hardwareDecodeWidget = DUXBetaListItemSwitchWidget()
        hardwareDecodeWidget.setTitle("Enable Hardware Decode", andIconName: nil)
        hardwareDecodeWidget.onOffSwitch.isOn = fpvWidget?.enableHardwareDecode ?? false
        hardwareDecodeWidget.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.enableHardwareDecode = enabled
        }
        
        let fpvFeedCustomization = FPVVideoFeedWidget().setTitle("Video Feed", andIconName: nil)
        fpvFeedCustomization.fpvWidget = fpvWidget
        
        listPanel.addWidgetArray([
                                hardwareDecodeWidget,
                                fpvFeedCustomization,
                                cameraNameVisibility,
                                cameraSideVisibility,
                                gridlinesVisibility,
                                gridlinesType,
                                centerImageVisibility,
                                centerImageType,
                                centerImageColor])
        fpvCustomizationPanel = listPanel
    }
}
