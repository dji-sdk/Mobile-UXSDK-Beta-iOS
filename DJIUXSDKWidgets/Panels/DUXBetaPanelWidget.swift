//
//  DUXBetaPanelWidget.swift
//  DJIUXSDKWidgets
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

/**
 * DUXBetaPanelType is an enum used to define/identify the style of a panel
 * Current values are: bar, toobar, or list
 */
@objc public enum DUXBetaPanelType: Int {
    case bar = 0
    case toolbar
    case list
}

/**
 * DUXBetaPanelVariant defines positoning and layout for bar and toobar panels.
 * Current values:
 * horizontal, vertical - The orientation for a bar panel
 * top, left, right - The edge tools icons/labels for a toobar panel will appear on
 */
@objc public enum DUXBetaPanelVariant: Int {
    case horizontal = 0
    case vertical
    case top
    case left
    case right
}

/**
 DUXBetaPanelTitleBarAligmnet defines the positioning of the title in the titlebar for
 DUXBetaListPanelWidget and DUXBetaToolbarPanelWidget.
 center - The title is horizontally centered.
 leading - The title is aligned to the leading edge of the toolbar with spacing always left for the back button whch may be shown.
 */
@objc public enum DUXBetaPanelTitleBarAlignment: Int {
    case center = 0
    case leading
}

/**
 Generic close box sizing paramters if an actual close box image is missing.
 */
let kCloseBoxHeightDefault: CGFloat = 24.0
let kCloseBoxWidthDefault: CGFloat = 24.0

/**
 * DUXBetaPanelWidgetConfiguration - This class is used to define configuration options for panels in the DUXBetaListPanel cluster.
 * There are two init methods for list and non-list panel types and three configuration methods used to prepare the configuration
 * object.
 *
 * Once the configuration object is prepared, a panel is created and the configure method on the panel is called,
 * passing in the configuration object.
 *
 * Initialization Methods:
 * init(type: DUXBetaPanelType, variant: DUXBetaPanelVariant) - This method starts configuration of a Bar or Toolbar panel.
 * init(type: DUXBetaPanelType, listKind: DUXBetaListType) - This method starts configuration of a List panel.
 *
 * Configuration Setup methods
 * configureColors      - Sets the colors which will be used for drawing elements of the panel.
 * configureTitlebar    - Defines the titlebar information for List and Toolbar panels.
 * configureToolbar     - Defines the size of icons to be shown in the Toolbar panel tools list.
 */
@objcMembers open class DUXBetaPanelWidgetConfiguration : NSObject {
    public var widgetVariant: DUXBetaPanelVariant = .horizontal
    public var panelToolbarColor = UIColor.duxbeta_lightGray()

    // MARK: - Internal configuration settings
    
/**
 * The general configuration settings for type of panel and if a list panel, which type of panel.
 *
 */
    var widgetType: DUXBetaPanelType = .list
    var widgetListType: DUXBetaListType = .none

    // Title bar configuration settings
    var showTitleBar = false
    var hasCloseBox = false
    var hasBackButton = false
    var panelTitle = ""
    var titleBarBackgroundColor = UIColor.duxbeta_black()
    var titleColor = UIColor.duxbeta_white()
    var titlebarHeight: CGFloat = 32.0
    var titleBarFont: UIFont?
    var titlebar: UIView?
    var titleBarAlignment: DUXBetaPanelTitleBarAlignment = .center
    
    // The specific ToolbarPanel configuration settings
    var toolbarDimension: CGFloat = 44.0   // Default height along top, or width for edges.
    var panelBackgroundColor = UIColor.duxbeta_black()
    var panelBorderColor = UIColor.duxbeta_clear()
    var panelSelectionColor = UIColor.duxbeta_darkGray()
    var toolbarBackgroundColor = UIColor.duxbeta_black()
    var toolbarTintColor = UIColor.duxbeta_white()
    
    /**
     * Initializes the configuration object for use with DUXBetaBarPanel and DUXBetaToolbarPanel.
     *
     * - Parameters:
     *     - type: The type of panel to be configured.
     *     - variant: The positioning style of the panel being configured.
     *
     */
    public init(type: DUXBetaPanelType, variant: DUXBetaPanelVariant) {
        widgetType = type
        widgetVariant = variant
        super.init()
    }
    
    /**
     * Initializes the configuration object for use with DUXBetaBarPanel and DUXBetaToolbarPanel.
     *
     * - Parameters:
     *     - type: The type of panel to be configured.
     *     - listKind: The style of the list to be displayed which defines how list items are added.
     *
     */
    public init(type: DUXBetaPanelType, listKind: DUXBetaListType) {
        widgetType = type
        widgetListType = listKind
        super.init()
    }

    /**
     * Defines the colors which will be used for drawing the Panel and some of its contents. Default values
     * are supplied for omitted parameters.
     *
     * - Parameters:
     *      - background: The background color for the panel. Defaults to DUXBeta_black.
     *      - border:The border color to be drawn around the panel. Defaults to DUXBeta_clear.
     *      - title: The color to draw the title in the titlebar. Defaults to dex_white.
     *      - titleBarBackground: The color to use for the background of the titlebar. Defaults to DUXBeta_black.
     *      - selection: Selection color to use for selections in panels. Only used in Toolbar panels. Defaults to DUXBeta_darkGray.
     *      - toolbarBackground: The background color for the tool icons Toolbar panels. Defaults to DUXBeta_black.
     *      - toolbarTint: The tint color to use for colorizing the selected tool in Toolbar panels. Currently unused. Defaults to DUXBeta_white.
     *
     * - Returns: A configuration object suitable for chaining or passing to the panel configure method.
     */
    public func configureColors(background: UIColor = .duxbeta_black(),
                                      border: UIColor = .duxbeta_clear(),
                                      title: UIColor = .duxbeta_white(),
                                      titleBarBackground: UIColor = .duxbeta_black(),
                                      selection: UIColor = .duxbeta_darkGray(),
                                      toolbarBackground: UIColor = .duxbeta_black(),
                                      toolbarTint : UIColor = .duxbeta_white()) -> DUXBetaPanelWidgetConfiguration {
        panelBackgroundColor = background
        panelBorderColor = border
        panelSelectionColor = selection
        titleColor = title
        titleBarBackgroundColor = titleBarBackground
        toolbarBackgroundColor = toolbarBackground
        toolbarTintColor = toolbarTint
        return self
    }
    
    /**
     * Defines the titlebar which will be used for the List or Toolbar Panel.
     *
     * - Parameters:
     *      - visible: Defines if the titlebar will be shown. No default.
     *      - withCloseBox: Shows the close box in the titlebar if true/YES. Defaults to false/NO.
     *      - withBackButton: Show the back button if true/YES. Defaults to false/NO.
     *      - title: The title to display in the titlebar. Defaults to an empty string.
     *      - titleHeight: The height for the titlebar area.  Defaults to 32 points.
     *      - titleAlignment: Defines the position for the title in the titlebar. Defaults to centered.
     *
     * - Returns: A configuration object suitable for chaining or passing to the panel configure method.
     */
    public func configureTitlebar(visible: Bool,
                                  withCloseBox: Bool = false,
                                  withBackButton: Bool = false,
                                  title: String = "",
                                  titleHeight: CGFloat = 32.0,
                                  titleAlignment: DUXBetaPanelTitleBarAlignment = .center) -> DUXBetaPanelWidgetConfiguration {
        showTitleBar = visible
        hasCloseBox = withCloseBox
        hasBackButton = withBackButton
        panelTitle = title
        titlebarHeight = titleHeight
        titleBarAlignment = titleAlignment
        return self
    }
    
    /**
     * Defines the height and width of an individual icon in the toolbar icon bar. Requires that the icon proportions are a square.
     *
     * - Parameters:
     *      - dimension: The height and width of the tool icons in the toobar panel.
     *
     * - Returns: A configuration object suitable for chaining or passing to the panel configure method.
     */
    public func configureToolbar(dimension: CGFloat) -> DUXBetaPanelWidgetConfiguration {
        self.toolbarDimension = dimension
        return self
    }
}

/**
 * DUXBetaPanelWidget is the base class for the cluster of panel classes in the DJI UXSDK. It defines the common methods for adding
 * and removing widgets from a panel and common configuraton code.
 */
@objcMembers open class DUXBetaPanelWidget : DUXBetaBaseWidget {

    // MARK: - Public Variables
    /// Has this panel finished configuration yet
    public var isConfigured = false
    /// The title of the panel in the titlebar for List and Toolbar panels
    public var panelTitle = ""
    /// The color for the background of the panel. Defaults to DUXBeta_black
    public var panelBackgroundColor = UIColor.duxbeta_black()
    /// The color for the border of the panel. Defaults to DUXBeta_clear (edgeless)
    public var panelBorderColor = UIColor.duxbeta_clear()
    /// The color for the background of the tool icon area in a toolbar panel. Defaults to DUXBeta_black
    public var panelToolbarBackgroundColor = UIColor.duxbeta_black()
    /// The tint color used to colorize the tool icon currently selected in a toolbar panel. Defaults to DUXBeta_white
    public var panelToobarTintColor = UIColor.duxbeta_white()
    /// The color used to hilight the icon selected in a toolbar panel. Defaults to DUXBeta_dakrGray
    public var panelSelectionColor = UIColor.duxbeta_darkGray()
    /// The UIView used for drawing the titlebar on a List or Toolbar panel
    public var titlebar = UIView(frame: CGRect(x: 0.0, y: 0.0, width:300.0, height: 0))
    /// The height for the titlebar in list or toolbar panels
    public var titlebarHeight: CGFloat = 0.0
    /// The widgetSizeHint is used to indicate the minimum size for the widget (panel in this case). It defaults to
    /// a minimum size of 10x10 and must be overridden in each panel subclass
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: 1, minimumWidth: 10, minimumHeight: 10)}
        set {}
    }
    

    // MARK: - Private Variables
    fileprivate var titlebarHidden = true      // Hidden nomenclature to follow UIView/UIControl conventions
    fileprivate var closeBoxHidden = true
    fileprivate var backButtonHidden = true
    fileprivate var closeBoxImage: UIImage? = nil
    fileprivate var backButtonImage: UIImage? = nil
    fileprivate var titleColor = UIColor.duxbeta_white()
    fileprivate var titleBarBackgroundColor = UIColor.duxbeta_black()
    fileprivate var titleBarAlignment: DUXBetaPanelTitleBarAlignment = .center

    internal var closeHandler: ((DUXBetaPanelWidget) -> ())? = nil

    // MARK: - Class Factory Methods
    /**
     * Class method widget creates a panel based off a defined configuration item and returns it.
     *
     * - Parameters configuration: The DUXBetaPanelWidgetConfiguration object specifiying the type of panel, variants, and configuration options.
     *
     * - Returns: A DUXBetaPanelWidget instance, fully configured.
     */
    class public func widget(configuration: DUXBetaPanelWidgetConfiguration) -> DUXBetaPanelWidget? {
        var returnObject : DUXBetaPanelWidget?
        
        switch configuration.widgetType {
        case .bar:
            returnObject = DUXBetaBarPanelWidget(variant: configuration.widgetVariant).configure(configuration)
        
        case .toolbar:
            returnObject = DUXBetaToolbarPanelWidget(variant: configuration.widgetVariant).configure(configuration)
        
        case .list:
            returnObject = DUXBetaListPanelWidget(variant: configuration.widgetVariant).configure(configuration)
        }
        
        return returnObject
    }

    // MARK: - Class Methods
    /**
     * Initializer the panel object with no parameters. Configure must be called next.
     */
    public init() {
        super.init(nibName:nil, bundle:nil)
    }
    
    /**
     * Initializer the panel object when loaded for a Storyboard or xib. Configure must be called next.
     */
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /**
     * Configures the panel settings from the passed in configuration object.
     *
     * - Parameter config: unnamed parameter which takes a configuration object defining the panel.
     *
     * - Returns: A configured DUXBetaPanelWidget subclass item.
     */
    open func configure(_ config:DUXBetaPanelWidgetConfiguration) -> DUXBetaPanelWidget {
        func copyColorConfig() {
            panelBackgroundColor = config.panelBackgroundColor
            panelBorderColor = config.panelBorderColor
            panelSelectionColor = config.panelSelectionColor

            panelToolbarBackgroundColor = config.toolbarBackgroundColor
            panelToobarTintColor = config.toolbarTintColor
            titleColor = config.titleColor
            titleBarBackgroundColor = config.titleBarBackgroundColor
        }
        copyColorConfig()
        if config.showTitleBar || config.hasCloseBox {
            self.titlebarHidden = false
        } else {
            self.titlebarHidden = true      // This will change with lists becasue sublists need a back button location
        }
        
        if self.titlebarHidden {
            self.titlebarHeight = 0.0
        } else {
            self.titlebarHeight = config.titlebarHeight
            if config.showTitleBar {
                self.panelTitle = config.panelTitle
            }
        }
        self.titleBarAlignment = config.titleBarAlignment

        self.closeBoxHidden = !config.hasCloseBox
        if config.hasCloseBox {
            closeBoxImage = UIImage.duxbeta_image(withAssetNamed: "PanelToolbarClose")
        }

        self.backButtonHidden = !config.hasBackButton
        if config.hasBackButton {
            backButtonImage = UIImage.duxbeta_image(withAssetNamed: "PanelBackArrow")
        }

        self.isConfigured = true
        return self
    }

    /**
     * Call onCloseTapped to install any external cleanup handler needed when a panel widget is closed via the close button for the panel.
     *
     * - Parameter closeHanlder: The bloock/closure which will be called when the close button on the widget is tapped. It will pass a single
     *                          argument, the panel being closed.
     */
    public func onCloseTapped(_ closeHandler: @escaping ((DUXBetaPanelWidget) -> ())) {
        self.closeHandler = closeHandler;
    }
    /**
     * The abstraction method for adding an array of existing widgets into the panel. Each item in the passed in array
     * will be added as appropriate for the specific panel type.
     *
     * - Parameter displayWidgets: unnamed parameter which takes an array of widgets descended form DUXBetaBaseWidget.
     */
    public func addWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        // TBD Add a listener to each isHidden after the subview is called. This can't be done until after widgets
        // have been inserted becasue lazy instantiation of the views means the view may not exist yet when this
        // is called on the child class.
    }
    
    /**
     * Abstract method to be overridden by each panel type to return the number of widgets being dispayed in that particular
     * panel.
     *
     * - Returns: Int/NSInteger of the count of widgets in panel.
     */
    public func widgetCount() -> Int {
        assertionFailure("DUXPanelWidget: must override widgetCount for panel classes")
        return 0
    }

    /**
     * Abstract method to be overridden by each panel type to insert a widget at the given index positon.
     *
     * - Parameters:
     *     - widget: The widget to insert into the panel.
     *     - atIndex: The position at which to insert the widget in the panel.
     *
     * - Returns: Int/NSInteger of the count of widgets in panel.
     */
    public func insert(widget: DUXBetaBaseWidget, atIndex: Int) {
        assertionFailure("DUXPanelWidget: must override insert(widget, atIndex) for panel classes")
    }
    
    /**
     * Abstract method to be overridden by each panel type to remove a widget at the given index positon.
     *
     * - Parameters:
     *     - atIndex: The position in the array of widgets in the panel to remove the widget from.
     */
    public func removeWidget(atIndex: Int) {
        assertionFailure("DUXPanelWidget: must override removeWidget(atIndex) for panel classes")
    }

    /**
     * Abstract method to be overridden by each panel type to remove all widgets from the panel.
     */
    public func removeAllWidgets() {
        assertionFailure("DUXPanelWidget: must override removeAllWidgets for panel classes")
    }

    /**
     * Abstract method to be overridden by each panel type to update the contents of the UI for the panel.
     * Most panels will invoke this method after observing changes in the widget model.
     */
    public func updateUI() {
        assertionFailure("DUXPanelWidget: must override updateUI for panel classes")
    }

    // TODO: This should set the height constraint to 0, not just hide the titlebar view
    // except for the override in the list panel which needs to keep the titlebar for the back button
    /**
     * Method to call to hide the titlebar for a panel.
     */
    public func hideTitleBar() {
        self.titlebar.isHidden = true
    }
    
    /**
     * Method to call to show the titlebar for a panel
     */
    public func showTitleBar() {
        self.titlebar.isHidden = false
    }
    
    /**
     * Override of the standard viewDidLoadMethod. This converts the titlebar for autolayout and removes any existing constraints.
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        titlebar.translatesAutoresizingMaskIntoConstraints = false
        removeConstraintsOn(view: titlebar)
        
        defaultConfigurationSetup()
    }

    /**
     * Method to override to build a customer configuration object if you want to always have a certain configuration
     * and not need to configure in the instantiating code.
     * The default implementation does nothing but is called from the base viewDidLoad of the panel cluster.
     */
    public func defaultConfigurationSetup() {
        
    }
    

    // MARK: - Private Methods
    func setupTitlebar() {
        if self.titlebarHidden {
            return
        }

        let localTitleBar = self.titlebar
        self.titlebar = localTitleBar    // Assign to the instance optional
        localTitleBar.translatesAutoresizingMaskIntoConstraints = false
        localTitleBar.layer.borderColor = panelBorderColor.cgColor
        localTitleBar.layer.borderWidth = 1.0
        localTitleBar.backgroundColor = titleBarBackgroundColor
        
        self.removeConstraintsOn(view: localTitleBar)
        localTitleBar.heightAnchor.constraint(equalToConstant: titlebarHeight).isActive = true
        
        var closeboxView: UIImageView?
        closeboxView = UIImageView(image:closeBoxImage)
        if let view = closeboxView {
            view.translatesAutoresizingMaskIntoConstraints = false
            localTitleBar.addSubview(view)
            view.isHidden = self.closeBoxHidden
        }
        
        var backButtonView: UIImageView?
        backButtonView = UIImageView(image:backButtonImage)
        if let view = backButtonView {
            view.translatesAutoresizingMaskIntoConstraints = false
            localTitleBar.addSubview(view)
            view.isHidden = self.backButtonHidden
        }
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:0, width:200, height: titlebarHeight - 4.0))
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = panelTitle
        titleLabel.textColor = titleColor
        titleLabel.textAlignment = .center
        localTitleBar.addSubview(titleLabel)

        closeboxView?.widthAnchor.constraint(equalToConstant: kCloseBoxWidthDefault).isActive = true
        closeboxView?.heightAnchor.constraint(equalToConstant: kCloseBoxHeightDefault).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: titlebarHeight - 4.0).isActive = true
        titleLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40.0).isActive = true

        backButtonView?.widthAnchor.constraint(equalToConstant: kCloseBoxWidthDefault ).isActive = true
        backButtonView?.heightAnchor.constraint(equalToConstant: kCloseBoxHeightDefault).isActive = true

        closeboxView?.centerYAnchor.constraint(equalTo: localTitleBar.centerYAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: localTitleBar.centerYAnchor).isActive = true
        backButtonView?.centerYAnchor.constraint(equalTo: localTitleBar.centerYAnchor).isActive = true
        
        backButtonView?.leadingAnchor.constraint(equalTo:localTitleBar.leadingAnchor, constant:8.0).isActive = true
       
        if titleBarAlignment == .center {
            titleLabel.centerXAnchor.constraint(equalTo:localTitleBar.centerXAnchor).isActive = true
        } else {
            if let backView = backButtonView {
                titleLabel.leadingAnchor.constraint(equalTo:backView.trailingAnchor, constant:8.0).isActive = true
            } else {
                titleLabel.leadingAnchor.constraint(equalTo:localTitleBar.leadingAnchor, constant:8.0+24.0).isActive = true
            }
        }
        closeboxView?.leadingAnchor.constraint(equalTo:titleLabel.trailingAnchor, constant:8.0).isActive = true
        closeboxView?.trailingAnchor.constraint(equalTo:localTitleBar.trailingAnchor, constant:-8.0).isActive = true
        
        let closeGesture = UITapGestureRecognizer(target: self, action: #selector(closeTapped))
        closeboxView?.isUserInteractionEnabled = true
        closeboxView?.addGestureRecognizer(closeGesture)
        
        let backRGesture = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped))
        backButtonView?.addGestureRecognizer(backRGesture)
        backButtonView?.isUserInteractionEnabled = true
    }
    
    /**
     * The closeTapped method can be called to close the current list. It is also used to process closing by the user.
     */
    @IBAction public func closeTapped() {
        // TODO: Add a bock callback to notify the original installer that this is about to close.
        self.view.removeFromSuperview()
        self.removeFromParent()

        if let closeCompletionBlock = self.closeHandler {
            closeCompletionBlock(self)
        }
    }
    
    @IBAction func backButtonTapped() {
        // TODO: Add a bock callback to notify the original installer that this is about to close.
    }

    //MARK: Observing for hiding/showing widgets
    /**
     The observeValue method is used to implement KVO to trigger updateUI when an widget is hidden or shown.
     */
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let change = change, let keyPath = keyPath {
            if (keyPath == "hidden") && (change[.newKey] != nil) {
                self.updateUI()
            }
        }
    }

    //MARK: Constraint Manipulation
    func removeConstraintsOn(view: UIView) {
        var superV = view.superview
        while let superview = superV {
            for constraint in superview.constraints {
                if (constraint.firstItem as? UIView == view) || (constraint.secondItem as? UIView == view) {
                    superview.removeConstraint(constraint)
                }
            }
            superV = superview.superview
        }
    }

    func removeHeightAndWidthConstraintsOn(view: UIView) {
        for constraint in view.constraints {
            if ((constraint.firstAttribute == .height) || (constraint.firstAttribute == .width) ) &&
            (constraint.firstItem as? UIView == view) {
                view.removeConstraint(constraint)
            }
        }
    }

}
