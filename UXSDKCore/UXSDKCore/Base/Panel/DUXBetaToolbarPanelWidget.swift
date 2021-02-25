//
//  DUXBetaToolbarWidget.swift
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

/// Default Toolbar panel width
fileprivate let kMinPanelWidth: CGFloat = 100.0
/// Default Toolbar panel height
fileprivate let kMinPanelHeight: CGFloat = 144.0

/**
 * DUXBetaToolbarPanelWidget descends from DUXBetaPanelWidget and implements the DUXBetaToolbarPanelSupportProtocol. It implements
 * the Toolbar Panel.
 *
 * The Toolbar shows a row of icons, selecting a single icon shows the widget in the panel area.
 */
@objcMembers open class DUXBetaToolbarPanelWidget : DUXBetaPanelWidget, DUXBetaToolbarPanelSupportProtocol {
    // MARK: - Public Variables
    /// The icon to represet this toolbar panel in a nesting toolbar situation
    public var toolbarImage: UIImage?
    /// The name to show for this toobar panel in a nesting toolbar situation
    public var toolbarItemName: String?
    /// The standard widgetSizeHint indicating the minimum size for this widget and prefered aspect ratio
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (panelSize.width / panelSize.height), minimumWidth: panelSize.width, minimumHeight: panelSize.height)}
        set {
        }
    }

    // MARK: - Private Variables
    fileprivate var toolbarEdge: DUXBetaPanelVariant = .top
    fileprivate var panelSize = CGSize(width: kMinPanelWidth, height: kMinPanelHeight)

    fileprivate var panelItemList: [DUXBetaToolbarPanelItemTemplate] = [DUXBetaToolbarPanelItemTemplate]()
    fileprivate var recognizerList : [ToolRecognizer] = [ToolRecognizer]()
    fileprivate var currentSelectedIndex = NSNotFound
    
    fileprivate var toolbarDimension: CGFloat = 44
    fileprivate var toolView = UIView()

    fileprivate var toolbarIconFont: UIFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    
    fileprivate var scrollView = UIScrollView()
    fileprivate var toolHeadersStackView = UIStackView()

    fileprivate var internalLayoutDone = false
    fileprivate var initialToolbarUIDone = false
    fileprivate var internalSetupDone = false
    fileprivate var internalDelayedUIUpdate = false

    //MARK: - Instance Methods
    //MARK: DUXBetaToolbarPanelWidget

    /**
     * The default init method for the class when loading from a Storyboard or Xib.
     */
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * The default init method for the class. Sets the orientation to horiztonal.
     */
    override public init() {
        super.init()
    }
    
    /**
     * The init method for creating an instance of a bar panel with the tools on the specified edge.
     *
     * - Parameter variant: The variant specifying which edge the tools are along.
     */
    public init(variant: DUXBetaPanelVariant) {
        self.toolbarEdge = variant
        super.init()
    }
    
    /**
     * Override of configure method. Takes the configuration object and extracts the specific part needed for this
     * widget (side variant) and tool icon dimension and calls the parent configuration for the remainder of the processing.
     *
     * - Returns: This object instance for call chaining.
     */
    override public func configure(_ configuration:DUXBetaPanelWidgetConfiguration) -> DUXBetaToolbarPanelWidget {
        let _ = super.configure(configuration)
        
        guard ((configuration.widgetVariant == .top)
            || (configuration.widgetVariant == .left)
            || (configuration.widgetVariant == .right)) else {
            assertionFailure("DUXBetaToolbarWidget varient must be one of .top, .left, right")
            return DUXBetaToolbarPanelWidget()
        }
        
        self.toolbarEdge = configuration.widgetVariant
        self.toolbarDimension = configuration.toolbarDimension
        if (view != nil) && !internalSetupDone {
            setupUI()
            if internalDelayedUIUpdate {
                updateUI()
            }
        }
        return self
    }


    /**
     * Override of the standard viewdDidLoad. Sets the parent view for autolayout and if the widget has already been
     * configured, calls setupUI.
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        if isConfigured {
            setupUI()
        }
    }
    
    //MARK: - Bar content control
    /**
     * The addWidgetArray method adds the widgets into the internal widget list and calls updateUI to redraw the toobar.
     *
     * - Parameter displayWidgets: unnamed array of widgets subclassed from from DXBaseWidget.
     */
    public override func addWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        displayWidgets.forEach {
            panelItemList.append(DUXBetaToolbarPanelItemTemplate.init(widget: $0, icon: nil, title: nil))
        }
        updateUI()
    }

    /**
     * The addPanelToolsArray method adds an array of predefined DUXBetaToolbarPanelItemsTemplates into the tool array
     * using the template to define the displayed tools by classname and other information. It then calls updateUI to refresh
     * the toolbar.
     *
     * - Parameter panelTools: unnamed array of DUXBetaToolbarPanelItemTemplate items.
     */
    public func addPanelToolsArray(_ panelTools: [DUXBetaToolbarPanelItemTemplate]) {

        panelItemList.append(contentsOf: panelTools)
        updateUI()
    }

    /**
     * The method widgetCount returns the number of widgets in the toolbar panel.
     *
     * - Returns: Interer/NSInteger number of widgets in the toobar panel.
     */
    override public func widgetCount() -> Int {
        return panelItemList.count
    }

    /**
     * The insert method inserts the given widget into the toolbar array at the given index.
     * Indexing is from leading to trailing side or top to bottom depending on the panel variant. updateUI is then called
     *
     * - Parameters:
     *      -  widget: The widget subclassed from from DXBaseWidget to insert.
     *      - atIndex: The index at which to insert the widget in the toolbar array.
     */
    override public func insert(widget: DUXBetaBaseWidget, atIndex: Int) {
        let widgetTemplate = DUXBetaToolbarPanelItemTemplate.init(widget: widget, icon: nil, title: nil)
        insert(itemTemplate: widgetTemplate, atIndex: atIndex)
    }

    /**
     * The insert method inserts the given itemTemplate into the toolbar array at the given index using the settings in
     * the DUXBetaToolbarPanelItemTemplate object.
     * Indexing is from leading to trailing side or top to bottom depending on the panel variant. updateUI is then called.
     *
     * - Parameters:
     *      - itemTemplate: The widget defining the DUXBetaToolbarPanelItemTemplate object to insert.
     *      - atIndex: The index at which to insert into the toolbar array.
     */
    public func insert(itemTemplate: DUXBetaToolbarPanelItemTemplate, atIndex: Int) {
        if (currentSelectedIndex != NSNotFound) && (atIndex <= currentSelectedIndex) {
            // Inserting before out selected index. We need to massage the selection.
            currentSelectedIndex += 1
        }
        self.panelItemList.insert(itemTemplate, at: atIndex)
        if internalSetupDone && !internalDelayedUIUpdate {
            insertToolHeaderFromTemplate(itemTemplate, at: atIndex)
            self.updateUI()
        }
    }

    /**
     * The method removeWidget handles removing both widget and template bassed toolbars. This simplified interface
     * removes the appropriate entries at the given index.
     *
     * - Parameters:
     *      - atIndex: The index from which to remove the item from the toolbar.
    */
    public override func removeWidget(atIndex: Int) {
        if (currentSelectedIndex != NSNotFound) && (currentSelectedIndex >= atIndex) {
            // Need to shift the selection down. If the selection is the current item
            // set to 0 if there is an element 0 left
            if currentSelectedIndex == atIndex {
                self.removeWidgetFromToolView()
                
                if currentSelectedIndex == atIndex {
                    currentSelectedIndex = NSNotFound
                }
            } else {
                currentSelectedIndex -= 1
            }
        }
        removeToolHeader(at: atIndex)
        self.panelItemList.remove(at: atIndex)
        self.updateUI()
    }

    /**
     * The method removeWidget removes all widgets from both widget and template based toolbars.
    */
    public override func removeAllWidgets() {
        self.recognizerList.removeAll()
        self.panelItemList.removeAll()
        self.removeAllToolHeaders()
        self.removeWidgetFromToolView()
        currentSelectedIndex = NSNotFound
        self.updateUI()
    }

    //MARK: - UI Setup and Update
    func setupUI() {
        if (internalSetupDone) { return }
        
        self.view.backgroundColor = .uxsdk_black()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolHeadersStackView.translatesAutoresizingMaskIntoConstraints = false
        toolView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addSubview(toolView)
        internalSetupDone = true

        if toolbarEdge == .top {
            toolHeadersStackView.axis = .horizontal
            toolHeadersStackView.distribution = .fill
            toolHeadersStackView.alignment = .leading
            
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.heightAnchor.constraint(equalToConstant: toolbarDimension).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            toolHeadersStackView.heightAnchor.constraint(equalToConstant: toolbarDimension).isActive = true

        } else if (toolbarEdge == .left) {
            toolHeadersStackView.axis = .vertical
            toolHeadersStackView.distribution = .fill
            toolHeadersStackView.alignment = .leading
            
            scrollView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            scrollView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
            scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            toolHeadersStackView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
        } else if (toolbarEdge == .right) {
            toolHeadersStackView.axis = .vertical
            toolHeadersStackView.distribution = .fill
            toolHeadersStackView.alignment = .leading

            scrollView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            scrollView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
            scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
 
            toolHeadersStackView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
}

        scrollView.addSubview(toolHeadersStackView)
        NSLayoutConstraint.activate([
            toolHeadersStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            toolHeadersStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            toolHeadersStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            toolHeadersStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        ])
        
        layoutInternals()
        
        if internalDelayedUIUpdate {
            updateUI()
        }
    }
    /**
     * The method layoutInternals is a lazy instantiation of the scrollbar location. It should normally be called only once,
     * when panel tools are finally added. If the setupUI runs before configuration happens, the default is a top toolbar
     * which may not be desired, so this can be called when updateUI is first run
     */
    func layoutInternals() {
        if internalLayoutDone {
            return
        }
        
        self.setupTitlebar()

        self.view.addSubview(titlebar)
        titlebar.leadingAnchor.constraint(equalTo:self.view.leadingAnchor).isActive = true
        titlebar.trailingAnchor.constraint(equalTo:self.view.trailingAnchor).isActive = true
        titlebar.topAnchor.constraint(equalTo:self.view.topAnchor).isActive = true
        
        internalLayoutDone = true
    }
        
    func removeToolHeader(at: Int) {
        recognizerList.remove(at: at)
        let removeView = toolHeadersStackView.arrangedSubviews[at]
        toolHeadersStackView.removeArrangedSubview(removeView)
    }
    
    func removeAllToolHeaders() {
        recognizerList.removeAll()
        let subViews = toolHeadersStackView.arrangedSubviews
        subViews.forEach {
            toolHeadersStackView.removeArrangedSubview($0)
        }
    }
    
    func insertToolHeaderFromTemplate(_ toolItemTemplate: DUXBetaToolbarPanelItemTemplate, at: Int) {
        let toolIcon = DUXBetaToolHeaderView(image: toolItemTemplate.barIcon, title: toolItemTemplate.barName, labelFont: nil, height: toolbarDimension)
        toolIcon.highlightStyle = toolItemTemplate.highlightStyle
        toolIcon.highlightThickness = toolItemTemplate.highlightThickness
        toolIcon.highlightColor = panelSelectionColor   // This comes from the panel configuration, not the tool template
        
        toolHeadersStackView.insertArrangedSubview(toolIcon, at: at)
        recognizerList.insert(ToolRecognizer(toolIconView: toolIcon, self), at: at)

        switch self.toolbarEdge {
            case .top:
                toolIcon.heightAnchor.constraint(equalTo:toolHeadersStackView.heightAnchor).isActive = true
                toolIcon.widthAnchor.constraint(equalTo:toolHeadersStackView.heightAnchor).isActive = true

            case .left, .right:
                toolIcon.heightAnchor.constraint(equalTo:toolHeadersStackView.widthAnchor).isActive = true
                toolIcon.widthAnchor.constraint(equalTo:toolHeadersStackView.widthAnchor).isActive = true

            default:
                assertionFailure("This class does not support this bar variant /(self.variant)")
        }
}
    
    /**
     * The updateUI method is the standard mechanism for redrawing the UI when something in the panel changes.
    */
    @objc public override func updateUI() {
        if internalSetupDone == false {
            internalDelayedUIUpdate = true
            return
        }
        internalDelayedUIUpdate = false
        
        var maxWidth : CGFloat = 0.0
        var maxHeight : CGFloat = 0.0
                
        if !initialToolbarUIDone {
            // Part 1. Create all the tooblar items on initial setup. This will use either
            // the PanelItemTemplates or the actual widgets. This means an array should
            // be used for initial setup or we won't guess the display size right for widgets
            for toolItemTemplate in panelItemList {
                insertToolHeaderFromTemplate(toolItemTemplate, at: toolHeadersStackView.arrangedSubviews.count)
            }
            initialToolbarUIDone = true
        }

        for (index, iconView) in toolHeadersStackView.arrangedSubviews.enumerated() {
            if let iv = iconView as? DUXBetaToolHeaderView {
                iv.selected = (index == currentSelectedIndex)
            } else {
                // This should never happen
                assert(false, "Non-DUXBetaToolHeaderView in toolbar headers")
            }
        }
        switch self.toolbarEdge {
        case .top:
            panelSize.height = maxHeight + toolbarDimension + self.titlebarHeight
            panelSize.height = max(panelSize.height, kMinPanelHeight)
            panelSize.width = max(maxWidth, kMinPanelWidth)
        break
            
        case .left, .right:
            panelSize.width = max(maxWidth + toolbarDimension, kMinPanelWidth)
            panelSize.height = max(maxHeight + self.titlebarHeight, kMinPanelHeight)
        break
        default:
            assertionFailure("This class does not support this bar variant /(self.variant)")
        }

        view.layoutIfNeeded()
    }

    //MARK: - Widget selection
    /**
     * The method selectedToolIndex returns the index of the selected tool in the toolbar.
     *
     * - Returns: Int/NSInteger indicating which toolbar item in the tool array is currently selected.
     */
    public func selectedToolIndex() -> Int {
        return currentSelectedIndex
    }
    
    /**
     * The method widgetIndex returns the index in the tool array for the widget passed in.
     *
     * - Parameter forWidget: The widget to find in the tool array
     *
     * - Returns: the index of the found widget (Int/NSInteger) or NSNotFound
     *
     */
   public func widgetIndex(forWidget: DUXBetaBaseWidget) -> Int {
        for (index, element) in panelItemList.enumerated() {
            if element.matchesWidget(forWidget) {
                return index
            }
        }
        return NSNotFound
    }
    
    /**
     * The selectTool method selects the tool specified in the tool array form the index passed in. If the panel is displaying
     * template based widgets, the widget will be created if it doesn't exist already.
     *
     * - Parameter index: The index of the tool widget to activate in the main tool area.
     */
    public func selectTool(index: Int) {
        guard index != NSNotFound else {
            return
        }
        
        if index == currentSelectedIndex {
            return
        }
        
        // Remove the currently shown tool from the toolView.
        let subViewArray: [UIView] = self.toolView.subviews
        for aView in subViewArray {
            aView.removeFromSuperview()
        }
        
        // Now set the highlighted for the propper tool and disable it for others
        for (toolHeaderIndex, iconView) in toolHeadersStackView.arrangedSubviews.enumerated() {
            if let iv = iconView as? DUXBetaToolHeaderView {
                iv.selected = (toolHeaderIndex == index)
            } else {
                // This should never happen
                assert(false, "Non-DUXBetaToolHeaderView in toolbar headers")
            }
        }

        let template = self.panelItemList[index]
        if let widget = template.widget() {
            self.insertIntoToolView(widget:widget)

        }

        // This will clean up the old widget if we don't want to keep it alive. This MUST
        // be done before we reset the currentSelectedIndex or we need to keep a copy of the index around
        if currentSelectedIndex != NSNotFound {
            let oldTemplate = self.panelItemList[currentSelectedIndex]
            oldTemplate.releaseWidgetIfNeeded()
        }

        currentSelectedIndex = index
    }
    
    /**
     * The utility method selectToolFromHeader takes the header from the gesture recognizer which was tapped and selects the tool
     * specified by the tool header item
     */
    public func selectToolFromHeader(headerView: UIView) {
        for (index, toolHeaderView) in toolHeadersStackView.arrangedSubviews.enumerated() {
            if toolHeaderView == headerView {
                selectTool(index: index)
                break
            }
        }
    }
    
    func removeWidgetFromToolView() {
        for subview in toolView.subviews {
            // Only valid on iOS and tvOS because subviews returns a copy so we aren't
            // mutating the actual subviews list
            subview.removeFromSuperview()
        }
    }
    
    func insertIntoToolView(widget: DUXBetaBaseWidget) {
        guard let widgetView = widget.view else {
            return
        }

        toolView.addSubview(widgetView)
        
        
        // Now we have a special case of a panel nesting inside another panel. We need to maximize that entire area
        // The good news is that we know the toolView is the maximized area already, so just pin to the edges
        if let _ = widget as? DUXBetaPanelWidget {
            widgetView.topAnchor.constraint(equalTo:toolView.topAnchor).isActive = true
            widgetView.leadingAnchor.constraint(equalTo:toolView.leadingAnchor).isActive = true
            widgetView.bottomAnchor.constraint(equalTo:toolView.bottomAnchor).isActive = true
            widgetView.rightAnchor.constraint(equalTo:toolView.rightAnchor).isActive = true

            return
        }
        
        // If it isn't already a subpanel, do lots of math to maximize the size. (This may have a small
        // problem because sizes haven't been correctly fitted before layoutSubviews has been called,
        // but it appears to work correctly.
        widgetView.centerXAnchor.constraint(equalTo:toolView.centerXAnchor).isActive = true
        widgetView.centerYAnchor.constraint(equalTo:toolView.centerYAnchor).isActive = true
        let widthRatio: CGFloat = widgetView.bounds.size.width / toolView.bounds.size.width
        let heightRatio: CGFloat = widgetView.bounds.size.height / toolView.bounds.size.height

        // TODO: This code still needs comprehensive testing and a complete test plan. Develomental testing appears to show
        // it working correctly. This probably could probably be refactored into a smaller routines
        if (widthRatio <= 1.0) && (heightRatio <= 1.0) {
            // widget is entirely smaller than the tool area. Already centered but height and width need to be set because
            // we just added it to the subview. It may have been added before and removed, so it's proportions are correct,
            // but the constraints were removed when it got pulled out of the view hierarchy.
            widgetView.heightAnchor.constraint(equalTo:toolView.heightAnchor, multiplier: heightRatio).isActive = true
            widgetView.widthAnchor.constraint(equalTo:toolView.widthAnchor, multiplier: widthRatio).isActive = true
        } else if (widthRatio > 1.0) && (heightRatio <= 1.0) {
            // This needs to shrink width wise and keep height relative to width
            widgetView.heightAnchor.constraint(equalTo: widgetView.widthAnchor, multiplier: widgetView.bounds.size.height / widgetView.bounds.size.width).isActive = true
            widgetView.widthAnchor.constraint(equalTo: toolView.widthAnchor, multiplier: 1.0/widthRatio).isActive = true

        } else if (widthRatio <= 1.0) && (heightRatio > 1.0) {
            // The widget needs to shrink heigh wise and keep aspect ratio
            widgetView.widthAnchor.constraint(equalTo: widgetView.heightAnchor, multiplier: widgetView.bounds.size.width / widgetView.bounds.size.height).isActive = true
            widgetView.heightAnchor.constraint(equalTo: toolView.heightAnchor, multiplier: 1.0/heightRatio).isActive = true
        } else {
            // Both widthRatio and heightRatio are > 1.0.
            // Find the larger ratio and use it as the inverse for both height and width dimension to keep it in bounds
            if widthRatio > heightRatio {
                let heightWidthRatio:CGFloat = widgetView.bounds.size.height / widgetView.bounds.size.width
                widgetView.heightAnchor.constraint(equalTo: toolView.heightAnchor, multiplier: heightWidthRatio).isActive=true
                widgetView.widthAnchor.constraint(equalTo: toolView.widthAnchor).isActive = true
            } else {
                let widthHeightRatio:CGFloat = widgetView.bounds.size.width / widgetView.bounds.size.height
                widgetView.heightAnchor.constraint(equalTo: toolView.heightAnchor).isActive=true
                widgetView.widthAnchor.constraint(equalTo: toolView.widthAnchor, multiplier: widthHeightRatio).isActive = true
            }
        }
        
    }

    //MARK: Support for including toolbar panels within toolbar panels
    
    public func toolbarItemTitle() -> String? {
        return toolbarItemName
    }
    
    public func toolbarItemIcon() -> UIImage? {
        return toolbarImage
    }

}

/**
 * Class DUXBetaToolHeaderView is a UIView class which is used for the ToolbarPanel icons and names and selection highlighting.
 */
@objcMembers open class DUXBetaToolHeaderView : UIView {
    var highlightStyle:ToolHeaderHighlightStyle = .underline {
        didSet {
            NSLayoutConstraint.deactivate(hilightingView.constraints)
        }
    }
    var highlightColor : UIColor = .uxsdk_selectedBlue()
    var highlightThickness : CGFloat = 3.0
    var displayLabel: UILabel?
    var displayIcon: UIImageView?
    var selected: Bool = false {
        didSet {
            drawHilighting()
        }
    }
    fileprivate var contentsView: UIView = UIView(frame:CGRect(x: 0, y: 0, width: 10, height: 10))
    fileprivate var hilightingView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    /**
     * The init method takes the image and title. Both are optional, but at least one of the two must be supplied.
     * The title font is set with the labelFont optional parameter. If labelFont is nil, the defult of systemFont 14.0 is used.
     * Width or height is required. Used Height for top oriented toolbars, and width for side toolbars.
     *
     * - Parameter image: A UIImage to use. Optional
     * - Parameter title: A String to use. Optional
     * - Parameter labelFont: The UIFont used to draw the title. Optional
     * - Parameter width: The width to use for this toolbar icon header. May be 0 if height is set.
     * - Parameter height: The height to use for this toolbar icon header. May be 0 if width is set.
     */
    public init(image: UIImage?, title: String?, labelFont: UIFont?, width: CGFloat = 0, height: CGFloat = 0) {
        super.init(frame:CGRect(x: 0, y: 0, width: 10, height: 10))
        backgroundColor = .uxsdk_clear()
        contentsView.translatesAutoresizingMaskIntoConstraints = false
        hilightingView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentsView)
        self.addSubview(hilightingView)
        constructToolIcon(image: image, title: title, labelFont: labelFont, width: width, height: height)
    }
    
    /**
     * The required initWithCoder method for the class. Don't use.
     */
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func constructToolIcon(image: UIImage?, title: String?, labelFont: UIFont?, width: CGFloat = 0, height: CGFloat = 0) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .uxsdk_clear()
        
        // 3 cases. image, title, image + title
        if let title = title {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.numberOfLines = 1
            label.font = labelFont ?? UIFont.systemFont(ofSize: 14.0)
            label.textColor = .uxsdk_white()
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            
            displayLabel = label
            contentsView.addSubview(label)
            label.sizeToFit()
        }
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            displayIcon = imageView
            contentsView.addSubview(imageView)
        }
        
        // With an image title, and underline, the image should be about 42% of the height/width
        // Title is about 20%
        // Line is 3 points thick
        // 72 point high image is 31.68, label is 14, gap is 6% = 4.32pt 50 points. Line is 3, line inset is 4.
        if let imageView = displayIcon, let label = displayLabel {
            
            let imageRatio: CGFloat = imageView.bounds.size.width / imageView.bounds.size.height
            imageView.heightAnchor.constraint(equalTo:self.heightAnchor, multiplier: 0.42).isActive = true
            imageView.widthAnchor.constraint(equalTo:imageView.heightAnchor, multiplier: imageRatio).isActive = true
            imageView.centerXAnchor.constraint(equalTo: contentsView.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo:contentsView.topAnchor).isActive = true
            
            label.centerXAnchor.constraint(equalTo: contentsView.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant:4.0).isActive = true
            label.bottomAnchor.constraint(equalTo: contentsView.bottomAnchor).isActive = true
            
        } else if let imageView = displayIcon {
            
            let imageRatio: CGFloat = imageView.bounds.size.width / imageView.bounds.size.height
            imageView.heightAnchor.constraint(equalTo:self.heightAnchor, multiplier: 0.70 ).isActive = true
            imageView.widthAnchor.constraint(equalTo:imageView.heightAnchor, multiplier: imageRatio).isActive = true
            
            imageView.centerXAnchor.constraint(equalTo: contentsView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: contentsView.centerYAnchor).isActive = true
        } else if let label = displayLabel {
            
            label.centerXAnchor.constraint(equalTo: contentsView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: contentsView.centerYAnchor).isActive = true
            label.widthAnchor.constraint(equalTo: contentsView.widthAnchor, constant: 12*8.0).isActive = true
            
        }
        
        if (width == 0.0) && (height > 0.0) {
            let ratio: CGFloat = self.bounds.size.width / self.bounds.size.height;
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
            self.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: ratio, constant: 0.0).isActive = true

        } else if (width > 0.0) && (height == 0.0) {
            let ratio: CGFloat = self.bounds.size.height / self.bounds.size.width;
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
            self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ratio, constant: 0.0).isActive = true
        } else {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        
        contentsView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        contentsView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        
    }

    open func drawHilighting() {
        switch highlightStyle {
            case .fill:
                if selected {
                    if hilightingView.constraints.count == 0 {
                        // Not setup yet
                        NSLayoutConstraint.activate([
                            hilightingView.topAnchor.constraint(equalTo:self.topAnchor),
                            hilightingView.leadingAnchor.constraint(equalTo:self.leadingAnchor),
                            hilightingView.bottomAnchor.constraint(equalTo:self.bottomAnchor),
                            hilightingView.trailingAnchor.constraint(equalTo:self.trailingAnchor)
                        ])
                        sendSubviewToBack(hilightingView)
                    }
                    self.hilightingView.backgroundColor = highlightColor
                } else {
                    self.hilightingView.backgroundColor = .uxsdk_clear()
                }

            case .underline:
                if (selected) {
                    if hilightingView.constraints.count == 0 {
                        // Not setup yet
                        NSLayoutConstraint.activate([
                            hilightingView.bottomAnchor.constraint(equalTo:self.bottomAnchor, constant: -4.0),
                            hilightingView.topAnchor.constraint(equalTo:hilightingView.bottomAnchor, constant: -4.0),
                            hilightingView.leadingAnchor.constraint(equalTo:self.leadingAnchor, constant: highlightThickness),
                            hilightingView.trailingAnchor.constraint(equalTo:self.trailingAnchor, constant: -4.0)
                        ])
                        sendSubviewToBack(hilightingView)
                    }
                    self.hilightingView.backgroundColor = highlightColor
                } else {
                    self.hilightingView.backgroundColor = .uxsdk_clear()
                }

            case .edges:
                if (selected) {
                    if hilightingView.constraints.count == 0 {
                        // Not setup yet
                        NSLayoutConstraint.activate([
                            hilightingView.topAnchor.constraint(equalTo:self.topAnchor),
                            hilightingView.leadingAnchor.constraint(equalTo:self.leadingAnchor),
                            hilightingView.bottomAnchor.constraint(equalTo:self.bottomAnchor),
                            hilightingView.trailingAnchor.constraint(equalTo:self.trailingAnchor)
                        ])
                        hilightingView.layer.borderWidth = highlightThickness
                        sendSubviewToBack(hilightingView)
                    }
                    hilightingView.layer.borderColor = highlightColor.cgColor
                } else {
                    hilightingView.layer.borderColor = UIColor.uxsdk_clear().cgColor
                }
        }
    }
}
