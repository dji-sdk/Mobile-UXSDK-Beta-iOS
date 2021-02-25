//
//  DUXBetaToolbarPanelItemTemplate.swift
//  UXSDKCore
//
//  MIT License
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

@objc public enum ToolHeaderHighlightStyle : Int {
    case underline
    case fill
    case edges
}


/**
 * The DUXBetaToolbarPanelItemTemplate allows for describing a widget to be added to a DUXBetaToolbarPanelWidget without instantiating
 * the widget beforehand. It defines the widget by classname, icon and title, and a lifetime hint called keepWidgetAlive.
 */
@objcMembers public class DUXBetaToolbarPanelItemTemplate : NSObject {
    /// The name of the class to use when creating the widget
    public var klassname: String?
    /// The icon image to use for the tool item in the toolbar
    public var barIcon:UIImage?
    /// The label to apply to the tool in the toolbar
    public var barName:String?
    /// The actual widget once the widget has been instantiated for use or if it was passed in during init
    fileprivate var internalWidget: DUXBetaBaseWidget?
    /// Hint to keep the widget alive in memory once created, even if it is not being displayed. If false, widget releases on hide
    public let keepWidgetAlive: Bool
    public var highlightStyle: ToolHeaderHighlightStyle = .underline
    public var highlightThickness: CGFloat = 3.0

    /**
     * Initialization method taking all parameters needed to constuct the toolbar item in the future from a classname.
     * Either one or both parameters icon and title can be nil, but at least one must be set.
     * The alternative init method may be used to add an existing widget.
     *
     * Note: For Swift classes, the fully qualified className includes the module for the class.
     *
     * - Parameters:
     *     - className: The name of the class to use when creating the widget.
     *     - icon: The icon image to use for the tool item in the toolbar.
     *     - title: The label to apply to the tool in the toolbar.
     *     - keepWidget: The hint if the widget should be released when it is no longer displayed as the active tool.
     *     - highliteStyle: An enum designating how to highlight the selected tool in the toolbar. Defaults to .underline if not specified in Swift.
     *     - hightlightThickness: The thickness/width of the underline or border boundary for .underline and .edges hightlight styles. Defaults to 3 points.
     */
    public init(className: String, icon: UIImage?, title: String?, keepWidget:Bool = true,
                highlightStyle: ToolHeaderHighlightStyle = .underline, highlightThickness: CGFloat = 3.0) {

        klassname = className
        internalWidget = nil
        barIcon = icon
        barName = title
        keepWidgetAlive = keepWidget
        self.highlightStyle = highlightStyle
        self.highlightThickness = highlightThickness

        // At this point we have at least an icon or title or this whole thing is bad.
        if (icon == nil) && (title == nil) {
            // We require an icon, title or ToolbarPanelSupportProtocol on the widget to add a widget to the toolbar
            assert(false, "ToolbarPanelItemTempate requires either a title or an icon for use with ToolbarPanelWidget")
        }

        super.init()

    }
    
    /**
     * Initialization method taking all parameters needed to constuct the toolbar item in the future from an existing widget.
     * Either or both parameters icon and title can be nil, if the widget implements the DUXBetaToolbarPanelSupportProtocol,
     * otherwise icon or title must be supplied. If icon or title is supplied, it overrides any value from DUXBetaToolbarPanelSupportProtocol.
     * The alternative init method may be used to add tool which will instantiate the tool from a classname.
     *
     * - Parameters:
     *     - widget: A existing widget to use in the toolbar panel, optionally implementing DUXBetaToolbarPanelSupportProtocol.
     *     - icon: The icon image to use for the tool item in the toolbar.
     *     - title: The label to apply to the tool in the toolbar.
     *     - keepWidget: The hint if the widget should be released when it is no longer displayed as the active tool.
     *     - highliteStyle: An enum designating how to highlight the selected tool in the toolbar. Defaults to .underline if not specified in Swift.
     *     - hightlightThickness: The thickness/width of the underline or border boundary for .underline and .edges hightlight styles. Defaults to 3 points.
     */
    public init(widget passedWidget: DUXBetaBaseWidget, icon: UIImage?, title: String?, keepWidget:Bool = true,
                highlightStyle: ToolHeaderHighlightStyle = .underline, highlightThickness: CGFloat = 3.0) {

        klassname = nil
        internalWidget = passedWidget
        keepWidgetAlive = keepWidget
        self.highlightStyle = highlightStyle
        self.highlightThickness = highlightThickness
        
        super.init()

        if let _ = icon {
            barIcon = icon
        } else {
            if let x = internalWidget as? DUXBetaToolbarPanelSupportProtocol {
                barIcon = loadToolIcon(widget:x)
            }
        }
        
        if let _ = title {
            barName = title
        } else {
            if let x = internalWidget as? DUXBetaToolbarPanelSupportProtocol {
                barName = loadToolTitle(widget:x)
            }
        }

        // At this point we have at least an icon or title or this whole thing is bad.
        if (icon == nil) && (title == nil) {
            // We require an icon, title or ToolbarPanelSupportProtocol on the widget to add a widget to the toolbar
            assert(false, "Widget must implement DUXBetaToolbarPanelSupportProtocol for use with ToolbarPanelWidget")
        }
        
    }
    
    func loadToolIcon<T: AnyObject>(widget: T) -> UIImage? where T: DUXBetaToolbarPanelSupportProtocol {
        return widget.toolbarItemIcon?()

    }
    
    func loadToolTitle<T: AnyObject>(widget: T) -> String? where T: DUXBetaToolbarPanelSupportProtocol {
        return widget.toolbarItemTitle?()
        
    }

    /*
     * Test if the passed in widget matches this templates widget without creating a new widget if it doesnt exist
     */
    func matchesWidget(_ widget: DUXBetaBaseWidget) -> Bool {
        return internalWidget == widget
    }

    func widget() -> DUXBetaBaseWidget? {
        if let widget = internalWidget {
            return widget
        }
        
        // It has not been created yet, so make it from the klassname
        if let klassname = klassname {
            let aClass = NSClassFromString(klassname) as! DUXBetaBaseWidget.Type
            internalWidget = aClass.init()
        }
        
        return internalWidget
    }
    
    func releaseWidgetIfNeeded() {
        if (keepWidgetAlive == false) && (klassname != nil) {
            internalWidget = nil
        }
    }
}

/**
 * ToolRecognizer is a class which installs a gesture recognizer on an individual tool item in a Toolbar pane; and will
 * select the item for display when it is tapped. It is only used internally by the DUXBetaToolbarPanelWidget
 */
class ToolRecognizer : NSObject {
    /// The tap gesture recognizer for this helper
    private var tapRecognizer: UITapGestureRecognizer?
    /// The iconView to attach the gesture recognizer onto
    weak var iconView: UIView?
    // The owning toolbar panel to perform the selection on.
    weak var panel: DUXBetaToolbarPanelWidget?

    /**
     * Initialization method taking the toolIcon view and the unnamed panel to send selection to.
     *
     * - Parameters:
     *     - toolIconView: The icon in the tool list for the toolbar pane being observed.
     *     - panel: unnamed panel which will recevie the seletion once a tap is seen.
     */
    init(toolIconView: UIView, _ panel:DUXBetaToolbarPanelWidget) {
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
        if let unwrappedPanel = self.panel, let iconView = iconView {
            unwrappedPanel.selectToolFromHeader(headerView: iconView)
        }
    }
}

