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
import DJIUXSDK

#if canImport(Forge)
    import Forge
#endif

class DefaultLayoutViewController : UIViewController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    let rootView = UIView()
    var topBarWidget: DUXBetaTopBarWidget?
    var remainingFlightTimeWidget: DUXBetaRemainingFlightTimeWidget?
    var fpvWidget: DUXBetaFPVWidget?
    var compassWidget: DUXBetaCompassWidget?
    var telemetryPanel: DUXBetaTelemetryPanelWidget?
    var systemStatusListPanel: DUXBetaListPanelWidget?
    var fpvCustomizationPanel: DUXBetaListPanelWidget?
    var telemetryCustomizationPanel: DUXBetaListPanelWidget?
    var currentMainViewWidget : DUXBetaBaseWidget?
    var radarWidget : DUXBetaRadarWidget?

#if canImport(Forge)
    var forgeController: DJIForgeController?
    var forgeDisplay: DJIForgeDisplayWidget?
#endif
    var pipPanel: PictureInPicturePanelWidget?
    

    var topBarRightConstraint: NSLayoutConstraint?

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

        setupCoreWidgets()
        setupAccessoryWidgets()
        setupFlightWidgets()
        setupCameraCoreWidgets()
        setupRadarWidget()
//        setupToolbarWidget()

#if canImport(Forge)
        setupPIP()
        setupForge()
#endif
        
        setupTempTestWidgets()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DUXBetaStateChangeBroadcaster.instance().unregisterListener(self)
        
        super.viewDidDisappear(animated)
    }
    
    @IBAction func close() {
        dismiss(animated: true) {
            DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
        }
    }
    
    func setupCoreWidgets() {
        setupTopBar()
        setupFPVWidget()
        setupTelemetryPanel()
        setupRemainingFlightTimeWidget()
    }
    
    func setupFlightWidgets() {
        setupLeftPanel()
    }
    
    func setupAccessoryWidgets() {
        setupRTKWidget()
    }
    
    func setupCameraCoreWidgets() {
        setupRightPanel()
    }
    
    // MARK: - Core Widgets
    
    // Method for setting up the top bar. We may want to refactor this into another file at some point
    // but for now, let's use this as out basic playground file. We are designing for lower complexity
    // if possible than having multiple view containers defined in other classes and getting attached.
    fileprivate func setupTopBar() {
        let topBarWidget = DUXBetaTopBarWidget()
        
        let logoBtn = UIButton()
        logoBtn.translatesAutoresizingMaskIntoConstraints = false
        logoBtn.setImage(UIImage.init(named: "Close"), for: .normal)
        logoBtn.imageView?.contentMode = .scaleAspectFit
        logoBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        view.addSubview(logoBtn)
        
        topBarWidget.install(in: self)
        
        let margin: CGFloat = 5.0
        let height: CGFloat = 28.0
        
        topBarRightConstraint = topBarWidget.view.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -margin)
        NSLayoutConstraint.activate([
            logoBtn.leftAnchor.constraint(equalTo: rootView.leftAnchor),
            logoBtn.topAnchor.constraint(equalTo: rootView.topAnchor, constant: margin),
            logoBtn.heightAnchor.constraint(equalToConstant: height - 2 * margin),
          
            topBarRightConstraint!,
            topBarWidget.view.leadingAnchor.constraint(equalTo: logoBtn.trailingAnchor),
            topBarWidget.view.topAnchor.constraint(equalTo: rootView.topAnchor),
            topBarWidget.view.heightAnchor.constraint(equalToConstant: height)
        ])
        
        topBarWidget.topMargin = margin
        topBarWidget.rightMargin = margin
        topBarWidget.bottomMargin = margin
        topBarWidget.leftMargin = margin
        self.topBarWidget = topBarWidget

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
    
    fileprivate func setupRemainingFlightTimeWidget() {
        let remainingFlightTimeWidget = DUXBetaRemainingFlightTimeWidget()
        
        remainingFlightTimeWidget.install(in: self)
        
        NSLayoutConstraint.activate([
            remainingFlightTimeWidget.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            remainingFlightTimeWidget.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            remainingFlightTimeWidget.view.centerYAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? rootView.topAnchor, constant: 3.0)
        ])

        self.remainingFlightTimeWidget = remainingFlightTimeWidget
    }
    
    fileprivate func setupSystemStatusList() {
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
    
    fileprivate func setupMainViewConstraints(widget: DUXBetaBaseWidget) {
        NSLayoutConstraint.activate([
            widget.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? view.topAnchor),
            widget.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            widget.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            widget.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    fileprivate func setupFPVWidget() {
        let fpvWidget = DUXBetaFPVWidget()
        
        fpvWidget.install(in: self)
        
        setupMainViewConstraints(widget: fpvWidget)
        
        self.fpvWidget = fpvWidget
        currentMainViewWidget = fpvWidget
    }
    
    fileprivate func setupTelemetryPanel() {
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

    func setupRadarWidget() {
        radarWidget = DUXBetaRadarWidget()
        
        if let radarWidget = radarWidget {
            radarWidget.install(in: self)
            radarWidget.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            radarWidget.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            radarWidget.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.5).isActive = true
        }
    }
    
    func setupPIP() {
        pipPanel = PictureInPicturePanelWidget() //DUXBetaFreeformPanelWidget()
        if let pipPanel = pipPanel {
            _ = pipPanel.configure(DUXBetaPanelWidgetConfiguration(type: .freeform, variant: .freeform))
            pipPanel.install(in: self)
            pipPanel.enablePaneDebug(assist: true)
            
            let mapWidget: DUXBetaMapWidget? = nil  // DUXBetaMapWidget()
            mapWidget?.showFlyZoneLegend = false
            
            let pipPaneWidth: CGFloat = 150.0
            let pipPaneHeight: CGFloat = 105.0
            let pipViewsX: CGFloat = 2.0
            let pipViewsY: CGFloat = 1.0
            
            NSLayoutConstraint.activate([
                pipPanel.view.trailingAnchor.constraint(equalTo:view.trailingAnchor, constant: -20.0),
                pipPanel.view.bottomAnchor.constraint(equalTo:view.bottomAnchor, constant: -20.0),
                pipPanel.view.widthAnchor.constraint(equalToConstant: pipPaneWidth * pipViewsX),
                pipPanel.view.heightAnchor.constraint(equalToConstant: pipPaneHeight * pipViewsY)
            ])
            
            let mainPanes = pipPanel.splitPane(pipPanel.rootPane(), along: .horizontal, proportions: [0.5, 0.5])
            // Once mapWidget works correctly, add it in here.
            if let mapWidget = mapWidget {
                mapWidget.install(in: pipPanel, pane: mainPanes[1], position: .centered)
            }
            
            pipPanel.installSwapTapNotificationHandler( { [weak self] paneID in
                if let self = self {
                    if let newDisplayWidget = pipPanel.swapWidget(paneID, fromController:self, widget:self.currentMainViewWidget) {
                        
                        self.currentMainViewWidget = newDisplayWidget
                        DispatchQueue.main.async {
                            self.setupMainViewConstraints(widget: newDisplayWidget);
                        }
                    }
                }
            })
        }
    }
    

#if canImport(Forge)
    func setupForge() {
        guard let _ = NSClassFromString("DJIForgeController") else { print("SDL Forge not loadded")
            return }
        
        forgeController = DJIForgeController(modules: ["DJIForgeModule"])
        if let forgeController = forgeController {
            forgeController.startForge()
            
            forgeDisplay = DJIForgeDisplayWidget()
            if let forgeDisplay = forgeDisplay {
                forgeController.setOutputView(forgeDisplay.displayView)
                
                
                if let pipPanel = pipPanel {
                    forgeDisplay.install(in: pipPanel, pane: 1, position: .bottomTrailing)
                    forgeController.setOutputView(forgeDisplay.displayView)
                }
            }
        }
    }
#endif
    

    // MARK: - Flight Widgets
    
    fileprivate func setupLeftPanel() {
        let leftBarWidget = DUXBetaFreeformPanelWidget()
        var configuration = DUXBetaPanelWidgetConfiguration(type: .freeform, variant: .freeform)
        configuration = configuration.configureColors(background: .uxsdk_clear())
        _ = leftBarWidget.configure(configuration)
        
        leftBarWidget.install(in: self)

        NSLayoutConstraint.activate([
            leftBarWidget.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? rootView.topAnchor),
            leftBarWidget.view.bottomAnchor.constraint(equalTo: telemetryPanel?.view.topAnchor ?? rootView.bottomAnchor),
            leftBarWidget.view.leftAnchor.constraint(equalTo: (compassWidget?.view ?? rootView).leftAnchor),
            leftBarWidget.view.rightAnchor.constraint(equalTo: rootView.leftAnchor, constant: 64.0)
        ])
        
        let newPanes = leftBarWidget.splitPane(leftBarWidget.rootPane(), along: .vertical, proportions: [0.25, 0.25, 0.25, 0.25])

        DUXBetaTakeOffWidget().install(in: leftBarWidget, pane: newPanes[1], position: .centered)
        DUXBetaReturnHomeWidget().install(in: leftBarWidget, pane: newPanes[2], position: .centered)
    }
    
    // MARK: - Accessory Widgets
    
    fileprivate func setupRTKWidget() {
        let rtkWidget = DUXBetaRTKWidget()
        rtkWidget.view.translatesAutoresizingMaskIntoConstraints = false
        rtkWidget.install(in: self)
        
        if let topBar = topBarWidget {
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
    
    // MARK: - Camera Core Widgets
    
    fileprivate func setupRightPanel() {
        let rightBarWidget = DUXBetaFreeformPanelWidget()
        var configuration = DUXBetaPanelWidgetConfiguration(type: .freeform, variant: .freeform)
        configuration = configuration.configureColors(background: .uxsdk_clear())
        _ = rightBarWidget.configure(configuration)
        
        rightBarWidget.install(in: self)

        NSLayoutConstraint.activate([
            rightBarWidget.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? rootView.topAnchor),
            rightBarWidget.view.bottomAnchor.constraint(equalTo: telemetryPanel?.view.topAnchor ?? rootView.bottomAnchor),
            rightBarWidget.view.rightAnchor.constraint(equalTo: rootView.rightAnchor, constant: -20),
            rightBarWidget.view.widthAnchor.constraint(equalToConstant: 64.0)
        ])
        
        let newPanes = rightBarWidget.splitPane(rightBarWidget.rootPane(), along: .vertical, proportions: [0.20, 0.20, 0.20, 0.20, 0.20])

        DUXBetaPhotoVideoSwitchWidget().install(in: rightBarWidget, pane: newPanes[1], position: .centered)
        DUXBetaCaptureWidget().install(in: rightBarWidget, pane: newPanes[2], position: .centered)
        DUXBetaCameraSettingsIndicatorWidget().install(in: rightBarWidget, pane: newPanes[3], position: .centered)
    }
    
    fileprivate func setupToolbarWidget() {
        let configSettingsMain = DUXBetaPanelWidgetConfiguration(type:.toolbar, variant:.top)
            .configureToolbar(dimension:72.0)
            .configureTitlebar(visible: true, withCloseBox: true, title: "Top Title")
            .configureColors(selection: .red )//.uxsdk_selectedBlue())

        let panelWidget = DUXBetaToolbarPanelWidget()

        panelWidget.install(in: self)
        NSLayoutConstraint.activate([
            panelWidget.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80.0),
            panelWidget.view.widthAnchor.constraint(equalToConstant: 400.0),
            panelWidget.view.heightAnchor.constraint(equalToConstant: 500.0),
            panelWidget.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -100.0)
        ])
        _ = panelWidget.configure(configSettingsMain)
            
        let configSettingsSubpanel = DUXBetaPanelWidgetConfiguration(type:.toolbar, variant:.top)
            .configureToolbar(dimension:64.0)
            .configureTitlebar(visible: true, withCloseBox: false, title: "Inner Tool Bar")
                
        configSettingsMain.panelToolbarColor = UIColor.yellow
        
        
        let aTemplate =  DUXBetaToolbarPanelItemTemplate(className: "UXSDKCore.DUXBetaTelemetryPanelWidget",
                                                         icon: nil /*UIImage(named: "Test"),*/,
                                                         title:"Telelmetry", highlightStyle: .fill)
        let bTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaCompassWidget",
                                                         icon: UIImage(named: "HomePoint"),
                                                         title:"RTK", highlightStyle: .edges)
        panelWidget.addPanelToolsArray([aTemplate, bTemplate])
//        panelWidget.view.heightAnchor.constraint(equalToConstant:300).isActive = true;
//        panelWidget.view.widthAnchor.constraint(equalToConstant:400).isActive = true;
        
        let cTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaCompassWidget",
                                                         icon: UIImage(named: "Wrench"),
                                                         title: nil/*"Compass"*/, highlightStyle: .underline)
       panelWidget.insert(itemTemplate:cTemplate, atIndex:1)
        
        Timer.scheduledTimer(withTimeInterval: 20.0, repeats: false) { timer in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
//                let dTemplate =  DUXBetaToolbarPanelItemTemplate(className: "DUXBetaRTKWidget",
//                                                                 icon: UIImage(named: "HomePoint"),
//                                                                 title:"RTK3")
//                panelWidget.insert(itemTemplate: dTemplate, atIndex: 1)
//                panelWidget.removeAllWidgets()
            }
        }
        
    }
    
    func setupTempTestWidgets() {
        let testBaseCamConfig = DUXBetaCameraConfigShutterWidget()
        testBaseCamConfig.install(in: self)
        
        testBaseCamConfig.view.topAnchor.constraint(equalTo: (topBarWidget?.view.bottomAnchor)!, constant: 20.0).isActive = true
        testBaseCamConfig.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -200.0).isActive = true
        
        if let radarWidget = radarWidget {
        //        radarWidget?.distanceTextColor = UIColor.green
        //        radarWidget?.distanceTextBackgroundColor = UIColor.red
        //        radarWidget?.distanceTextFont = UIFont.italicSystemFont(ofSize: 30.0);
        //
        //        let imageDict = [   DUXRadarWidgetForward_1_0 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_0")!,
        //                            DUXRadarWidgetForward_1_1 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_1")!,
        //                            DUXRadarWidgetForward_1_2 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_2")!,
        //                            DUXRadarWidgetForward_1_3 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_3")!,
        //                            DUXRadarWidgetForward_1_4 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_4")!,
        //                            DUXRadarWidgetForward_1_5 : UIImage.duxbeta_image(withAssetNamed: "RadarBackward_3_5")!
        //        ]
        //        radarWidget?.setCustomRadarImages(imageDict)
        }

    }
}
