//
//  CoreModuleViewController.swift
//  UXSDKBetaSampleApp
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

import UIKit
import DJIUXSDK

class CoreModuleViewController : DefaultLayoutViewController {
    
    override func setupCoreWidgets() {
        super.setupCoreWidgets()
        
        addCustomizationButton()
    }
    
    override func setupFlightWidgets() {
        
    }
    
    override func setupAccessoryWidgets() {
        
    }
    
    fileprivate func addCustomizationButton() {
        let customizationsBtn = UIButton()
        customizationsBtn.translatesAutoresizingMaskIntoConstraints = false
        customizationsBtn.setImage(UIImage.init(named: "Wrench"), for: .normal)
        customizationsBtn.imageView?.contentMode = .scaleAspectFit
        customizationsBtn.addTarget(self, action: #selector(setupTopbarCustomizationPanel), for: .touchUpInside)
        view.addSubview(customizationsBtn)
        
        topBarRightConstraint?.isActive = false
        topBarRightConstraint = topBarWidget?.view.trailingAnchor.constraint(equalTo: customizationsBtn.leadingAnchor)

        if let refrenceView = topBarWidget?.view {
            NSLayoutConstraint.activate([
                topBarRightConstraint!,
                customizationsBtn.topAnchor.constraint(equalTo: refrenceView.topAnchor),
                customizationsBtn.heightAnchor.constraint(equalTo: refrenceView.heightAnchor),
                customizationsBtn.rightAnchor.constraint(equalTo: rootView.rightAnchor)
            ])
        }
    }
    
    @objc func setupTopbarCustomizationPanel() {
        if let _ = telemetryCustomizationPanel {
            telemetryCustomizationPanel?.closeTapped()
        }
        
        let listPanel = DUXBetaListPanelWidget()
        _ = listPanel.configure(DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: "FPV"))

        listPanel.onCloseTapped({ [weak self] inPanel in
            guard let self = self else { return }
            self.fpvCustomizationPanel = nil;
        })
        listPanel.install(in: self)
        telemetryCustomizationPanel = listPanel
        
        NSLayoutConstraint.activate([
            listPanel.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listPanel.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            listPanel.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? view.topAnchor),
            listPanel.view.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])
                
        let listTitle = SettingTitle()
        listTitle.setTitle("Choose Widget", andIconName: nil)
        
        let topbarListSetting = TopbarListSetting()
        topbarListSetting.setTitle("Widget", andIconName: nil)
        topbarListSetting.topbarWidget = topBarWidget
        
        let customizeTitle = SettingTitle()
        customizeTitle.setTitle("Customize", andIconName: nil)
        
        let connectedTintColorSetting = ColorSetting()
        connectedTintColorSetting.setTitle("Connected Tint Color", andIconName: nil)
        connectedTintColorSetting.onInitialValue = { topbarListSetting.connectedTintColor }
        connectedTintColorSetting.onValueChanged = { (color) in
            topbarListSetting.connectedTintColor = color
        }
        
        let disconnectedTintColorSetting = ColorSetting()
        disconnectedTintColorSetting.setTitle("Disconnected Tint Color", andIconName: nil)
        disconnectedTintColorSetting.onInitialValue = { topbarListSetting.disconnectedTintColor }
        disconnectedTintColorSetting.onValueChanged = { (color) in
            topbarListSetting.disconnectedTintColor = color
        }
        
        let inactiveTintColorSetting = ColorSetting()
        inactiveTintColorSetting.setTitle("Inactive Tint Color", andIconName: nil)
        inactiveTintColorSetting.onInitialValue = { topbarListSetting.inactiveTintColor }
        inactiveTintColorSetting.onValueChanged = { (color) in
            topbarListSetting.inactiveTintColor = color
        }
        
        listPanel.addWidgetArray([
            listTitle,
            topbarListSetting,
            customizeTitle,
            connectedTintColorSetting,
            disconnectedTintColorSetting,
            inactiveTintColorSetting,
        ])
    }
    
    @objc func setupTelemetryCustomizationPanel() {
        if let _ = telemetryCustomizationPanel {
            telemetryCustomizationPanel?.closeTapped()
        }
        
        let listPanel = DUXBetaListPanelWidget()
        _ = listPanel.configure(DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: "FPV"))

        listPanel.onCloseTapped({ [weak self] inPanel in
            guard let self = self else { return }
            self.fpvCustomizationPanel = nil;
        })
        listPanel.install(in: self)
        telemetryCustomizationPanel = listPanel
        
        NSLayoutConstraint.activate([
            listPanel.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listPanel.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            listPanel.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? view.topAnchor),
            listPanel.view.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])
        
        let isEnabled = self.fpvWidget?.widgetModel.isProductConnected ?? false
        
        let telemetryListTitle = SettingTitle()
        telemetryListTitle.setTitle("Choose Widget", andIconName: nil)
        
        let telemetryListSetting = TelemetryListSetting()
        telemetryListSetting.setTitle("Widget", andIconName: nil)
        telemetryListSetting.telemetryPanel = telemetryPanel
        
        let customizeTitle = SettingTitle()
        customizeTitle.setTitle("Customize", andIconName: nil)
        
        let visibilitySetting = DUXBetaListItemSwitchWidget()
        visibilitySetting.setTitle("Visibility", andIconName: nil)
        visibilitySetting.onOffSwitch.isOn = fpvWidget?.isCameraNameVisible ?? false && isEnabled
        visibilitySetting.setSwitchAction { (enabled) in
            telemetryListSetting.visibilityValue = enabled
        }
        
        let textColorSetting = ColorSetting()
        textColorSetting.setTitle("Text Color", andIconName: nil)
        textColorSetting.onInitialValue = { return self.fpvWidget?.cameraNameTextColor }
        textColorSetting.onValueChanged = { (color) in
            guard let color = color else { return }
            telemetryListSetting.textColorValue = color
        }
        
        let backgroundColorSetting = ColorSetting()
        backgroundColorSetting.setTitle("Background Color", andIconName: nil)
        backgroundColorSetting.onInitialValue = { return self.fpvWidget?.cameraNameBackgroundColor }
        backgroundColorSetting.onValueChanged = { (color) in
            guard let color = color else { return }
            telemetryListSetting.backgroundColorValue = color
        }
        
        let fontSizeSetting = SliderValueSetting()
        fontSizeSetting.setTitle("Font Size", andIconName: nil)
        fontSizeSetting.onValueChanged = { (value) in
            telemetryListSetting.textSizeValue = CGFloat(value)
        }
        
        listPanel.addWidgetArray([
            telemetryListTitle,
            telemetryListSetting,
            customizeTitle,
            visibilitySetting,
            textColorSetting,
            backgroundColorSetting,
            fontSizeSetting
        ])
    }
    
    @objc func setupFPVCustomizationPanel() {
        if let _ = fpvCustomizationPanel {
            fpvCustomizationPanel?.closeTapped()
        }
        
        let listPanel = DUXBetaListPanelWidget()
        _ = listPanel.configure(DUXBetaPanelWidgetConfiguration(type: .list, listKind: .widgets)
            .configureTitlebar(visible: true, withCloseBox: true, title: "FPV"))

        listPanel.onCloseTapped({ [weak self] inPanel in
            guard let self = self else { return }
            self.fpvCustomizationPanel = nil;
        })
        listPanel.install(in: self)
        
        NSLayoutConstraint.activate([
            listPanel.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            listPanel.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            listPanel.view.topAnchor.constraint(equalTo: topBarWidget?.view.bottomAnchor ?? view.topAnchor),
            listPanel.view.rightAnchor.constraint(equalTo: rootView.rightAnchor)
        ])
        
        let isEnabled = self.fpvWidget?.widgetModel.isProductConnected ?? false
        
        // Video Source settings
        let videoSettings = SettingTitle()
        videoSettings.setTitle("Video Setings", andIconName: nil)
        
        let videoSourceSetting = DUXBetaListItemRadioButtonWidget()
        videoSourceSetting.setTitle("Video Source", andIconName: nil)
        videoSourceSetting.setEnabled(isEnabled)
        videoSourceSetting.selection = (self.fpvWidget?.videoFeed == DJISDKManager.videoFeeder()?.primaryVideoFeed) ? 0 : 1
        videoSourceSetting.setOptionTitles(["Primary", "Secondary"])
        videoSourceSetting.setOptionSelectedAction { [weak self] (oldIndex, newIndex) in
            if oldIndex != newIndex {
                if newIndex == 0 {
                    self?.fpvWidget?.videoFeed = DJISDKManager.videoFeeder()?.primaryVideoFeed
                } else {
                    self?.fpvWidget?.videoFeed = DJISDKManager.videoFeeder()?.secondaryVideoFeed
                }
            }
        }
        
        let hardwareDecodeSetting = DUXBetaListItemSwitchWidget()
        hardwareDecodeSetting.setTitle("Enable Hardware Decode", andIconName: nil)
        hardwareDecodeSetting.onOffSwitch.isOn = fpvWidget?.enableHardwareDecode ?? false && isEnabled
        hardwareDecodeSetting.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.enableHardwareDecode = enabled
        }
        
        // Camera Name settings
        let cameraNameSettings = SettingTitle()
        cameraNameSettings.setTitle("Camera Name", andIconName: nil)
        
        let cameraNameVisibility = DUXBetaListItemSwitchWidget()
        cameraNameVisibility.setTitle("Visibility", andIconName: nil)
        cameraNameVisibility.onOffSwitch.isOn = fpvWidget?.isCameraNameVisible ?? false && isEnabled
        cameraNameVisibility.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.isCameraNameVisible = enabled
        }
        
        let cameraNameTextColor = ColorSetting()
        cameraNameTextColor.setTitle("Text Color", andIconName: nil)
        cameraNameTextColor.onInitialValue = { return self.fpvWidget?.cameraNameTextColor }
        cameraNameTextColor.onValueChanged = { [weak self] (color) in
            guard let color = color else { return }
            self?.fpvWidget?.cameraNameTextColor = color
        }
        
        let cameraNameBackgroundColor = ColorSetting()
        cameraNameBackgroundColor.setTitle("Background Color", andIconName: nil)
        cameraNameBackgroundColor.onInitialValue = { return self.fpvWidget?.cameraNameBackgroundColor }
        cameraNameBackgroundColor.onValueChanged = { [weak self] (color) in
            guard let color = color else { return }
            self?.fpvWidget?.cameraNameBackgroundColor = color
        }
        
        let cameraNameSizeSetting = SliderValueSetting()
        cameraNameSizeSetting.setTitle("Font Size", andIconName: nil)
        cameraNameSizeSetting.onValueChanged = { [weak self] (value) in
            self?.fpvWidget?.cameraNameFont = UIFont.systemFont(ofSize: CGFloat(value))
        }

        // Camera Side settings
        let cameraSideSettings = SettingTitle()
        cameraSideSettings.setTitle("Camera Side", andIconName: nil)
        
        let cameraSideVisibility = DUXBetaListItemSwitchWidget()
        cameraSideVisibility.setTitle("Visibility", andIconName: nil)
        cameraSideVisibility.onOffSwitch.isOn = fpvWidget?.isCameraSideVisible ?? false && isEnabled
        cameraSideVisibility.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.isCameraSideVisible = enabled
        }
        
        let cameraSideTextColor = ColorSetting()
        cameraSideTextColor.setTitle("Text Color", andIconName: nil)
        cameraSideTextColor.onInitialValue = { return self.fpvWidget?.cameraSideTextColor }
        cameraSideTextColor.onValueChanged = { [weak self] (color) in
            guard let color = color else { return }
            self?.fpvWidget?.cameraSideTextColor = color
        }
        
        let cameraSideBackgroundColor = ColorSetting()
        cameraSideBackgroundColor.setTitle("Background Color", andIconName: nil)
        cameraSideBackgroundColor.onInitialValue = { return self.fpvWidget?.cameraSideBackgroundColor }
        cameraSideBackgroundColor.onValueChanged = { [weak self] (color) in
            guard let color = color else { return }
            self?.fpvWidget?.cameraSideBackgroundColor = color
        }
        
        let cameraSideSizeSetting = SliderValueSetting()
        cameraSideSizeSetting.setTitle("Font Size", andIconName: nil)
        cameraSideSizeSetting.onValueChanged = { [weak self] (value) in
            self?.fpvWidget?.cameraSideFont = UIFont.systemFont(ofSize: CGFloat(value))
        }
        
        // Gridlines settings
        let gridlinesSettings = SettingTitle()
        gridlinesSettings.setTitle("Gridlines", andIconName: nil)
        
        let gridlinesVisibility = DUXBetaListItemSwitchWidget()
        gridlinesVisibility.setTitle("Visibility", andIconName: nil)
        gridlinesVisibility.onOffSwitch.isOn = fpvWidget?.isGridViewVisible ?? false && isEnabled
        gridlinesVisibility.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.isGridViewVisible = enabled
        }
        
        let gridlinesTypeSetting = DUXBetaListItemRadioButtonWidget()
        gridlinesTypeSetting.setTitle("Type", andIconName: nil)
        gridlinesTypeSetting.setEnabled(isEnabled)
        gridlinesTypeSetting.setOptionTitles([NSLocalizedString("None", comment: "None"),
                                              NSLocalizedString("Parallel", comment: "Parallel"),
                                              NSLocalizedString("Parallel Diag", comment: "Parallel Diag")])
        gridlinesTypeSetting.setOptionSelectedAction { [weak self] (oldIndex, newIndex) in
            if newIndex != oldIndex {
                switch newIndex {
                case 0: self?.fpvWidget?.gridView.gridViewType = .None
                case 1: self?.fpvWidget?.gridView.gridViewType = .Parallel
                case 2: self?.fpvWidget?.gridView.gridViewType = .ParallelDiagonal
                default: break
                }
            }
        }
        gridlinesTypeSetting.selection = self.fpvWidget?.gridView?.gridViewType.rawValue ?? 0
        
        let gridlinesWidthSetting = SliderValueSetting()
        gridlinesWidthSetting.setTitle("Line Width", andIconName: nil)
        gridlinesWidthSetting.onValueChanged = { [weak self] (value) in
            self?.fpvWidget?.gridView.lineWidth = CGFloat(value)
        }
        
        // Center Point settings
        let centerPointSettings = SettingTitle()
        centerPointSettings.setTitle("Center Point", andIconName: nil)
        
        let centerPointVisibility = DUXBetaListItemSwitchWidget()
        centerPointVisibility.setTitle("Visibility", andIconName: nil)
        centerPointVisibility.onOffSwitch.isOn = fpvWidget?.isCenterViewVisible ?? false && isEnabled
        centerPointVisibility.setSwitchAction { [weak self] (enabled) in
            self?.fpvWidget?.isCenterViewVisible = enabled
        }
        
        let centerPointTypeSetting = CenterPointTypeSetting()
        centerPointTypeSetting.setTitle("Type", andIconName: nil)
        centerPointTypeSetting.fpvWidget = fpvWidget
        
        let centerPointColorSetting = CenterPointColorSetting()
        centerPointColorSetting.setTitle("Color", andIconName: nil)
        centerPointColorSetting.fpvWidget = fpvWidget
        
        listPanel.addWidgetArray([
            videoSettings,
            videoSourceSetting,
            hardwareDecodeSetting,
            cameraNameSettings,
            cameraNameVisibility,
            cameraNameTextColor,
            cameraNameBackgroundColor,
            cameraNameSizeSetting,
            cameraSideSettings,
            cameraSideVisibility,
            cameraSideTextColor,
            cameraSideBackgroundColor,
            cameraSideSizeSetting,
            gridlinesSettings,
            gridlinesVisibility,
            gridlinesTypeSetting,
            gridlinesWidthSetting,
            centerPointSettings,
            centerPointVisibility,
            centerPointTypeSetting,
            centerPointColorSetting,
        ])
        fpvCustomizationPanel = listPanel
    }
}
