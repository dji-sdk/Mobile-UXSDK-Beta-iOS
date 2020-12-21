//
//  DUXBetaSmartListModel.swift
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

public typealias widgetID = String

/**
 * DUXBetaSmartListModel is the base class for implementing smart models for ListPanelWidgets. The SmartListModel is passed into a ListPanelWidget
 * where it controls which widgets will added/removed in the list, removing the need for maintaining the list externally.
 */
@objcMembers open class DUXBetaSmartListModel : NSObject {
    // Mark: - Public Variables
    // A lazy instantiated model which is used to do any key bindings needed to support decision making in the SmartModel
    public lazy var internalModel = DUXBetaSmartListInternalModel()
    
    /// The list of class names which will be shown in this model. Filled in by the method buildModelLists
    open var modelClassnameList: [String] = [String]()

    // MARK: - Private Variables
    fileprivate var containerModel: DUXBetaListPanelWidgetBaseModel? = nil
    fileprivate var activeWidgetCount = 0
    fileprivate var totalWidgetCount = 0
    fileprivate var totalWidgetArray: [DUXBetaBaseWidget] = []
    fileprivate var activeWidgetArray: [DUXBetaBaseWidget] = []
    
    fileprivate var excludeItems: [widgetID] = [widgetID]()

    // MARK: - Public Methods
    
    /**
     * Init method which then builds the model lists. It does not initialize the excluded items
     */
    public override init() {
        // This method sets up anything needed by the SmartModel and is invoked during creation, before injection happens
        super.init()
        internalModel = createSmartListInternalsModel()
        internalModel.setup()
        // Set up all the default models here and install key listeners to
        // monitor for changes
        buildModelLists()
    }
    
    /**
     * Init method which then builds the model lists. It also initializes an excludedItems collection of widgetIDs which should not be shown in this list.
     */
    public init(excludeItems: [widgetID]) {
        // This method sets up anything needed by the SmartModel and is invoked during creation, before injection happens
        super.init()
        internalModel = createSmartListInternalsModel()
        internalModel.setup()
        // Set up all the default models here and install key listeners to
        // monitor for changes
        self.excludeItems = excludeItems
        buildModelLists()
    }

    
    deinit {
        for widget in totalWidgetArray {
            widget.removeObserver(self, forKeyPath: "view.hidden")
        }
        unbindRKVOModel(self)

        internalModel.cleanup()
    }
    
    /*
     * The createSmartListInternalsModel method is used to create the custom bindings needed for this particular SmartListModel. Overriding
     * this creation model allows a custom internal model with additional key listening to be added to the SmartModel.
     */
    public func createSmartListInternalsModel() -> (DUXBetaSmartListInternalModel) {
        return DUXBetaSmartListInternalModel()
    }
    
    /**
     * This method is used to set the ListPanelWidgetModel which actually contains the widgets which will be displayed. The SmartModel adjusts
     * display widgets by manipulating this model.
     */
    public func setListPanelModel(_ lpwm : DUXBetaListPanelWidgetBaseModel) -> Void {
        // This method should ideally be private and protected if possible, allowing only
        // the ListPanelWidget to access it as a friend (in C++ terminology)
        containerModel = lpwm

        buildAndInstallWidgets()
        containerModel!.setWidgetsArray(activeWidgetArray)
    }
    
    // MARK: - Widget and count finding for visible and full lists
    
    /**
     * Call activeCount to get the number of displayed widgets at the current time. This number may change dynamically depending on
     * conditions monitored by the SmartModel.
     *
     * - Returns: Int of the number of widgets currently displayed by the SmartListModel.
     */
    open func activeCount() -> Int {     // How many widgets are actually being shown in the list
        return activeWidgetCount
    }
    
    /**
     * Call totalCount to get the number of widgets under the control of the SmartModel.
     *
     * - Returns: Int of the number of widgets controlled by the SmartListModel.
     */
    open func totalCount() -> Int  {
        // How many widgets are alive, even any hidden widgets
        return totalWidgetCount
    }
    
     /**
      * The method activeWidgetAtIndex is used to find a widget at the given index in the curretly active display list.
      *
      * - Parameter index: The index in the display list to return the widget for.
      * - Returns: The widget of base type DUXBetaBaseWidget at the given index from the widgets actively displayed in the list.
      */
    open func activeWidgetAtIndex(index: Int) -> DUXBetaBaseWidget?  {
        // Fetch the widget from the list of displayed widgets. This will throw an exception if the
        // index is out of range
        return activeWidgetArray[index]
    }

    /**
     * The method widgetAtIndex is used to find a widget at the given index in the entire SmartList widget list.
     *
     * - Parameter index: The index in the entire widget list to return the widget for.
     * - Returns: The widget of base type DUXBetaBaseWidget at the given index from the entire widget list.
     */
    open func widgetAtIndex(index: Int) -> DUXBetaBaseWidget? {
        // Fetch the widget from the list of all widgets, even hidden. This will throw an exception
        // if the index is out of range
        return totalWidgetArray[index]
    }
    
    /**
     * The method findActiveWidgetWithID is used to find the widget instance by widgetID in the curretly active display list. May return nil.
     *
     * - Parameter widgetID: The widgetID to look for.
     * - Returns: The widget of base type DUXBetaBaseWidget in the actve display list or nil.
     */
    open func findActiveWidgetWithID(widgetID: String) -> DUXBetaBaseWidget? {
        // Search for a particular widget and return it if it exists and is shown or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: activeWidgetArray)
        if found {
            return activeWidgetArray[index]
        }
        return nil
    }

    /**
     * The method findWidgetWithID is used to find the widget instance by widgetID in the entire SmartList widget list. May return nil.
     *
     * - Parameter widgetID: The widgetID to look for.
     * - Returns: The widget of base type DUXBetaBaseWidget in widget list or nil.
     */
    open func findWidgetWithID(widgetID: String) -> DUXBetaBaseWidget? {
        // Search for a particular widget and return it or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: totalWidgetArray)
        if found {
            return totalWidgetArray[index]
        }
        return nil
    }
    
    /**
     * The method findActiveWidgetIndexWithID is used to find the index for a widget using the widgetID in the curretly active display list.
     *
     * - Parameter widgetID: The widgetID to look for.
     * - Returns: The index of the widget in the actve display list or NSNotFound.
     */
    open func findActiveWidgetIndexWithID(widgetID: String) -> Int {
        // Search for a particular widget and return it if it exists and is shown or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: activeWidgetArray)
        if found {
            return index
        }
        return NSNotFound
    }
    
    /**
     * The method findActiveWidgetIndexWithID is used to find the index for a widget using the widgetID in the entire widget list.
     *
     * - Parameter widgetID: The widgetID to look for.
     * - Returns: The index of the widget in the entire widget list or NSNotFound.
     */
    open func findWidgetIndexWithID(widgetID: String) -> Int {
        // Search for a particular widget and return it or nil
        let (found, index) = findIndexByWidgetID(widgetID: widgetID, list: totalWidgetArray)
        if found {
            return index
        }
        return NSNotFound
    }
    
    /**
     * The method move is used to reposition the widget specified from by widgetID to a new index.
     * IMPORTANT: The move functionality only works on the full widget list
     *
     * Parameter identifier: The widgetID to move.
     * Parameter toFullIndex: The index to move the widget to in the full widget list.
     */
    open func move(identifier: widgetID, toFullIndex: Int) {
    // This moves actual widgets in the display list order. Hidden widgets are included in the ordering
        let indexTuple = findIndexByWidgetID(widgetID: identifier, list: totalWidgetArray)
        if indexTuple.0 {
            let widget = totalWidgetArray.remove(at:indexTuple.1)
            totalWidgetArray.insert(widget, at:toFullIndex)
        }
    }
    
    /**
     * The move method moves the widget specified from one index to another in the full widget list.
     * IMPORTANT: The move functionality only works on the full widget list
     *
     * - Parameter fromFullIndex: The index to move the widget from in the full widget list.
     * - Parameter toFullIndex: The index to move the widget to in the full widget list.
     */
    open func move(fromFullIndex: Int, toFullIndex: Int) {
        let widget = totalWidgetArray.remove(at:fromFullIndex)
        totalWidgetArray.insert(widget, at:toFullIndex)
    }
    
    /**
     * Override the method setup to implment the key binding code needed specifically for the SmartModel here.
     * This is called by the DUXBetaListPanelWidgetBaseModel from its setup/cleanup methods.
     */
    open func setup() {
        bindRKVOModel(self, #selector(productConnectedChanged), (\DUXBetaSmartListModel.internalModel.isProductConnected).toString)
        bindRKVOModel(self, #selector(aircraftModelUpdated), (\DUXBetaSmartListModel.internalModel.aircraftModel).toString)
    }

    /**
     * Override the method cleanup to tear down key bindings established in setup().
     */
    open func cleanup() {
        
    }


    public func aircraftModelUpdated() {
        buildModelLists()   // This wlll be called on initial binding to the internalModel. That is done in setup()
                            // which is called from the full model during it's setup phase. At this point we know that
                            // we can at least tell which product we are using. If buildModelLists is called again later
                            // it should reconcile any changes.
        if internalModel.isProductConnected && (internalModel.aircraftModel.count > 1) {
            buildAndInstallWidgets()
        }
    }

    public func productConnectedChanged() {
        // The aircraft name changing is the key monitor in the default class at present because it happens after the
        // productConnectedChange call happens.
    }

    // MARK: - List Crafting and Construction
    /**
     * The method buildModelLists should be overriden by every class which overrides SmartModelList. It creates the full list of widgetIDs which will be
     * created and used by this SmartModel. Any additional maintenance information can also be created in here.
     */
    open func buildModelLists() {
        // In concrete class, use the KeyManager to monitor which product you are connected to and adjust this list as needed, then call buildAndInstallWidgets to replace the currently list of widgets
        // This is a brief sample (incomplete) on how to add the business logic into this method to determine what to show.
/*
        if (internalModel.isProductConnected) {
            let isInspire = internalModel.aircraftModel == DJIAircraftModelNameInspire2 || ProductUtil.isInspire1Series()
            
            modelClassnameList = [
                DUXBetaMaxAltitudeListItemWidget.duxbeta_className(),
                DUXBetaMaxFlightDistanceListItemWidget.duxbeta_className()
            ]
            if (isInspire) {
                modelClassnameList.append(DUXBetaTravelModeListItemWidget.duxbeta_className())
            }
        } else {
            modelClassnameList = [
                DUXBetaMaxAltitudeListItemWidget.duxbeta_className(),
                DUXBetaMaxFlightDistanceListItemWidget.duxbeta_className(),
                DUXBetaTravelModeListItemWidget.duxbeta_className()
            ]
        }
 */
    }

    // MARK: - Widget Custom Initialization
    /**
     * The method customizeWidgetSetup is used for custom customizations of different widgets.
     * This method can be overridden and any additional customization for select widgets can be done after they are created
     *
     * - Parameter widget: The widget to customize for display.
     */
    open func customizeWidgetSetup(widget: DUXBetaBaseWidget) {
        // For custom customizations of different widgets, this method can be overridden
        // and any additional customization for select widgets can be done after they are created
    }
    
    // MARK: - Internal functions which may be overridden

    /**
     * The method buildAndInstallWidgets is used to create all the widgets from the modelClassnameList. It usually won't need to be overridden
     * but if widgets have special needs for parameters which can not be handled in customizeWidgetSetup, this method can be overridden to handle it.
     */
    open func buildAndInstallWidgets() {
        // Decide which list to use. Base class just uses the modelClassnameList. Specialized
        // ListSmartModels may overide this method to select different lists based on connected
        // aircraft or other customizations
        activeWidgetArray.removeAll()

        var listIndex = 0;
        for className in modelClassnameList {
            let classInst = NSClassFromString(className) as? NSObject.Type
            // See if in excludeItems and prevent adding if it is in there
            if !excludeItems.contains(className) {
                let foundIndex = findWidgetIndexWithID(widgetID: className);
                if foundIndex != NSNotFound {
                    // Widget already existed, make sure it is in the right place.
                    if foundIndex != listIndex {
                        move(fromFullIndex:foundIndex, toFullIndex: listIndex)
                    }
                    if !totalWidgetArray[listIndex].view.isHidden {
                        activeWidgetArray.append(totalWidgetArray[listIndex])
                    }
                } else {
                    if let widget = classInst!.init() as? DUXBetaBaseWidget {
                        customizeWidgetSetup(widget: widget)
                        totalWidgetArray.append(widget)
                        // Need to do standard KVO for this since we aren't holding the widget in
                        // a path accessible manner for this model class so there is no valid
                        // key path from this object to the widget property
                        widget.addObserver(self, forKeyPath: "view.hidden", options: .new, context: nil)

                        if !widget.view.isHidden {
                            activeWidgetArray.append(widget)
                        }
                    }
                }
            }
            listIndex += 1
        }

    }

    /**
     * The method observeValue handles KVO monitoring for installed widgets. Override for custom handling as necessary.
     * The default implementation handles showing and removing widgets based on widget view.hidden property.
     *
     * - Parameter forKeyPath: The keypath being observed.
     * - Parameter of: The object which had a change to the observed keypath.
     * - Parameter change: A dictionary of change values such as new value, old value.
     * - Parameter context: Contextual data included when the observation was created.
     */
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let _ = object as? DUXBetaBaseWidget {
            if keyPath == "view.hidden" {
                // Visibility changed. Update the visible widget list
                buildVisibleWidgetList()
                if let cm = containerModel {
                    cm.setWidgetsArray(activeWidgetArray)
                }
            } else {
                print("Bad keyPath observed (\(String(describing: keyPath))) in ListSmartModel")
            }
        } else {
            print("Bad observing for non-widget (\(String(describing:object)) in ListSmartModel")
        }
    }
    
    /**
     * Method buildVisibleWidgetList is a shorter rebuild version of the buildAndInstallWidgets which only rebuilds
     * the visible widdet list.
     */
    open func buildVisibleWidgetList() {
        var newVisibleList: [DUXBetaBaseWidget] = [DUXBetaBaseWidget]()
        for widget in totalWidgetArray {
            if !widget.view.isHidden {
                newVisibleList.append(widget)
            }
        }
        activeWidgetArray = newVisibleList
    }
    
    // MARK: - Internal functions to not be overridden
    
    internal func findIndexByWidgetID(widgetID : String, list: [DUXBetaBaseWidget]) -> (Bool, Int) {
        for (index, aWidget) in list.enumerated() {
            let fullString = aWidget.duxbeta_className()
            let className = String(fullString.split(separator: ".").last!)
            if className == widgetID {
                return (true, index)
            }
        }
        return (false, NSNotFound)
    }
    
    // This method returns the class name with no module attached to the name
    internal func className(_ some: Any) -> String {
        return (some is Any.Type) ? "\(some)" : "\(type(of: some))"
    }

}
