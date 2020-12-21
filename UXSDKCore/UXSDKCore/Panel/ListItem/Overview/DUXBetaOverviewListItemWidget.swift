//
//  DUXBetaOverviewListItemWidget.swift
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

/**
 * Widget for displaying the current overview of aircraft status
 */
@objcMembers open class DUXBetaOverviewListItemWidget : DUXBetaListItemLabelButtonWidget {
    /// The widget model for monitoring aircraft status
    lazy var widgetModel = DUXBetaSystemStatusWidgetModel()
    
    override public init() {
        super.init(.labelOnly)
    }
    
    /**
     * Required init for Swift implemntation of list item subclass.
     */
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * Override of viewDidLoad to set up widget model, text settings, and set title and icon when widget loads
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        widgetModel.setup()
        displayTextLabel.minimumScaleFactor = 0.6
        displayTextLabel.adjustsFontSizeToFitWidth = true
        
        setTitle(NSLocalizedString("Overall Status", comment: "List Item Widget Title"), andIconName:"SystemStatusOverview")
    }
    
    /*
     * Override of viewWillAppear to establish bindings to the widgetModel
     */
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindRKVOModel(self, #selector(warningStatusUpdated), (\DUXBetaOverviewListItemWidget.widgetModel.suggestedWarningMessage).toString,
                        (\DUXBetaOverviewListItemWidget.widgetModel.isCriticalWarning).toString,
                        (\DUXBetaOverviewListItemWidget.widgetModel.systemStatusWarningLevel).toString)
        bindRKVOModel(self, #selector(warningStatusItemChanged), (\DUXBetaOverviewListItemWidget.widgetModel.warningStatusItem).toString)
        bindRKVOModel(self, #selector(productConnectedChanged), (\DUXBetaOverviewListItemWidget.widgetModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(updateColors), (\DUXBetaOverviewListItemWidget.warningValueColor).toString,
                        (\DUXBetaOverviewListItemWidget.errorValueColor).toString,
                        (\DUXBetaOverviewListItemWidget.normalValueColor).toString,
                        (\DUXBetaOverviewListItemWidget.disconnectedValueColor).toString)

    }

    /*
     * Override of viewWillDisappear to clean up bindings to the widgetModel
     */
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindRKVOModel(self)
    }

    deinit {
        widgetModel.cleanup()
    }
    
    /*
     * Method updateColors is invoked by the KVO bindings with the colors settings for the widget and message with the updated colors.
     */
    public func updateColors() {
        warningStatusUpdated()
    }
    
    /*
     * Method warningStatusUpdated is invoked by the KVO bindings with the widget model and updates the displayed message and color if they change
     */
    public func warningStatusUpdated() {
        if (widgetModel.isProductConnected) {
            setLabelText(widgetModel.suggestedWarningMessage)
            switch widgetModel.systemStatusWarningLevel {
                case .none, .good: displayTextLabel.textColor = normalValueColor
                case .offline: displayTextLabel.textColor = disconnectedValueColor
                case .warning: displayTextLabel.textColor = warningValueColor
                case .error: displayTextLabel.textColor = errorValueColor
                
                default: displayTextLabel.textColor = normalValueColor
            }
        } else {
            setLabelText(NSLocalizedString("N/A", comment: "N/A"))
            displayTextLabel.textColor = self.disabledColor()
        }
    }
    
    public func warningStatusItemChanged() {
        DUXBetaStateChangeBroadcaster.send(DUXBetaOverviewItemModelState.productConnected(widgetModel.isProductConnected))
    }
    
    public func productConnectedChanged() {
        warningStatusUpdated()
        DUXBetaStateChangeBroadcaster.send(DUXBetaOverviewItemModelState.productConnected(widgetModel.isProductConnected))
    }

}

 /**
  * DUXBetaOverviewItemModelState contains the hooks for the DUXBetaOverviewListItemWidget model class.
  * It inherits all model hooks in ListItemLabelButtonModelState and adds:
  *
  * Key: overviewStateUpdated  Type: id - Sends the updated DJIWarningStatusItem object with the message and support info when it changes.
 */
@objc open class DUXBetaOverviewItemModelState: ListItemLabelButtonModelState {

    @objc public static func overviewStateUpdated(_ newValue: DJIWarningStatusItem) -> DUXBetaOverviewItemModelState {
        return DUXBetaOverviewItemModelState(key: "overviewStateUpdated", object: newValue)
    }

}

