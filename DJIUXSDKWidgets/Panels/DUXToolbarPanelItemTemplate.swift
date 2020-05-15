//
//  DUXToolbarPanelItemTemplate.swift
//  DJIUXSDKWidgets
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
 * The DUXToolbarPanelItemTemplate allows for describing a widget to be added to a DUXToolbarPanelWidget without instantiating
 * the widget beforehand. It defines the widget by classname, icon and title, and a lifetime hint called keepWidgetAlive.
 */
@objcMembers public class DUXToolbarPanelItemTemplate : NSObject {
    /// The name of the class to use when creating the widget
    public var klassname: String?
    /// The icon image to use for the tool item in the toolbar
    public var barIcon:UIImage?
    /// The label to apply to the tool in the toolbar
    public var barName:String?
    /// The actual widget once the widget has been instantiated for use or if it was passed in during init
    public var widget: DUXBetaBaseWidget?
    /// Hint to keep the widget alive in memory once created, even if it is not being displayed. If false, widget releases on hide
    public let keepWidgetAlive: Bool
    
    /**
     * Initialization method taking all parameters needed to constuct the toolbar item in the future
     *
     * - Parameters:
     *     - className: The name of the class to use when creating the widget.
     *     - icon: The icon image to use for the tool item in the toolbar.
     *     - title: The label to apply to the tool in the toolbar.
     *     - existingWidget: An optional existing widget to use instead of creating a new one for display.
     *     - keepWidget: The hint if the widget should be released when it is no longer displayed as the active tool.
     */
    public init(className: String?, icon: UIImage?, title: String?, existingWidget: DUXBetaBaseWidget? = nil, keepWidget:Bool = true) {

        klassname = className
        widget = existingWidget
        barIcon = icon
        barName = title
        keepWidgetAlive = keepWidget

        super.init()

        if (klassname == nil) && (widget == nil) {
            assertionFailure("Either classname or existingWidget must be non-nil")
        }
        
    }
}

/**
 * ToolRecognizer is a class which installs a gesture recognizer on an individual tool item in a Toolbar pane; and will
 * select the item for display when it is tapped. It is only used internally by the DUXToolbarPanelWidget
 */
class ToolRecognizer : NSObject {
    /// The tap gesture recognizer for this helper
    private var tapRecognizer: UITapGestureRecognizer?
    /// The iconView to attach the gesture recognizer onto
    weak var iconView: UIView?
    // The owning toolbar panel to perform the selection on.
    weak var panel: DUXToolbarPanelWidget?

    /**
     * Initialization method taking the toolIcon view and the unnamed panel to send selection to.
     *
     * - Parameters:
     *     - toolIconView: The icon in the tool list for the toolbar pane being observed.
     *     - panel: unnamed panel which will recevie the seletion once a tap is seen.
     */
    init(toolIconView: UIView, _ panel:DUXToolbarPanelWidget) {
        super.init()
        
        self.iconView = toolIconView
        self.panel = panel
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeTool))   // Save because I just assigned it.
        if let recognizer = tapRecognizer {
            self.iconView?.addGestureRecognizer(recognizer)
        }
    }
    
    deinit {
        print("deinit ToolRecognizer")
        if let recognizer = tapRecognizer {
            self.iconView?.removeGestureRecognizer(recognizer)
        }
    }
    
    @IBAction func changeTool() {
        if let unwrappedPanel = self.panel {
            for (index, theView) in unwrappedPanel.toolHeaderViews.enumerated() {
                if theView == self.iconView {
                    // Do a blind select, selectTool will be smart and reject it if already showing
                    unwrappedPanel.selectTool(index:index)
                }
            
            }
        }
    }
}

