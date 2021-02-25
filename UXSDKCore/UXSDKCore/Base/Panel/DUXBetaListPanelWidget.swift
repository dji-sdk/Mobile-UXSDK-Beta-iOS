//
//  DUXBetaListPanelWidget.swift
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


// The List Panel architecure deviates slightly from normal widget architecture. A normal
// UINavigationController architecture has a single navigation controller which is referenced
// in each subvue. In order to do that, additional extensive plumbing is required as well as
// invasive ownership of child views (to set the navigationController property.)
// This version implements the child view controller stack (currently) by passing the
// new list child controller up the list panel stack to the top element. That element becomes
// the actual rootViewController.
//
// The new sub-lists are added to the right of the current top UIViewController. When the push
// happens, they animate left, and then the parent UIViewController is hidden.
//
// How does a ListPanelWidget know if it is the rootViewController? That status is established
// when the view is added to an existing viewController. It is detected with the two calls:
//     @objc public override func didMove(toParent parent: UIViewController?) {
//     @objc public override func willMove(toParent parent: UIViewController?) {

import Foundation
import UIKit

/// The default minimum widget width (only used if no autolayout constraints added)
let kDesignWidthHint: CGFloat = 400.0
/// The default minimum widget height (only used if no autolayout constraints added)
let kDesignHeighthHint: CGFloat = 300.0

/**
 * DUXBetaListPanelWidget implements the List Pane which descends from the DUXBetaListPanelWidget. It implements a list using
 * UITableView. The list can consist of widgets or strings for making a selection. Widgets are placed into UITableViewCells
 * for display.
 * Individual widgets can adopt the DUXBetaListPanelSupportProtocol to present sublists via the normal detail view mechanism.
 *
 * List panels provides a title bar area which can contain a close box, title, and back button. These are configured using
 * the standard configuration object.
 */
@objcMembers open class DUXBetaListPanelWidget : DUXBetaPanelWidget, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    //MARK: - Public Variables
    /// Used by sublcasses of DUXBetaListPanelWidget and to know if the model has already been created and setup.
    var isWidgetModelSetup = false
    /// The model used by the panel for holding display widgets. May be replaced by subclasses
    var model: DUXBetaListPanelWidgetBaseModel = DUXBetaListPanelWidgetBaseModel()
    /// The standard widgetSizeHint indicating the minimum size for this widget and prefered aspect ratio. Always returns the same size for DUXBetaListPanelWidget. Atual size is controlled by constrains on class added to parent view.
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
        get { return DUXBetaWidgetSizeHint(preferredAspectRatio: kDesignWidthHint/kDesignHeighthHint, minimumWidth: kDesignWidthHint, minimumHeight: kDesignHeighthHint)}
        set {
        }
    }

    //MARK: - Private Variables
    fileprivate var listType: DUXBetaListType = .none
    
    // Tabel Support
    fileprivate var tableView = UITableView()
    fileprivate var tableViewController = UITableViewController()
    fileprivate var widgetToCell: [DUXBetaBaseWidget : UITableViewCell] = [DUXBetaBaseWidget : UITableViewCell]()
    /// variable to hold the selection update callback block if it exists
    fileprivate var selectionUpdater:((Int)->Void)? = nil
    

    // Used by the root list widget only
    fileprivate var viewControllerStack: [(DUXBetaListPanelWidget, NSLayoutConstraint?)]?   // This only exists for the base rootViewController. Widget and left edge constraint
    
    // Special setup value for .selectOne and .selectOneAndReturn lists to show an existing selectiin
    fileprivate var hasInitialSelection = false
    fileprivate var initialSelection = 0
    
    // Internal flags
    fileprivate var isRootViewController = false
    fileprivate var internalLayoutDone = false
    fileprivate var setupUIDone = false     //This may need to either move up in the panels, or become a pattern for all widgets
    
    // SmartModel support
    fileprivate var smartModelCarrier: DUXBetaSmartListModel?
    fileprivate var hasSmartModel = false
    fileprivate var initPhaseDone = false
    
    //MARK: - Public Methods

    /**
     * The default init method for the class when loading from a Storyboard or Xib.
     */
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableVisuals()
    }

    /**
     * The default init method for the class.
     */
    override public init() {
        super.init()
        setupTableVisuals()
    }
    
    /**
     * The init method for creating an instance of a list panel with a SmartModel to determine the list contents.
     *
     * - Parameter smartModel: The SmartModel object which will be used to add and remove widgets/options from the list.
     */
    public init(smartModel: DUXBetaSmartListModel) {
        super.init()
        setupTableVisuals()
        let _ = setupSmartModel(smartModel)
    }
    
    /**
     * The init method for creating an instance of a list panel with a variant.
     *
     * - Parameter variant: The variant defines what types of items the list accepts
     */
    public init(variant: DUXBetaPanelVariant) {
        super.init()
        setupTableVisuals()
    }
    
    deinit {
        model.cleanup()
    }
    
    /**
     * The method stupSmartModel is only valid to call from init or an override of init methods. Once initialization is complete
     * the SmartModel will be rejected.
     *
     * - Parameter smartModel: And unnamed parameter which is the actual SmartModel object which will be used in the list panel.
     *
     * - Returns: false if setup is rejected because init phase is complete, true if smart model was set.
     */
    open func setupSmartModel(_ smartModel: DUXBetaSmartListModel) -> Bool {
        if initPhaseDone {
            return false
        }
        smartModelCarrier = smartModel    // Release this as soon as assigned
        hasSmartModel = true
        initPhaseDone = true
        
        return true
    }

    /**
     * The method createStandardModel creates and returns the standard model for containing the widgets to be shown in the list.
     * This model will be used by the SmartModel if one is used.
     *
     * - returns: a new DUXBetaListPanelWidgetBaseModel.
     */
    open func createStandardModel() -> DUXBetaListPanelWidgetBaseModel {
        return DUXBetaListPanelWidgetBaseModel()
    }
    
    /**
     * The method createStringModel creates and returns the standard model for containing string to be shown in an options list.
     *
     * - returns: a new DUXBetaListPanelWidgetStringsModel.
     */
    open func createStringsModel() -> DUXBetaListPanelWidgetBaseModel {
        return DUXBetaListPanelWidgetStringsModel()
    }

    /**
     * Override of the standard viewDidLoad. This method sets the view and tableView up for autolayout. It then calls the
     * custom defaultConfigurationSetup method and hooks up the SmartModel if it exists or sets up the strings model if needed before
     * doing the seupUI if appropriate.
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableViewController.tableView = tableView
        initPhaseDone = true

        switch listType {
            case .widgets, .widgetNames:
                if let smartModel = smartModelCarrier, hasSmartModel {
                    model.set(smartModel: smartModel)
                    smartModelCarrier = nil
                }
                break
            case .selectOne, .selectOneAndReturn:
                if let _ = model as? DUXBetaListPanelWidgetStringsModel {
                    // The type was already correct somehow. Don't do anything
                } else {
                    model = createStringsModel()
                }
                break
            
        case .none:
            break
        @unknown default:
            break
        }
        
        model.setup()
        isWidgetModelSetup = true
        
        if isConfigured {
            setupUI()
        }
    }
    
    /**
     * Override of viewWillAppear to establish KVO bindings.
     */
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        bindRKVOModel(self, #selector(updateList), "model.count,model.widgetList")
    }
    
    /**
     * Override of viewDidAppear to establish setup initial selection in an options list if needed.
     */
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if hasInitialSelection {
            tableView.selectRow(at: IndexPath(row:initialSelection, section:0), animated: false, scrollPosition: .none)
        }
    }
    
    /**
     * Override of viewWillDisappear to symetrically remove KVO bindings when view disappears.
     */
    @objc public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unbindRKVOModel(self)
    }

    /**
     * The method updateList is a utility method which updates the UI and reloads the tabelView data.
     */
    open func updateList() {
        updateUI()
        tableView.reloadData()
    }
    
    /**
     * Override of willMove which is called when this widget is about to be placed into a new parent widget.
     *
     * - Parameter toParent: The new hosting UIViewController.
     */
    public override func willMove(toParent parent: UIViewController?) {
        if isTopListWidget() {
        }
    }

    /**
     * Override of method didMove which is called when this widget has been placed into a new parent widget. If this list panel
     * is at the top of its view controller stack (i.e. the root list panel) it initializes the view controller stack
     * and marks itself as the root. If it is a child list, the default value for isRootViewController is false.
     *
     * - Parameter toParent: The new hosting UIViewController.
     */
    public override func didMove(toParent parent: UIViewController?) {
        if isTopListWidget() {
            viewControllerStack = [(self, nil)]
            isRootViewController = true
            view.layer.masksToBounds = true
        }

        if isConfigured && isWidgetModelSetup {
            setupUI()
        }
    }
    
    /**
     * Method isTopListWidget walks the controller hierarchy to determine if this contoller (list panel) is the top
     * list panel in the hierarchy.
     *
     *- Returns: true if this is the root of the list panel hierarchy. false if this is a sublist.
     */
    func isTopListWidget() -> Bool {
        var currentCheckController: UIViewController? = parent
        while currentCheckController != nil {
            if currentCheckController!.isKind(of:DUXBetaListPanelWidget.self) {
                return false
            }
            currentCheckController = currentCheckController?.parent
        }
            
        return true
    }
    
    /**
     * Method topListWidget walks the view controller hierarchy and returns the root list panel widget in the current
     * list stack.
     *
     * - Returns: DUXBetaListPanelWidget at the root of the list panel hierarchy.
     */
    func topListWidget() -> DUXBetaListPanelWidget {
        var currentCheckController = parent as? DUXBetaListPanelWidget
        while currentCheckController != nil {
            if currentCheckController!.isMember(of:DUXBetaListPanelWidget.self) {
                if currentCheckController?.isRootViewController == true {
                    return currentCheckController!
                }
            }
            currentCheckController = currentCheckController?.parent as? DUXBetaListPanelWidget
        }
        assert(false, "No rootViewController in DUXBetaListPanelWidget!")
        return DUXBetaListPanelWidget()
    }
    

    /**
     * Override of the standard configure method. Sets up the internal string model if appripriate and will call
     * setupUI if all items are ready.
     *
     * - Returns: the list panel after configuration.
     */
    override open func configure(_ configuration:DUXBetaPanelWidgetConfiguration) -> DUXBetaPanelWidget {
        listType = configuration.widgetListType
        let configOverride = configuration
        configOverride.showTitleBar = true
        
        switch listType {
            case .widgets, .widgetNames:
                break
            case .selectOne, .selectOneAndReturn:
                if let _ = model as? DUXBetaListPanelWidgetStringsModel {
                    
                } else {
                    model = DUXBetaListPanelWidgetStringsModel()
                }
                break

        case .none:
            break
        @unknown default:
            break
        }

        let result = super.configure(configOverride)
        if isConfigured && isWidgetModelSetup {
            setupUI()
        }

        return result
    }
    
    /**
     * The method setInitialSelector takes an index and selects it. Used for option string lists.
     *
     * - Parameter selectedIndex: The index to select.
     */
    open func setInitialSelection(selectedIndex: Int) {
        hasInitialSelection = true
        initialSelection = selectedIndex
    }

    //MARK: - List Manipulation
    /**
     * The method widgetCount returns the number of widgets (or strings) in the list
     *
     * - returns: Int/NSInteger count of the number of widgets or strings in the list
     */
    public override func widgetCount() -> Int {
        return model.count
    }
    
    /**
     * The method addWidgetArray adds an array of widgets into the list panel after any existing widgets. Also updates the
     * internal model and automatically calls updateUI.
     *
     * - Parameter displayWidgets: unnammed parameter of an array of widgets descended from DUXBetaBaseWidget.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    public override func addWidgetArray(_ displayWidgets: [DUXBetaBaseWidget]) {
        if hasSmartModel {
            return
        }
        model.addWidgetsArray(displayWidgets)
        tableView.reloadData()
        updateUI()
    }

    /**
     * The method insert adds a single widget into the list panel after any existing widgets. Also updates the
     * internal model and automatically calls updateUI.
     *
     * - Parameters:
     *     - widget: widget descended from DUXBetaBaseWidget.
     *     - atIndex: index to insert widget at.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    public override func insert(widget: DUXBetaBaseWidget, atIndex: Int) {
        if hasSmartModel {
            return
        }

        model.insertWidget(inWidget: widget, at: atIndex)
        tableView.reloadData()
        updateUI()
    }
    
    /**
     * The method removeWidget removes a single widgets from the list panel. Also updates the internal model and automatically
     * calls updateUI.
     *
     * - Parameters atIndex: index to remove widget from.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    public override func removeWidget(atIndex: Int) {
        if hasSmartModel {
            return
        }
        model.removeWidget(atIndex: atIndex)
        tableView.reloadData()
        updateUI()
    }
    
    /**
     * The method removeAllWidgets removes all the widgets from the list panel. Also updates the internal model and automatically
     * calls updateUI.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    public override func removeAllWidgets() {
        if hasSmartModel {
            return
        }
        model.removeAllWidgets()
        tableView.reloadData()
        updateUI()
    }

    /**
     * The method addOptionStrings adds option strings for selection to the list and updates the UI.
     *
     * - Parameter stringArray: unnamed variable which holds an array of strings to add to the selection list.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    open func addOptionStrings(_ stringArray:[String]) {
        if hasSmartModel {
            return
        }
        if let m = model as? DUXBetaListPanelWidgetStringsModel {
            m.optionStrings = stringArray
        }
    }
    
    /**
     * The method insert adds an option string at specified index in the list and updates the UI.
     *
     * - Parameters
     *     - optionString: string to add to the option list.
     *     - atIndex: index to add the string at.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    open func insert(optionString: String, atIndex: Int) {
        if hasSmartModel {
            return
        }
        if let m = model as? DUXBetaListPanelWidgetStringsModel {
            m.insertString(inString: optionString, at: atIndex)
            tableView.reloadData()
            updateUI()
        }
    }
    
    /**
     * The method removeOptionString removes the string at the specified index.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    open func removeOptionString(atIndex: Int) {
        if hasSmartModel {
            return
        }
        if let m = model as? DUXBetaListPanelWidgetStringsModel {
            m.removeWidget(atIndex: atIndex)
            tableView.reloadData()
            updateUI()
        }
    }
    
    /**
     * The method removeAllOptionStrings removes all the option strings from the list and updates the UI.
     *
     * - Note: Does not work if the list is managed with a SmartModel.
     */
    open func removeAllOptionStrings() {
        if hasSmartModel {
            return
        }
        if let m = model as? DUXBetaListPanelWidgetStringsModel {
            m.removeAllWidgets()
            tableView.reloadData()
            updateUI()
        }
    }

    
    /**
     * The method instantiates the visual components.
     */
    open func setupUI() {
        if setupUIDone {
            return
        }
        view.backgroundColor = panelBackgroundColor
        view.layer.borderColor = panelBorderColor.cgColor
        view.layer.borderWidth = 1.0


        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .uxsdk_clear()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100.0
        
        view.addSubview(tableView)
        setupUIDone = true
    }
    
    func layoutInternals() {
        // setupUI should have been called via the configuration or possibly insertion
        // of widgets, or inserting into another controller. If you haven't called
        // configure before adding widgets, you need to do so or you will crash here in the
        // autolayout setup.
        
        if internalLayoutDone {
            return
        }
        setupTitlebar()

        view.addSubview(titlebar)
        titlebar.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        titlebar.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        titlebar.topAnchor.constraint(equalTo:view.topAnchor).isActive = true

        tableView.topAnchor.constraint(equalTo:titlebar.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo:view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo:view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true

        internalLayoutDone = true
    }
    
    /**
     * The method updateUI draws the list.
     */
    open override func updateUI() {
        layoutInternals()
    }

    /**
     * The method setSublistTheme is used to setup the subview background and tableview colors.
     */
    open func setSublistTheme() {
        view.backgroundColor = .uxsdk_clear()
        tableView.backgroundColor = panelBackgroundColor
    }
    
    // MARK: - List Hierarchy Utilities
    
    func listRootViewControler() -> DUXBetaListPanelWidget? {
        if isRootViewController {
            return self
        }

        var testWidget = parent
        while testWidget != nil {
            if let panelWidget = testWidget as? DUXBetaListPanelWidget {
                if panelWidget.isRootViewController {
                    return panelWidget
                }
            }
            testWidget = testWidget?.parent
        }
        return nil
    }
    
    // MARK: - Titlebar Handling
    // We need special handling for the title bar because with nexsted lists, the close box
    // still needs to apply to the top level, while the back button only applies to this level.
    @IBAction open override func closeTapped() {
        if !isRootViewController {
            listRootViewControler()?.closeTapped()
        } else {
            super.closeTapped()
        }

        popViewControllerStack()
    }

    @IBAction open override func backButtonTapped() {
        if !isRootViewController {
            popWidget()
        }
    }
    
    // MARK: - Table Support
    /**
     * Standard protocol method for number of cells in the list.
     *
     * - Returns: Int/NSInteger count of items in list.
     */
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }
    
    /**
     * Standard protocol method for getting the display cell for a row in the list. Creates a DUXBetaWidgetCell instance with the
     * widget inserted inside and setup with autolayout.
     *
     * - Returns: UITableViewCell for display for a particular row.
     */
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var widgetCell: UITableViewCell?
        
        switch listType {
        case .widgets, .widgetNames:
            let workWidget = model.widget(at:indexPath.row)
            if let testCell = widgetToCell[workWidget] {
                widgetCell = testCell
            } else {
                widgetCell = DUXBetaWidgetCell(widget: workWidget)
                widgetToCell[workWidget] = widgetCell
            }
            break
        
        case .selectOne, .selectOneAndReturn:
            widgetCell = tableView.dequeueReusableCell(withIdentifier: "simpleText")
            if widgetCell == nil {
                widgetCell = UITableViewCell(style: .default, reuseIdentifier: "simpleText")
                widgetCell?.backgroundColor = .uxsdk_clear()
                widgetCell?.textLabel?.textColor = .uxsdk_white()
            }
            if let workModel = model as? DUXBetaListPanelWidgetStringsModel {
                widgetCell?.textLabel?.text = workModel.optionString(at: indexPath.row)
            } else {
                widgetCell?.textLabel?.text = "Missting Option String"
            }
            widgetCell?.selectionStyle = .blue
            break
        
        case .none:
            assert(false, "bad list type")
            
        @unknown default:
            assert(false, "unknown list type")
        }
        return widgetCell!
    }

    /**
     * Standard tableView protocol method to handle selection of a row. Restricted to only select style lists
     *
     * - Returns: an IndexPath if a selectable row or nil
     */
    open func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch (listType) {
        case .none:
            break
            
        case .selectOne, .selectOneAndReturn:
            return indexPath
            
        default:
            let workWidget = model.widget(at:indexPath.row)
            if let protocolWidget = workWidget as? DUXBetaListPanelSupportProtocol  {
                if let hasDetailList = protocolWidget.hasDetailList {
                    if hasDetailList() {
                        if let sublistType = protocolWidget.detailListType {
                            if (sublistType() != DUXBetaListType.none) {
                                if (sublistType() == .selectOne) {
                                    
                                }
                                return indexPath
                            }
                        }
                    }
                }
            }
        }
        return nil
    }

    /**
     * Standard tableView delegate method to handle row selection.
     *
     * If row is a widget supporting a sublist, builds the sublist and presents it.
     * If the table is a selection style, calls the selection update block.
     * If the table is a select and return, calls the selection update block and pops the presenteed list.
     */
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (listType) {
        case .widgets, .widgetNames:
            tableView.deselectRow(at: indexPath, animated: true)
            let widget = model.widget(at:indexPath.row)
            if let protocolWidget = widget as? DUXBetaListPanelSupportProtocol {
                if let hasDetailList = protocolWidget.hasDetailList, hasDetailList() {
                    if let sublistType = protocolWidget.detailListType?() {
                        if (sublistType == .selectOne) || (sublistType == .selectOneAndReturn) {
                            //TODO: Alow widget to set title.
                            let _ = listRootViewControler()?.panelTitle ?? ""
                            let _ = protocolWidget.selectionUpdate ?? nil

                            let pushList = DUXBetaListPanelWidget()
                            
                            let _ = pushList.configure(DUXBetaPanelWidgetConfiguration(type:.list, listKind:sublistType)
                                .configureTitlebar(visible: true, withCloseBox: true, withBackButton: true, title: protocolWidget.detailsTitle?() ?? title ?? "")
                            .   configureColors(background: panelBackgroundColor, border:panelBorderColor, titleBarBackground:titlebar.backgroundColor ?? .uxsdk_blackAlpha90() ))

                            // This is a List specfic hack to prevent obscuring the existing title
                            // while this list is pushed in
                            pushList.titlebar.backgroundColor = .uxsdk_black()

                            let optionDict:[String: Any] = protocolWidget.oneOfListOptions!()
                            if let stringArray = optionDict["list"] as? [String] {
                                pushList.addOptionStrings(stringArray)
                            }
                            if let selectionBlock = protocolWidget.selectionUpdate {
                                pushList.selectionUpdater = selectionBlock()
                            }
                            if let number = optionDict["current"] as? Int {
                                pushList.setInitialSelection(selectedIndex: number)
                            }

                            addChildList(pushList)
                            animateSublistIn(pushList)
                        } else if (sublistType == .widgets) || (sublistType == .widgetNames) {
                            var childWidgets: [DUXBetaBaseWidget]?
                            if (sublistType == .widgets) {
                                childWidgets = protocolWidget.listOfSubwidgets?()
                            } else {
                                // Convert the childWidgetNames into an actual list of widgets
                                if let childWidgetNames = protocolWidget.listOfSubwidgetNames?() {
                                    childWidgets = [DUXBetaBaseWidget]()
                                    for className in childWidgetNames {
                                        let classInst = NSClassFromString(className) as? NSObject.Type
                                        if let widget = classInst?.init() as? DUXBetaBaseWidget {
                                            childWidgets?.append(widget)
                                        }
                                    }
                                }
                            }

                            if let childWidgets = childWidgets {
                                
                                let pushList = DUXBetaListPanelWidget()
                                let _ = pushList.configure(DUXBetaPanelWidgetConfiguration(type:.list, listKind:sublistType)
                                    .configureTitlebar(visible: true, withCloseBox: true, withBackButton: true, title: protocolWidget.detailsTitle?() ?? title ?? "")
                                    .configureColors(background: panelBackgroundColor, border:panelBorderColor, titleBarBackground:titlebar.backgroundColor ?? .uxsdk_blackAlpha90() ))
                                pushList.addWidgetArray(childWidgets)

                                addChildList(pushList)
                                animateSublistIn(pushList)
                            }
                        }
                    }
                }
            }
            
        case .selectOne, .selectOneAndReturn:
            if let selectionUp = selectionUpdater {
                selectionUp(indexPath.row)
                if listType == .selectOneAndReturn {
                    popWidget()
                }
            }
            
        case .none:
            break
        @unknown default:
            break
        }
    }
    
    //MARK: - Internal methods
    
    func setupTableVisuals() {
        tableView.separatorColor = .uxsdk_whiteAlpha80()
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.tableFooterView = UIView()
    }
    
    func navigationController(navController: UINavigationController, willShow: UIViewController, animated: Bool) {
        // Add debugging code here for pushing the list
    }
    
    func previousListController(for target: DUXBetaListPanelWidget) -> DUXBetaListPanelWidget? {
        if target == self && isRootViewController {
            return nil
        } else {
            return listRootViewControler()?.internalPreviousListController(for: target)
        }
    }

    func internalPreviousListController(for target: DUXBetaListPanelWidget) -> DUXBetaListPanelWidget? {
        for i in 0...viewControllerStack!.count-1 {
            let tuple = viewControllerStack![i]
            if tuple.0 == target {
                // Now look 1 before.
                if (i != 0) {
                    return viewControllerStack![i-1].0
                }
            }
        }
        return nil
    }

    func addChildList(_ nextList: DUXBetaListPanelWidget) {
        // Two ways to do this. Add as child list to this parent, or add as a child list to the root.
        
        if isRootViewController {
            addChild(nextList)
            view.addSubview(nextList.view)
            nextList.didMove(toParent: self)

            nextList.view.topAnchor.constraint(equalTo:view.topAnchor).isActive = true
            nextList.view.bottomAnchor.constraint(equalTo:view.bottomAnchor).isActive = true
            nextList.view.widthAnchor.constraint(equalTo:view.widthAnchor).isActive = true
            // This last one is strange but vital. We need to anchor with left/right anchors to avoid reversing leading/trailing
            var edgeConstraint: NSLayoutConstraint? = nil
            if let (panel, _) = viewControllerStack?.last {
                edgeConstraint = nextList.view.leftAnchor.constraint(equalTo:panel.view.rightAnchor)
                edgeConstraint?.isActive = true
            } else {
                // Should never reach this since there is alwasy a parent view in the stack!
                assert(true, "Attempt to use non-existant viewController")
            }
            viewControllerStack?.append((nextList, edgeConstraint))
            
            nextList.updateUI()
            nextList.setSublistTheme()
            nextList.view.layoutIfNeeded()
        }
        else {
            listRootViewControler()?.addChildList(nextList)
        }
    }
    
    // This method must only be called on the rootview
    func internalConstraintLookup(for target: DUXBetaListPanelWidget) -> NSLayoutConstraint? {
        for (controller, constraint) in viewControllerStack! {
            if controller == target {
                return constraint
            }
        }
        return nil
    }
    
    func internalSetEdgeConstraint(for target: DUXBetaListPanelWidget, newConstraint: NSLayoutConstraint) {
        for i in 0 ..< viewControllerStack!.count {
            let tuple = viewControllerStack![i]
            if tuple.0 == target {
                viewControllerStack![i] = (tuple.0, newConstraint)
                return
            }
        }
    }

    func edgeConstraint(for widget: DUXBetaListPanelWidget) -> NSLayoutConstraint? {
        if let root = listRootViewControler() {
            return root.internalConstraintLookup(for: widget)
        }
        return nil
    }
    
    func setEdgeConstraint(for widget: DUXBetaListPanelWidget, newConstraint: NSLayoutConstraint) {
        if let root = listRootViewControler() {
            return root.internalSetEdgeConstraint(for: widget, newConstraint: newConstraint)
        }
    }

    func animateIn() {
        hideTitleBar()
        let myConstraint = edgeConstraint(for: self)
        let previousList = previousListController(for: self)
        var newConstraint: NSLayoutConstraint?
        
        if let mc = myConstraint {
            mc.isActive = false
        }

        if let prev = previousList {
            newConstraint = tableView.leftAnchor.constraint(equalTo: prev.tableView.leftAnchor)
        } else {
            newConstraint = tableView.leftAnchor.constraint(equalTo: (view!.leftAnchor))
        }
        newConstraint?.isActive = true
        setEdgeConstraint(for: self, newConstraint: newConstraint!)
        
    }
    
    func animateOut() {
        hideTitleBar()
        
        let myConstraint = edgeConstraint(for: self)
        let previousList = previousListController(for: self)
        var newConstraint: NSLayoutConstraint?
        
        if let mc = myConstraint {
            mc.isActive = false
        }

        if let prev = previousList {
            newConstraint = tableView.leftAnchor.constraint(equalTo: prev.tableView.rightAnchor)
        } else {
            newConstraint = tableView.leftAnchor.constraint(equalTo: (view!.rightAnchor))
        }
        newConstraint?.isActive = true
        setEdgeConstraint(for: self, newConstraint: newConstraint!)
        
    }

    func popViewControllerStack() {
        if isRootViewController {
            if let _ = viewControllerStack?.last {
                viewControllerStack?.removeLast()
            }
        }
    }

    func popWidget() {
        if let prev = listRootViewControler() {
            DispatchQueue.main.asyncAfter(deadline: .now()+0.01) { [weak self] in
                if let s = self {
                    s.animateOut()
                }
                UIView.animate(withDuration: 0.3, delay: 0.01, options: .curveLinear, animations: {
                    prev.view.layoutIfNeeded()
                }, completion: { [weak self] complete in
                    prev.popViewControllerStack()
                    self?.view.removeFromSuperview()
                    self?.removeFromParent()
                })
            }
        }
    }

    private func animateSublistIn(_ pushList: DUXBetaListPanelWidget) {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.01) { [weak self] in
           pushList.animateIn()
            UIView.animate(withDuration: 0.3, delay: 0.01, options: .curveLinear, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: {complete in
                pushList.showTitleBar()
            })
        }
    }
}

class DUXBetaWidgetCell : UITableViewCell {
    
    init(widget: DUXBetaBaseWidget) {
        super.init(style: .`default`, reuseIdentifier: nil)
        selectionStyle = .none
        
        let sizeHint = widget.widgetSizeHint
        var hasDetailList = false
        
        var forceAspect = true
        if let test = widget as? DUXBetaListItemTitleWidget {
            // This class supports a method to indicate if it must be proportional or not
            forceAspect = test.forceAspectRatio()
        }
        if let test = widget as? DUXBetaListPanelSupportProtocol {
            if let hasDetailMethod = test.hasDetailList {
                hasDetailList = hasDetailMethod()
            }
        }
        
        backgroundColor = .uxsdk_clear()
        let backView = contentView // Convenience access for shorter code
        backView.backgroundColor = .uxsdk_clear()
        
        contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: widget.widgetSizeHint.minimumHeight).isActive = true;
        backView.topAnchor.constraint(equalTo:contentView.topAnchor).isActive = true
        backView.leadingAnchor.constraint(equalTo:contentView.leadingAnchor).isActive = true
        backView.bottomAnchor.constraint(equalTo:contentView.bottomAnchor).isActive = true
        backView.rightAnchor.constraint(equalTo:contentView.rightAnchor).isActive = true
        
        backView.addSubview(widget.view)

        widget.view.centerYAnchor.constraint(equalTo:backView.centerYAnchor).isActive = true
        widget.view.leadingAnchor.constraint(equalTo:backView.leadingAnchor).isActive = true
        widget.view.widthAnchor.constraint(equalTo:backView.widthAnchor).isActive = true
        // TODO: Debug why addding a height anchor causes the entire cell height to collapse.
        if forceAspect {
            widget.view.heightAnchor.constraint(equalTo:widget.view.widthAnchor, multiplier:1.0/sizeHint.preferredAspectRatio).isActive = true
        } else {
            widget.view.heightAnchor.constraint(equalTo:backView.heightAnchor).isActive = true
        }

        if hasDetailList {
            accessoryType = .disclosureIndicator
            accessoryView = UIImageView(image: UIImage.duxbeta_image(withAssetNamed:"PanelNextArrow"))
        }
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
