//
//  DUXToolbarWidget.swift
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

/// Default Toolbar panel width
fileprivate let kMinPanelWidth: CGFloat = 100.0
/// Default Toolbar panel height
fileprivate let kMinPanelHeight: CGFloat = 144.0

/**
 * DUXToolbarPanelWidget descends from DUXPanelWidget and implements the DUXToolbarPanelSupportProtocol. It implements
 * the Toolbar Panel.
 *
 * The Toolbar shows a row of icons, selecting a single icon shows the widget in the panel area.
 */
@objcMembers open class DUXToolbarPanelWidget : DUXPanelWidget, DUXToolbarPanelSupportProtocol {
    // MARK: - Public Variables
    /// Is this toolbar using template icons or actual images
    public var usingTemplates: Bool = false
    /// The icon to represet this toolbar panel in a nesting toolbar situation
    public var toolbarImage: UIImage?
    /// The name to show for this toobar panel in a nesting toolbar situation
    public var toolbarItemName: String?
    /// The toolbar header views (icon views) for any overriding class to access
    public var toolHeaderViews: [UIView] = [UIView]()
    /// The standard widgetSizeHint indicating the minimum size for this widget and prefered aspect ratio
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (panelSize.width / panelSize.height), minimumWidth: panelSize.width, minimumHeight: panelSize.height)}
        set {
        }
    }

    // MARK: - Private Variables
    fileprivate var templateOrWidgetSelected = false
    fileprivate var toolbarEdge: DUXPanelVariant = .top
    fileprivate var panelSize = CGSize(width: kMinPanelWidth, height: kMinPanelHeight)

    // If we init with the PanelItemTemplates, we can not allow adding via the addWidgetArray or addWidget methods
    // Unless we create a PanelItemTemplate for each one.
    fileprivate var widgetList : [DUXBetaBaseWidget] = [DUXBetaBaseWidget]()
    fileprivate var panelItemList: [DUXToolbarPanelItemTemplate] = [DUXToolbarPanelItemTemplate]()
    fileprivate var recognizerList : [ToolRecognizer] = [ToolRecognizer]()
    fileprivate var currentSelectedIndex = NSNotFound
    
    fileprivate var toolbarDimension: CGFloat = 44
    fileprivate var toolView = UIView()

    fileprivate var toolbarIconFont: UIFont = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    
    fileprivate var scrollView = UIScrollView()
    fileprivate var internalLayoutDone = false
    fileprivate var initialToolbarUIDone = false

    //MARK: - Instance Methods
    //MARK: DUXToolbarPanelWidget

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
    public init(variant: DUXPanelVariant) {
        self.toolbarEdge = variant
        super.init()
    }
    
    /**
     * Override of configure method. Takes the configuration object and extracts the specific part needed for this
     * widget (side variant) and tool icon dimension and calls the parent configuration for the remainder of the processing.
     *
     * - Returns: This object instance for call chaining.
     */
    override public func configure(_ configuration:DUXPanelWidgetConfiguration) -> DUXToolbarPanelWidget {
        let _ = super.configure(configuration)
        
        guard ((configuration.widgetVariant == .top)
            || (configuration.widgetVariant == .left)
            || (configuration.widgetVariant == .right)) else {
            assertionFailure("DUXToolbarWidget varient must be one of .top, .left, right")
            return DUXToolbarPanelWidget()
        }
        
        self.toolbarEdge = configuration.widgetVariant
        self.toolbarDimension = configuration.toolbarDimension
        return self
    }

    /**
     * Override of the standard viewdDidLoad. Sets the parent view for autolayout and if the widget has already been
     * configured, calls setupUI.
     */
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        if self.isConfigured {
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
        if templateOrWidgetSelected && usingTemplates {
            assertionFailure("DUXPanelWidget: panel already using DUXToolbarPanelItemTemplate objects")
        }
        usingTemplates = false
        templateOrWidgetSelected = true // Just blind update instead of lots of state checking
        
        widgetList.append(contentsOf: displayWidgets)
        self.updateUI()
    }

    /**
     * The addPanelToolsArray method adds an array of predefined DUXToolbarPanelItemsTemplates into the tool array
     * using the template to define the displayed tools by classname and other information. It then calls updateUI to refresh
     * the toolbar.
     *
     * - Parameter panelTools: unnamed array of DUXToolbarPanelItemTemplate items.
     */
    public func addPanelToolsArray(_ panelTools: [DUXToolbarPanelItemTemplate]) {
        if templateOrWidgetSelected && !usingTemplates {
            assertionFailure("DUXPanelWidget: panel already using widget objects")
        }
        usingTemplates = true
        templateOrWidgetSelected = true // Just blind update instead of lots of state checking

        self.panelItemList.append(contentsOf: panelTools)
        self.updateUI()
    }

    /**
     * The method widgetCount returns the number of widgets in the toolbar panel.
     *
     * - Returns: Interer/NSInteger number of widgets in the toobar panel.
     */
    override public func widgetCount() -> Int {
        var count = 0
        if templateOrWidgetSelected {
            if usingTemplates {
                count = self.panelItemList.count
            } else {
                count = self.widgetList.count
            }
        }

        return count
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
        if usingTemplates {
            assertionFailure("DUXPanelWidget: inserting DUXBetaBaseWidget in DUXToolbarPanelWidget when expecting DUXToolbarPanelItemTemplate")
        } else {
            if (currentSelectedIndex != NSNotFound) && (atIndex <= currentSelectedIndex) {
                // Inserting before out selected index. We need to massage the selection.
                currentSelectedIndex += 1
            }
            usingTemplates = false
            templateOrWidgetSelected = true
            self.widgetList.insert(widget, at: atIndex)
            insertToolHeaderFromWidget(widget, at: atIndex)
            self.updateUI()
        }
    }

    /**
     * The insert method inserts the given itemTemplate into the toolbar array at the given index using the settings in
     * the DUXToolbarPanelItemTemplate object.
     * Indexing is from leading to trailing side or top to bottom depending on the panel variant. updateUI is then called.
     *
     * - Parameters:
     *      - itemTemplate: The widget defining the DUXToolbarPanelItemTemplate object to insert.
     *      - atIndex: The index at which to insert into the toolbar array.
     */
    public func insert(itemTemplate: DUXToolbarPanelItemTemplate, atIndex: Int) {
        if usingTemplates {
            if (currentSelectedIndex != NSNotFound) && (atIndex <= currentSelectedIndex) {
                // Inserting before out selected index. We need to massage the selection.
                currentSelectedIndex += 1
            }
            usingTemplates = true
            templateOrWidgetSelected = true // Just blind update instead of lots of state checking
            self.panelItemList.insert(itemTemplate, at: atIndex)
            insertToolHeaderFromTemplate(itemTemplate, at: atIndex)
            self.updateUI()
        } else {
            assertionFailure("DUXPanelWidget: must override insert(widget, atIndex) for panel classes")
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
                self.drawHilighting(selected: false, at: currentSelectedIndex)
                
                if currentSelectedIndex == atIndex {
                    currentSelectedIndex = NSNotFound
                }
            } else {
                currentSelectedIndex -= 1
            }
        }
        removeToolHeader(at: atIndex)
        if usingTemplates {
            self.panelItemList.remove(at: atIndex)
        } else {
            self.widgetList.remove(at: atIndex)
        }
        self.updateUI()
    }

    /**
     * The method removeWidget removes all widgets from both widget and template based toolbars.
    */
    public override func removeAllWidgets() {
        self.recognizerList.removeAll()
        if usingTemplates {
            self.panelItemList.removeAll()
        } else {
            self.widgetList.removeAll()
        }
        
        self.removeAllToolHeaders()
        self.removeWidgetFromToolView()
        currentSelectedIndex = NSNotFound
        self.updateUI()
    }

    //MARK: - UI Setup and Update
    func setupUI() {
        self.view.backgroundColor = .duxbeta_black()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        toolView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        self.view.addSubview(toolView)
        
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

        // Setup constraints for the scrollView and the toolView so they are positioned correctly
        if toolbarEdge == .top {
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.heightAnchor.constraint(equalToConstant: toolbarDimension).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
        } else if (toolbarEdge == .left) {
            scrollView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            scrollView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
            scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.scrollView.trailingAnchor).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
        } else if (toolbarEdge == .right) {
            scrollView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true    // This needs to be the panel title if showing.
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            scrollView.widthAnchor.constraint(equalToConstant: toolbarDimension).isActive = true
            scrollView.bottomAnchor.constraint(equalTo:self.view.bottomAnchor).isActive = true  // This needs to be expandable once the final dimension is set after updateUI is called.
            
            // Propbably add some margins in here after seeing how this looks
            toolView.topAnchor.constraint(equalTo:self.view.topAnchor, constant:self.titlebarHeight).isActive = true
            toolView.trailingAnchor.constraint(equalTo: self.scrollView.leadingAnchor).isActive = true
            toolView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            toolView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        }

        internalLayoutDone = true
    }
        
    func removeToolHeader(at: Int) {
        recognizerList.remove(at: at)
        toolHeaderViews.remove(at: at)
    }
    
    func removeAllToolHeaders() {
        recognizerList.removeAll()
        toolHeaderViews.removeAll()
    }
    
    func insertToolHeaderFromTemplate(_ toolItemTemplate: DUXToolbarPanelItemTemplate, at: Int) {
        let toolIcon = self.constructToolIcon(image: toolItemTemplate.barIcon, title: toolItemTemplate.barName)
        toolHeaderViews.insert(toolIcon, at: at)
        recognizerList.insert(ToolRecognizer(toolIconView: toolIcon, self), at: at)
    }
    
    func insertToolHeaderFromWidget(_ widget: DUXBetaBaseWidget, at: Int) {
        if let x = widget as? DUXToolbarPanelSupportProtocol {
            let toolIcon = self.constructIconFrom(widget: x)
            toolHeaderViews.insert(toolIcon, at: at)
            recognizerList.insert(ToolRecognizer(toolIconView: toolIcon, self), at: at)
        }
    }
    
    /**
     * The updateUI method is the standard mechanism for redrawing the UI when something in the panel changes.
    */
    @objc public override func updateUI() {

        self.layoutInternals()
        
        var maxWidth : CGFloat = 0.0
        var maxHeight : CGFloat = 0.0
                
        if !initialToolbarUIDone {
            // Part 1. Create all the tooblar items on initial setup. This will use either
            // the PanelItemTemplates or the actual widgets. This means an array should
            // be used for initial setup or we won't guess the display size right for widgets
            if usingTemplates {
                for toolItemTemplate in panelItemList {
                    insertToolHeaderFromTemplate(toolItemTemplate, at: toolHeaderViews.count)
                }
            } else {
                    for aWidget in widgetList {
                        insertToolHeaderFromWidget(aWidget, at: toolHeaderViews.count)
                }
            }
            initialToolbarUIDone = true
        }
        
        if !usingTemplates {
            // Only do this if using real widgets for the top. Otherwise we depend on the default panel size.
            // This will need to get adjusted later
            for aWidget in widgetList {
                // Don't check for isHidden on the widget view. We assume if you are
                // putting a widget in here you should be able to see it.
                let sizeHint = aWidget.widgetSizeHint
                if maxWidth < sizeHint.minimumWidth { maxWidth = sizeHint.minimumWidth }
                if maxHeight < sizeHint.minimumHeight { maxHeight = sizeHint.minimumHeight }
            }
        }
        
        // Part 2, layout the created toolbar items now
        for subView in scrollView.subviews {
            // This works only because subviews returns a copy of the actual subview list
            // on iOS, therefore it isn't mutating the actual subviews list.
            subView.removeFromSuperview()
        }
        
        for (index, iconView) in toolHeaderViews.enumerated() {
            scrollView.addSubview(iconView)
            if self.toolbarEdge == .top {
                iconView.heightAnchor.constraint(equalTo:scrollView.heightAnchor).isActive = true
                iconView.widthAnchor.constraint(equalTo:iconView.heightAnchor, multiplier:1.0).isActive = true
            } else {
                iconView.widthAnchor.constraint(equalTo:scrollView.widthAnchor).isActive = true
                iconView.heightAnchor.constraint(equalTo:iconView.widthAnchor, multiplier:1.0).isActive = true
            }
            self.drawHilighting(selected: (currentSelectedIndex == index), at: index)
        }
        
        switch self.toolbarEdge {
        case .top:
            let contentSize = CGSize(width:self.addHorizontalToolConstraints(), height:self.toolbarDimension)
            self.scrollView.contentSize = contentSize
            
            panelSize.height = maxHeight + toolbarDimension + self.titlebarHeight
            panelSize.height = max(panelSize.height, kMinPanelHeight)
            panelSize.width = max(maxWidth, kMinPanelWidth)
        break
            
        case .left, .right:
            let contentSize = CGSize(width:self.toolbarDimension, height:self.addVerticalToolConstraints())
            self.scrollView.contentSize = contentSize
            
            panelSize.width = max(maxWidth + toolbarDimension, kMinPanelWidth)
            panelSize.height = max(maxHeight + self.titlebarHeight, kMinPanelHeight)
        break
        default:
            assertionFailure("This class does not support this bar variant /(self.variant)")
        }

        self.view.heightAnchor.constraint(equalToConstant: panelSize.height).isActive = true
        self.view.widthAnchor.constraint(equalTo: self.view.heightAnchor,  multiplier: panelSize.width/panelSize.height, constant: 0.0).isActive = true

        self.view.layoutIfNeeded()
        
    }

    //MARK: - Toolbar icon construction
    func constructToolIcon(image: UIImage?, title: String?) -> UIView {
        let toolIconView = UIView()
        toolIconView.translatesAutoresizingMaskIntoConstraints = false
        toolIconView.backgroundColor = .duxbeta_clear()

        // 3 cases. image, title, image + title
        if let image = image, let title = title {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.font = toolbarIconFont
            label.textColor = .duxbeta_white()
            label.textAlignment = .center

            toolIconView.addSubview(label)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.sizeToFit()
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            toolIconView.addSubview(imageView)
            
            self.removeConstraintsOn(view:imageView)
            imageView.heightAnchor.constraint(equalTo:toolIconView.heightAnchor, multiplier: 0.70 ).isActive = true
            imageView.widthAnchor.constraint(equalTo:toolIconView.widthAnchor, multiplier: 0.70 ).isActive = true
            imageView.centerXAnchor.constraint(equalTo: toolIconView.centerXAnchor).isActive = true
            
            label.centerXAnchor.constraint(equalTo: toolIconView.centerXAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: toolIconView.bottomAnchor, constant:-4.0).isActive = true

        } else if let image = image {
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            toolIconView.addSubview(imageView)
            
            self.removeConstraintsOn(view:imageView)
            imageView.heightAnchor.constraint(equalTo:toolIconView.heightAnchor, multiplier: 0.70 ).isActive = true
            imageView.widthAnchor.constraint(equalTo:toolIconView.widthAnchor, multiplier: 0.70 ).isActive = true

            imageView.centerXAnchor.constraint(equalTo: toolIconView.centerXAnchor).isActive = true
        } else if let title = title {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = title
            label.font = toolbarIconFont
            label.textColor = .duxbeta_white()
            label.textAlignment = .center
               
            toolIconView.addSubview(label)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.sizeToFit()
            label.centerXAnchor.constraint(equalTo: toolIconView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: toolIconView.centerYAnchor, constant: 4.0).isActive = true
            label.widthAnchor.constraint(equalToConstant: self.toolbarDimension).isActive = true

        }
        return toolIconView
    }
    
    func constructIconFrom<T: AnyObject>(widget: T) -> UIView where T: DUXToolbarPanelSupportProtocol {
        let image = widget.toolbarItemIcon?()
        let title = widget.toolbarItemTitle?()
        
        return constructToolIcon(image: image, title: title)
    }

    func addHorizontalToolConstraints() -> CGFloat {
        var lastItem: UIView?
        var totalWidth: CGFloat = 0.0
        
        for toolItem in toolHeaderViews {
            toolItem.topAnchor.constraint(equalTo:scrollView.topAnchor).isActive = true
            if let localLastItem = lastItem {
                toolItem.leadingAnchor.constraint(equalTo:localLastItem.trailingAnchor).isActive = true
                lastItem = toolItem
                totalWidth += toolItem.bounds.size.width
            } else {
                toolItem.leadingAnchor.constraint(equalTo:scrollView.leadingAnchor).isActive = true
                lastItem = toolItem
                totalWidth += toolItem.bounds.size.width
            }
        }
        
        return totalWidth
    }
    
    func addVerticalToolConstraints() -> CGFloat {
        var lastItem: UIView?
        var totalHeight: CGFloat = 0.0
        
        for toolItem in toolHeaderViews {
            toolItem.leadingAnchor.constraint(equalTo:scrollView.leadingAnchor).isActive = true
            
            if let localLastItem = lastItem {
                toolItem.topAnchor.constraint(equalTo:localLastItem.bottomAnchor).isActive = true
                lastItem = toolItem
                totalHeight += toolItem.bounds.size.height
            } else {
                toolItem.topAnchor.constraint(equalTo:scrollView.topAnchor).isActive = true
                lastItem = toolItem
                totalHeight += toolItem.bounds.size.height
            }
        }
        
        return totalHeight
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
        for (index, element) in widgetList.enumerated() {
            if element == forWidget {
                return index
            }
        }
        return NSNotFound
    }
    
    func drawHilighting(selected: Bool, at: Int) {
        if selected {
            toolHeaderViews[at].backgroundColor = self.panelSelectionColor
        } else {
            toolHeaderViews[at].backgroundColor = .duxbeta_clear()
        }
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
        
        let usingTemplates = (self.panelItemList.count > 0)
        
        // Remove the currently shown tool from the toolView.
        let subViewArray: [UIView] = self.toolView.subviews
        for aView in subViewArray {
            aView.removeFromSuperview()
        }
        
        // Now set the background color for the selected tool in the toolbar
        for headerIndex in 0..<toolHeaderViews.count {
            drawHilighting(selected: (index == headerIndex), at: headerIndex)
        }
        
        if usingTemplates {
            let template = self.panelItemList[index]
            if let widget = template.widget {
                // All good, don't need to create it
                self.insertIntoToolView(widget:widget)

            } else {
                if let klassname = template.klassname {
                    let aClass = NSClassFromString(klassname) as! DUXBetaBaseWidget.Type
                    let widget = aClass.init()
                        template.widget = widget
                        self.insertIntoToolView(widget:widget)
                }
            }
 
            // This will clean up the old widget if we don't want to keep it alive. This MUST
            // be done before we reset the currentSelectedIndex or we need to keep a copy of the index around
            if currentSelectedIndex != NSNotFound {
                let oldTemplate = self.panelItemList[currentSelectedIndex]
                if oldTemplate.keepWidgetAlive == false {
                    oldTemplate.widget = nil
                }
            }

        } else {
            if let _ = widgetList[index].view {
                self.insertIntoToolView(widget:widgetList[index])
            }
        }
        
        currentSelectedIndex = index
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
        if let _ = widget as? DUXPanelWidget {
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

