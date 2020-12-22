//
//  DUXBetaBarPanelWidget.swift
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

fileprivate let defaultInterWidgetSpace = CGFloat(12.0)

/******************************************************************************
 * Some rules of the layout here:
 * Widgets are added into the bar moving from left to right. So if a new widget is added (not inserted) all
 * widgets will shift left (towards leading edge).
 * For vertical bars, the leftBar is hanging at the top, and the rightBar is at the bottom of the vertical area.
 * Bar panels do not have title bars or close bars.
 * Bar panels to support margins on all edges.
******************************************************************************/

/**
 * The LayoutInfoTuple contains the widget, the widget visibility, the height and width constraints on the widget
 * to allow dynamic adjustments.
 * If isVisible is false, the height and width NSLayoutConstraint will be nil. This lets us
 * track and deactivate constraints before updating them in UpdateUI, so we don't get constraint build up and conflicts.
 *
 * - Parameters:
 *      - widget: The widget this tuple is about
 *      - isVisible: Is the widget currently visible
 *      - heightConstraint: The current active constraint on the heightAnchor for this widget. Optional
 *      - widthConstraint: The current active constraint on the widthAnchor for this widget. Optional
 */
typealias LayoutInfoTuple = (widget: DUXBetaBaseWidget, isVisible: Bool, heightConstraint: NSLayoutConstraint?, widthConstraint: NSLayoutConstraint?)

/**
 * DUXBetaBarPanelWidget implements the Bar Panel which descends from DUXBetaPanelWidget. The bar panel is a single strip of widgets
 * either horizontal or vertical which has a left/right side, or a top/bottom side (but still using the left/right nomenclature.)
 * Widgets can be added or removed or even made invisible while the widget is on screen and the visible widgets will adjust
 * positions in the visible bar.
 *
 * Margins can be added either one at a time by setting the individual margins or all at once by calling the
 * setBarMargins method.
 */
@objcMembers open class DUXBetaBarPanelWidget : DUXBetaPanelWidget {
    /// The topMargin for insetting the panel contents
    public var topMargin: CGFloat = 0.0 {
        didSet {
            updatetMarginConstraints(top: true)
        }
    }
    /// The bottomMargin for insetting the panel contents
    public var bottomMargin: CGFloat = 0.0 {
        didSet {
            updatetMarginConstraints(bottom: true)
        }
    }
    /// The leftMargin for insetting the panel contents
    public var leftMargin: CGFloat = 0.0 {
        didSet {
            updatetMarginConstraints(left: true)
        }
    }
    /// The rightMargin for insetting the panel contents
    public var rightMargin: CGFloat = 0.0 {
        didSet {
            updatetMarginConstraints(right: true)
        }
    }

    /// The standard widgetSizeHint indicating the minimum size for this widget and preferred aspect ratio
   public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (panelSize.width / panelSize.height), minimumWidth: panelSize.width, minimumHeight: panelSize.height)}
        set {}
    }
    
    // Instance variables visible inside the module
    let rightBar = UIStackView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))
    let leftBar = UIStackView(frame:CGRect(x: 0, y: 0, width: 20, height: 20))

    // Private instance variables
    enum BarIndex: Int {
        case leftBarIndex = 0
        case rightBarIndex = 1
    }
    
    fileprivate var orientation : DUXBetaPanelVariant
    fileprivate var panelSize = CGSize(width: 10, height: 10)
    fileprivate var interWidgetSpace: CGFloat = defaultInterWidgetSpace
    
    fileprivate let marginsLayoutGuide = UILayoutGuide()
    fileprivate var topGuideConstraint : NSLayoutConstraint?
    fileprivate var leftGuideConstraint : NSLayoutConstraint?
    fileprivate var bottomGuideConstraint : NSLayoutConstraint?
    fileprivate var rightGuideConstraint : NSLayoutConstraint?
    
    // This is an array of arrays. Indexing is leftBarIndex and rightBarIndex. Each array inside contains
    // tuples of all the widgets in the bar, a visibility shortcut (possibly not needed), and height and width constraints.
    fileprivate var allWidgetVisibilities : [[LayoutInfoTuple]] = [ [LayoutInfoTuple](), [LayoutInfoTuple]() ]
    fileprivate var panelSizeInitalLayoutDone = false
    fileprivate var suspendUpdates = false

    // We only have one modifiable constraint for horizontal or vertical. Se we can be flexible on
    // what these variables hold.
    fileprivate var rightBarConstraint: NSLayoutConstraint?
    fileprivate var leftBarConstraint: NSLayoutConstraint?

    // MARK: - Public Instance Methods

    /**
     * The default init method for the class. Sets the orientation to horiztonal.
     */
    override public init() {
        orientation = .horizontal
        super.init()
    }
    
    /**
     * The default init method for the class when loading from a Storyboard or Xib. Sets the orientation to horiztonal.
     */
    required public init?(coder: NSCoder) {
        orientation = .horizontal
        super.init(coder: coder)
    }

    /**
     * The init method for creating an instance of a bar panel with a given orientation.
     *
     * - Parameter variant: The variant specifying horizontal or vertical orientation.
     */
    init(variant: DUXBetaPanelVariant) {
        orientation = variant
        super.init()
    }

    deinit {
        // Clean up the KVO on the installed widgets
        for widgetVisArray in allWidgetVisibilities {
            for aWidgetTuple in widgetVisArray {
                if let widgetView = aWidgetTuple.widget.view {
                    widgetView.removeObserver(self, forKeyPath: "hidden")
                }
            }
        }
    }

    /**
     * Override of the standard viewdDidLoad. Sets the parent view for autolayout and if the widget has already been
     * configured, calls setupUI.
     */
    override open func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        if isConfigured {
            setupUI()
        }
    }
    
    //MARK: - Configuration
    /**
     * Override of configure method. Takes the configuration object and extracts the specific part needed for this
     * widget (orientation) and calls the parent configuration for the remainder of the processing.
     * If the configuration has been conmpleted, calls setupUI.
     *
     * - Returns: This object instance for call chaining.
     */
    override open func configure(_ configuration:DUXBetaPanelWidgetConfiguration) -> DUXBetaPanelWidget {
        orientation = configuration.widgetVariant
        let _ = super.configure(configuration)
        if isConfigured {
            setupUI()
        }
        return self
    }

    //MARK: - Margin maintainance
    /**
     * Method setupBarMargins takes the four margins (top, left, bottom, right) as a UIEdgeInserts and applies them to the bar panel.
     *
     * - Parameter marginInsets: The UIEdgeInsets structure defining the margins for top, left, bottom, and right.
     */
    open func setBarMargins(marginInsets: UIEdgeInsets) {
        topMargin = marginInsets.top
        leftMargin = marginInsets.left
        bottomMargin = marginInsets.bottom
        rightMargin = marginInsets.right
    }
    
    //MARK: - Bar content control
    
    /**
     * The method widgetCount returns the number of widgets in the right/bottom bar side only.
     *
     * - Returns: Int/NSInteger number of widgets in the right or bottom side of the widget.
     */
    open override func widgetCount() -> Int {
        return rightWidgetCount()
    }
    
    /**
     * The method rightWidgetCount returns the number of widgets in the right/bottom bar side.
     *
     * - Returns: Interer/NSInteger number of widgets in the right or bottom side of the widget.
     */
    open func rightWidgetCount() -> Int {
        return allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].count
    }
    
    /**
     * The method leftWidgetCount returns the number of widgets in the left/top bar side.
     *
     * - Returns: Int/NSInteger number of widgets in the left or top side of the widget.
     */
    open func leftWidgetCount() -> Int {
        return allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].count
    }

    /**
     * The addWidgetArray method defaults to adding widgets to the right/bottom bar.
     *
     * - Parameter displayWidgets: unnamed array of widgets subclassed from from DXBaseWidget.
     */
    open override func addWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        addRightWidgetArray(displayWidgets)
    }
    
    /**
     * The addRightWidgetArray method adds the widgets from the passed array to the right/bottom bar.
     *
     * - Parameter displayWidgets: unnamed array of widgets subclassed from from DXBaseWidget.
     */
    open func addRightWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        suspendUpdates = true
        for aWidget in displayWidgets {
            // Build our tracking tuple for each widget so we can associate constraint.
            let isVisible = !(aWidget.view?.isHidden ?? true)   // The true means isHidden since there is no view
            let workTuple : LayoutInfoTuple = (aWidget, isVisible, nil, nil)
            allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].append(workTuple)
            
            // Add an abserver to the hidden property so we can handle automatic adjustment when a widget disappears or reappears
            aWidget.view?.addObserver(self, forKeyPath: "hidden", options: .new, context: nil)
            addChild(aWidget)
            // And always have all widgets in the bar, even if invisible.
            rightBar.addArrangedSubview(aWidget.view)

            aWidget.view.layoutIfNeeded()
        }
        suspendUpdates = false
        updateUI()
    }
    
    /**
     * The addLeftWidgetArray method adds the widgets from the passed array to the left/top bar.
     *
     * - Parameter displayWidgets: unnamed array of widgets subclassed from from DXBaseWidget.
     */
    open func addLeftWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        for aWidget in displayWidgets {
            // Build our tracking tuple for each widget so we can associate constraint.
            let isVisible = !(aWidget.view?.isHidden ?? true)   // The true means isHidden since there is no view
            let workTuple : LayoutInfoTuple = (aWidget, isVisible, nil, nil)
            allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].append(workTuple)
            
            // Add an observer to the hidden property so we can handle automatic adjustment when a widget disappears or reappears
            aWidget.view?.addObserver(self, forKeyPath: "hidden", options: .new, context: nil)
            addChild(aWidget)
            // And always have all widgets in the bar, even if invisible.
            leftBar.addArrangedSubview(aWidget.view)
            aWidget.view.layoutIfNeeded()
        }
        updateUI()
    }

    /**
     * The insertRightWidget method inserts the given widget into the right/bottom bar at the given index.
     * Indexing is from leading to trailing side.
     *
     * - Parameters:
     *      -  widget: The widget subclassed from from DXBaseWidget to insert.
     *      - atIndex: The index at which to insert the widget in the bar array.
     */
    open func insertRightWidget(_ widget: DUXBetaBaseWidget, atIndex: Int) {
        let isVisible = !(widget.view?.isHidden ?? true)   // The true means isHidden since there is no view
        let workTuple : LayoutInfoTuple = (widget, isVisible, nil, nil)
        allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].insert(workTuple, at: atIndex)
        // Add an observer to the hidden property so we can handle automatic adjustment when a widget disappears or reappears
        widget.view?.addObserver(self, forKeyPath: "hidden", options: .new, context: nil)
        addChild(widget)
        rightBar.insertArrangedSubview(widget.view, at: atIndex)
        widget.view.layoutIfNeeded()
        updateUI()
    }
    
    /**
     * The insertLeftWidget method inserts the given widget into the left/top bar at the given index.
     * Indexing is from top to bottom.
     *
     * - Parameters:
     *      - widget: The widget subclassed from from DXBaseWidget to insert.
     *      - atIndex: The index at which to insert the widget in the bar array.
     */
    open func insertLeftWidget(_ widget: DUXBetaBaseWidget, atIndex: Int) {
        let isVisible = !(widget.view?.isHidden ?? true)   // The true means isHidden since there is no view
        let workTuple : LayoutInfoTuple = (widget, isVisible, nil, nil)
        allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].insert(workTuple, at: atIndex)
        // Add an observer to the hidden property so we can handle automatic adjustment when a widget disappears or reappears
        widget.view?.addObserver(self, forKeyPath: "hidden", options: .new, context: nil)
        addChild(widget)
        leftBar.insertArrangedSubview(widget.view, at: atIndex)
        widget.view.layoutIfNeeded()
        updateUI()
    }

    /**
     * The insert method inserts the given widget into the right/bottom bar at the given index.
     * Indexing is from leading to trailing side.
     *
     * - Parameters:
     *      - widget: The widget subclassed from from DXBaseWidget to insert.
     *      - atIndex: The index at which to insert the widget in the bar array.
     */
    open override func insert(widget: DUXBetaBaseWidget, atIndex: Int) {
        insertRightWidget(widget, atIndex: atIndex)
    }
    
    /**
     * The removeRightWidget method removes the widget at the given index from the right/bottom bar.
     * Indexing is from leading to trailing side.
     *
     * - Parameters:
     *      - atIndex: The index at which to remove the widget in the bar array.
     */
    open func removeRightWidget(atIndex: Int) {
        let workTuple = allWidgetVisibilities[BarIndex.rightBarIndex.rawValue][atIndex]
        rightBar.removeArrangedSubview(workTuple.widget.view)
        workTuple.widget.view.removeFromSuperview()

        allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].remove(at: atIndex)
        updateUI()
    }
    
    /**
     * The removeLeftWidget method removes the widget at the given index from the left/top bar.
     * Indexing is from top to bottom.
     *
     * - Parameters:
     *      - atIndex: The index at which to remove the widget in the bar array.
     */
    open func removeLeftWidget(atIndex: Int) {
        let workTuple = allWidgetVisibilities[BarIndex.leftBarIndex.rawValue][atIndex]
        leftBar.removeArrangedSubview(workTuple.widget.view)
        workTuple.widget.view.removeFromSuperview()

        allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].remove(at: atIndex)
        updateUI()
    }
    
    /* The left vs right vs all methods below are split up strictly to prevent calling
     * updateUI twice if we wrote removeAllWidgets as a composition of the other
     * two remove widgets calls.
     */
    
    /**
     * The method removeLeftWidgets removes all the widgets from the left/top bar.
     */
    open func removeLeftWidgets() {
        let leftSubviews = leftBar.arrangedSubviews
        for theView in leftSubviews {
            leftBar.removeArrangedSubview(theView)
            theView.removeFromSuperview()
        }
        allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].removeAll()
        updateUI()
    }
    
    /**
     * The method removeRightWidgets removes all the widgets from the right/bottom bar.
     */
    open func removeRightWidgets() {
        let rightSubviews = rightBar.arrangedSubviews
        for theView in rightSubviews {
            rightBar.removeArrangedSubview(theView)
            theView.removeFromSuperview()
        }
        allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].removeAll()
    
        updateUI()
    }
    
    /**
     * The method removeAllWidgets removes all the widgets from the both internal bars.
     */
    open override func removeAllWidgets() {
        let leftSubviews = leftBar.arrangedSubviews
        for theView in leftSubviews {
            leftBar.removeArrangedSubview(theView)
            theView.removeFromSuperview()
        }
        allWidgetVisibilities[BarIndex.leftBarIndex.rawValue].removeAll()

        let rightSubviews = rightBar.arrangedSubviews
        for theView in rightSubviews {
            rightBar.removeArrangedSubview(theView)
            theView.removeFromSuperview()
        }
        allWidgetVisibilities[BarIndex.rightBarIndex.rawValue].removeAll()
        
        updateUI()
}
    
    //MARK: - KVO
    /**
     The observeValue method is used to implement KVO to trigger UI updates.
     */
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        updateUI()
    }

    
    //MARK: - UI Setup and Update
    
    open func setupUI() {
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        leftBar.backgroundColor = .uxsdk_black()
        leftBar.alignment = .center
        leftBar.distribution = .equalSpacing

        rightBar.translatesAutoresizingMaskIntoConstraints = false
        rightBar.backgroundColor = .uxsdk_black()
        rightBar.alignment = .center
        rightBar.distribution = .equalSpacing
        
        if orientation == .horizontal {
            rightBar.axis = .horizontal
            leftBar.axis = .horizontal
        } else {
            rightBar.axis = .vertical
            leftBar.axis = .vertical
        }
        view.addSubview(leftBar)
        view.addSubview(rightBar)

        // Set up the UIGuides for setting the margins
        view.addLayoutGuide(marginsLayoutGuide)
        updatetMarginConstraints(top: true, left: true, bottom: true, right: true)
        
        if orientation == .horizontal {
            // This setup is for horizontal only
            leftBar.topAnchor.constraint(equalTo: marginsLayoutGuide.topAnchor, constant: 0.0).isActive = true
            leftBar.leftAnchor.constraint(equalTo: marginsLayoutGuide.leftAnchor, constant: 0.0).isActive = true
            leftBar.heightAnchor.constraint(equalTo: marginsLayoutGuide.heightAnchor).isActive = true

            // Set up the right bar to be the full size of the view currently. When a left bar is added, both
            // with be constrained with a spacing constraint between them so they can't overlap.
            // The width anchor is dynamically calculated and proportional to the final height. It is set later
            // in this method.
            rightBar.topAnchor.constraint(equalTo: marginsLayoutGuide.topAnchor, constant: 0.0).isActive = true
            rightBar.rightAnchor.constraint(equalTo: marginsLayoutGuide.rightAnchor, constant: 0.0).isActive = true
            rightBar.heightAnchor.constraint(equalTo: marginsLayoutGuide.heightAnchor).isActive = true
        } else {
            // This is the case of orientation == .vertical. The right bar is placed at the visual top, and the left bar
            // is placed at the visual bottom

            leftBar.topAnchor.constraint(equalTo: marginsLayoutGuide.topAnchor, constant: 0.0).isActive = true
            leftBar.leftAnchor.constraint(equalTo: marginsLayoutGuide.leftAnchor, constant: 0.0).isActive = true
            leftBar.widthAnchor.constraint(equalTo: marginsLayoutGuide.widthAnchor).isActive = true

            // Set up the right bar to be the full size of the view currently. When a left bar is added, both
            // with be constrained with a spacing constraint between them so they can't overlap.
            // The width anchor is dynamically calculated and proportional to the final height. It is set later
            // in this method.
            rightBar.bottomAnchor.constraint(equalTo: marginsLayoutGuide.bottomAnchor, constant: 0.0).isActive = true
            rightBar.leftAnchor.constraint(equalTo: marginsLayoutGuide.leftAnchor, constant: 0.0).isActive = true
            rightBar.widthAnchor.constraint(equalTo: marginsLayoutGuide.widthAnchor).isActive = true
        }
    }

    /**
     * Override of the updateUI method for the BarPanel. It adjusts the sizes of the internal UIStackViews based on
     * the sizes of the items in the stack views and the margins in the widget.
     */
    open override func updateUI() {
        if suspendUpdates {
            // Updates may be suspended duing an add Widgets operation until all widgets are added.
            return
        }

        // The visibility is used to compute our UIStackView size based on the shown widgets
        // This maintains the list of visibility so we can compute the correct size
        func findWidgetsMaxMin(_ widgetVisibility: inout [LayoutInfoTuple]) -> (width: CGFloat, height: CGFloat) {
            var maxWidth : CGFloat = 1.0
            var maxHeight : CGFloat = 1.0
            
            for (index, widgetInfo) in widgetVisibility.enumerated() {
                var updatedWidgetInfo = widgetInfo
                let currentIsHidden = updatedWidgetInfo.widget.view?.isHidden ?? true
                updatedWidgetInfo.isVisible = !currentIsHidden
                widgetVisibility[index] = updatedWidgetInfo

                let aWidget = widgetInfo.widget
                if updatedWidgetInfo.isVisible {
                    let sizeHint = aWidget.widgetSizeHint
                    if maxWidth < sizeHint.minimumWidth { maxWidth = sizeHint.minimumWidth }
                    if maxHeight < sizeHint.minimumHeight { maxHeight = sizeHint.minimumHeight }
                }
            }
            return (maxWidth, maxHeight)
        }
        
        for barIdentider in [BarIndex.rightBarIndex, BarIndex.leftBarIndex] {
            
            _ = findWidgetsMaxMin(&allWidgetVisibilities[barIdentider.rawValue])

            var itemCount: CGFloat = 1

            // Force a layout here unfortunately. If we don't do this, on first updateUI the widgets aren't
            // correctly sized. (This may not be working fully yet.)
            var workBar = rightBar
            switch barIdentider {
            case .rightBarIndex:    rightBar.layoutIfNeeded()
            case .leftBarIndex:     leftBar.layoutIfNeeded(); workBar = leftBar
            }
            
            var barPanelSize = CGSize.zero
            (barPanelSize, itemCount) = findBarDimensions(workBar, orientation: orientation)
            if (itemCount == 0) {
                // Adjust itemCount to prevent negative interGap space computation if there are
                // 0 or 1 itmes.
                itemCount = 1
            }
            // Making the constraint false removes it from the constraints list.
            var workConstraint: NSLayoutConstraint?
            switch barIdentider {
            case .rightBarIndex:    rightBarConstraint?.isActive = false
            case .leftBarIndex:     leftBarConstraint?.isActive = false;   workBar = leftBar
            }
            
            workConstraint = spacingConstraint(forOrientation: orientation,
                                               andWorkBar: workBar,
                                               withSize: barPanelSize,
                                               andConstant: ((itemCount-1) * interWidgetSpace))
            workConstraint?.isActive = true
            
            switch barIdentider {
            case .rightBarIndex:    rightBarConstraint = workConstraint
            case .leftBarIndex:     leftBarConstraint = workConstraint
            }
        }
        rightBar.layoutIfNeeded()
        leftBar.layoutIfNeeded()
        view.layoutIfNeeded()
    }
    
    /**
     * The spacingConstraint method creates the width and height ratio constraint
     * for the bar panel.
     *
     * - Parameters:
     *      - orientation: The orientation of the widget.
     *      - workBar: The stackview for which the constraint is created.
     *      - size: The actual size of the panel.
     *      - constant: The constant that needs to be factored in.
     * - Returns: An NSLayoutConstraint for the widthAnchor or heightAnchor with
     *            the computed ratio and given constant.
     */
    open func spacingConstraint(forOrientation orientation: DUXBetaPanelVariant,
                                  andWorkBar workBar: UIView,
                                  withSize size: CGSize,
                                  andConstant constant: CGFloat) -> NSLayoutConstraint {
        if orientation == .horizontal {
            return workBar.widthAnchor.constraint(equalTo: workBar.heightAnchor, multiplier: size.width/size.height, constant: constant)
        } else {
            // Orientation is .vertical. Checks in other places guarantee this
            return workBar.heightAnchor.constraint(equalTo: workBar.widthAnchor, multiplier: size.height/size.width, constant: constant)
        }
    }
    
    //MARK: - internal methods
    func findBarDimensions(_ bar: UIStackView, orientation: DUXBetaPanelVariant) -> (CGSize, CGFloat) {
        var outSize: CGSize = CGSize(width: 0.0, height: 0.0)
        var totalHeight: CGFloat = 0.0
        var totalWidth: CGFloat = 0.0
        var maxWidth: CGFloat = 0.0
        var maxHeight: CGFloat = 0.0
        var visibleItems: CGFloat = 0.0
        
        for aView in bar.arrangedSubviews {
            if !aView.isHidden {
                let viewSize = aView.bounds.size
                if maxWidth < viewSize.width { maxWidth = viewSize.width }
                if maxHeight < viewSize.height { maxHeight = viewSize.height }
                totalWidth += viewSize.width
                totalHeight += viewSize.height
                visibleItems += 1
            }
        }
        if (orientation == .horizontal) {
            outSize.height = maxHeight == 0 ? 1.0 : maxHeight      // Never return a height of 0 or we get a divide by 0 error for the aspect ration calculation
            outSize.width = totalWidth //+ ((visibleItems-1) * interWidgetSpace)
        } else {
            outSize.height = totalHeight //+ ((visibleItems-1) * interWidgetSpace)
            outSize.width = maxWidth  == 0 ? 1.0 : maxWidth       // Never return a width of 0 or we get a divide by 0 error for the aspect ration calculation
        }

        return (outSize, visibleItems)
    }

    func updatetMarginConstraints(top: Bool = false, left: Bool = false, bottom: Bool = false, right: Bool = false) {
        if top {
            // Set the top margin
            if let oldConstraint = topGuideConstraint {
                oldConstraint.isActive = false
            }
            if let owningView = marginsLayoutGuide.owningView {
                topGuideConstraint = marginsLayoutGuide.topAnchor.constraint(equalTo:owningView.topAnchor, constant:topMargin)
                topGuideConstraint?.isActive = true;
            }
        }
        
        if left {
            // Set the left margin
            if let oldConstraint = leftGuideConstraint {
                oldConstraint.isActive = false
            }
            if let owningView = marginsLayoutGuide.owningView {
                leftGuideConstraint = marginsLayoutGuide.leftAnchor.constraint(equalTo:owningView.leftAnchor, constant:leftMargin)
                leftGuideConstraint?.isActive = true;
            }
        }
        
        if bottom {
            // Set the bottom margin
            if let oldConstraint = bottomGuideConstraint {
                oldConstraint.isActive = false
            }
            if let owningView = marginsLayoutGuide.owningView {
                bottomGuideConstraint = marginsLayoutGuide.bottomAnchor.constraint(equalTo:owningView.bottomAnchor, constant:-bottomMargin)
                bottomGuideConstraint?.isActive = true;
            }
        }

        if right {
            // Set the right margin
            if let oldConstraint = rightGuideConstraint {
                oldConstraint.isActive = false
            }
            if let owningView = marginsLayoutGuide.owningView {
                rightGuideConstraint = marginsLayoutGuide.rightAnchor.constraint(equalTo:owningView.rightAnchor, constant:-rightMargin)
                rightGuideConstraint?.isActive = true;
            }
        }
    }

    // Debugging method to be inserted as needed to test that no heights have gone to 0
    func find0Height(_ view:UIView) {
        view.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                if (constraint.constant == 0) || (constraint.multiplier == 0.0) {
                    print("Bad things")
                }
            }
        }
    }
}
