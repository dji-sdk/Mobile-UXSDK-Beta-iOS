//
//  DefaultLayoutViewController.swift
//  UXSDKBetaSample
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

class DefaultLayoutViewController: UIViewController {
    
    let rootView = UIView()
    var topBar: DUXBarPanelWidget?
    var leftBar: DUXBarPanelWidget?
    var fpvWidget: DUXBetaFPVWidget?
    var systemStatusListPanel: DUXListPanelWidget?
    var fpvCustomizationPanel: DUXListPanelWidget?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(rootView)
        
        self.view.backgroundColor = UIColor.duxbeta_black()
        
        rootView.translatesAutoresizingMaskIntoConstraints = false
        let statusBarInsets = UIApplication.shared.keyWindow!.safeAreaInsets
        
        var edgeInsets: UIEdgeInsets
        if #available(iOS 11, * ) {
            edgeInsets = self.view.safeAreaInsets
            edgeInsets.top += statusBarInsets.top
            edgeInsets.left += statusBarInsets.left
            edgeInsets.bottom += statusBarInsets.bottom
            edgeInsets.right += statusBarInsets.right
        } else {
            edgeInsets = UIEdgeInsets(top: statusBarInsets.top, left: statusBarInsets.left, bottom: statusBarInsets.bottom, right: statusBarInsets.right)
        }
        
        rootView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:edgeInsets.top).isActive = true
        rootView.leftAnchor.constraint(equalTo:self.view.leftAnchor, constant:edgeInsets.left).isActive = true
        rootView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor, constant:-edgeInsets.bottom).isActive = true
        rootView.rightAnchor.constraint(equalTo:self.view.rightAnchor, constant:-edgeInsets.right).isActive = true

        setupTopBar()
        setupFPVWidget()
        setupRemainingFlightTimeWidget()
        setupDashboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        DUXStateChangeBroadcaster.instance().unregisterListener(self)
        
        super.viewDidDisappear(animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent;
    }
    
    @IBAction func close() {
        self.dismiss(animated: true)
    }

    func setupTopBar() {
        let topBarWidget = DUXTopBarWidget()
        
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
            logoBtn.leftAnchor.constraint(equalTo: self.rootView.leftAnchor),
            logoBtn.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: margin),
            logoBtn.heightAnchor.constraint(equalToConstant: height - 2 * margin),
          
            topBarWidget.view.trailingAnchor.constraint(equalTo: customizationsBtn.leadingAnchor),
            topBarWidget.view.leadingAnchor.constraint(equalTo: logoBtn.trailingAnchor),
            topBarWidget.view.topAnchor.constraint(equalTo: self.rootView.topAnchor),
            topBarWidget.view.heightAnchor.constraint(equalToConstant: height),
            
            customizationsBtn.topAnchor.constraint(equalTo: self.rootView.topAnchor, constant: margin),
            customizationsBtn.heightAnchor.constraint(equalToConstant: height - 2 * margin),
            customizationsBtn.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])
        
        self.topBar = topBarWidget
        topBar?.topMargin = margin
        topBar?.rightMargin = margin
        topBar?.bottomMargin = margin
        topBar?.leftMargin = margin

        DUXStateChangeBroadcaster.instance().registerListener(self, analyticsClassName: "DUXSystemStatusWidgetUIState") { [weak self] (analyticsData) in
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
            remainingFlightTimeWidget.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            remainingFlightTimeWidget.view.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            remainingFlightTimeWidget.view.centerYAnchor.constraint(equalTo: self.topBar?.view.bottomAnchor ?? self.rootView.topAnchor, constant: 3.0),
            remainingFlightTimeWidget.view.widthAnchor.constraint(equalTo: remainingFlightTimeWidget.view.widthAnchor, multiplier: (remainingFlightTimeWidget.widgetSizeHint.preferredAspectRatio))
        ])
    }
    
    func setupLeftBar() {
        let configSettings = DUXPanelWidgetConfiguration(type:.bar, variant:.vertical)
        let leftSideBarWidget = DUXBarPanelWidget()
        _ = leftSideBarWidget.configure(configSettings)
        
        leftSideBarWidget.install(in: self)

        if let topBarWidget = self.topBar {
            leftSideBarWidget.view.topAnchor.constraint(equalTo: topBarWidget.view.bottomAnchor).isActive = true
            leftSideBarWidget.view.leftAnchor.constraint(equalTo: self.rootView.leftAnchor).isActive = true
            leftSideBarWidget.view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor).isActive = true
            leftSideBarWidget.view.rightAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 64.0).isActive = true
        } else {
            leftSideBarWidget.view.topAnchor.constraint(equalTo: self.rootView.topAnchor).isActive = true
            leftSideBarWidget.view.leftAnchor.constraint(equalTo: self.rootView.leftAnchor).isActive = true
            leftSideBarWidget.view.bottomAnchor.constraint(equalTo: self.rootView.bottomAnchor).isActive = true
            leftSideBarWidget.view.rightAnchor.constraint(equalTo: self.rootView.leftAnchor, constant: 64.0).isActive = true
        }

        let flightModeWidget = DUXBetaFlightModeWidget()
        leftSideBarWidget.addRightWidgetArray([DUXBetaVisionWidget(), flightModeWidget, DUXBetaRemoteControllerSignalWidget(), DUXBetaVideoSignalWidget()] )
        leftSideBarWidget.addLeftWidgetArray([DUXBetaGPSSignalWidget()] )
        self.leftBar = leftSideBarWidget
    }
    
    func setupSystemStatusList() {
        let listPanel = DUXSystemStatusListWidget()

        listPanel.install(in: self)
        
        listPanel.view.topAnchor.constraint(equalTo: self.topBar!.view.bottomAnchor).isActive = true
        listPanel.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 00.0).isActive = true
        listPanel.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6).isActive = true
        listPanel.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -30.0).isActive = true
        
        systemStatusListPanel = listPanel
    }
    
    func setupFPVWidget() {
        let fpvWidget = DUXBetaFPVWidget()
        
        fpvWidget.install(in: self)
        
        NSLayoutConstraint.activate([
            fpvWidget.view.topAnchor.constraint(equalTo: topBar?.view.bottomAnchor ?? view.topAnchor),
            fpvWidget.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            fpvWidget.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            fpvWidget.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.fpvWidget = fpvWidget
    }
    
    func setupDashboard() {
        let dashboardWidget = DUXBetaDashboardWidget()
        
        let leftMarginLayoutGuide = UILayoutGuide.init()
        self.view.addLayoutGuide(leftMarginLayoutGuide)
        
        let bottomMarginLayoutGuide = UILayoutGuide.init()
        self.view.addLayoutGuide(bottomMarginLayoutGuide)
        
        dashboardWidget.install(in: self)
        
        NSLayoutConstraint.activate([
            leftMarginLayoutGuide.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.015),
            leftMarginLayoutGuide.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            leftMarginLayoutGuide.rightAnchor.constraint(equalTo: dashboardWidget.view.leftAnchor),
            
            bottomMarginLayoutGuide.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.02),
            bottomMarginLayoutGuide.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            bottomMarginLayoutGuide.topAnchor.constraint(equalTo: dashboardWidget.view.bottomAnchor),

            dashboardWidget.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.6),
            dashboardWidget.view.widthAnchor.constraint(equalTo: dashboardWidget.view.heightAnchor,
                                                     multiplier: dashboardWidget.widgetSizeHint.preferredAspectRatio)
        ])
    }
    
    @objc func setupFPVCustomizationPanel() {
        if let _ = fpvCustomizationPanel {
            fpvCustomizationPanel?.closeTapped()
        }
        
        let listPanel = DUXListPanelWidget()
        _ = listPanel.configure(DUXPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: "FPV Customizations"))

        listPanel.install(in: self)
        
        NSLayoutConstraint.activate([
            listPanel.view.heightAnchor.constraint(greaterThanOrEqualToConstant: listPanel.widgetSizeHint.minimumHeight),
            listPanel.view.heightAnchor.constraint(lessThanOrEqualTo: self.view.heightAnchor, multiplier: 0.7),
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
        
        listPanel.addWidgetArray([cameraNameVisibility,
                                  cameraSideVisibility,
                                  gridlinesVisibility,
                                  gridlinesType,
                                  centerImageVisibility,
                                  centerImageType,
                                  centerImageColor])
        fpvCustomizationPanel = listPanel
    }
}
