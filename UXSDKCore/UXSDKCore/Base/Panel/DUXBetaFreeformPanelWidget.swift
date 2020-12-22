//
//  DUXBetaFreeformPanelWidget.swift
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
 Type DUXBetaFreeformPanelSplitType defines which axis a pane should be split along.
 */
@objc public enum DUXBetaFreeformPanelSplitType: Int {
    case vertical = 0
    case horizontal
}

/**
 * Type DUXBetaFreformPanelWidgetAlignment defines widget placement positions within a pane, using
 * constraint style naming conventions.
 */
@objc public enum DUXBetaFreformPanelWidgetAlignment: Int {
    case centered = 0
    case topLeading
    case top
    case topTrailing
    case leading
    case trailing
    case bottomLeading
    case bottom
    case bottomTrailing
}

public typealias PaneID = Int

/**
 * This widget implments the Freeform pane. It creates a panel splitable panes. Each pane can have its own widget
 * inserted. Panes can be split and merged. Merging panes removes any content. Splitting panes maintains the parent widget
 * but it will not be visible. Removing the children of a split pane restores the parent pane as it was.
 */
@objcMembers open class DUXBetaFreeformPanelWidget : DUXBetaPanelWidget {
    /// Panels list is a non-ordered array of all panes visible in the freeform panel at the current time
    var panesList = [PaneID]()
    
    /// Private tuple definition for managing panes
    typealias paneInfoTuple = (ident: PaneID, parent: Int, paneView: UIView, controller: UIViewController?, installedView: UIView?, positioning: DUXBetaFreformPanelWidgetAlignment, constraintList: [NSLayoutConstraint], margins: UIEdgeInsets)
    /// The highest assigned paneID so far. This must only increase
    fileprivate var finalIdentifier = -1
    /// Mapping dictionary for paneID to full info about the pane
    fileprivate var paneToPaneInfo = [PaneID : paneInfoTuple]()
    /// The 0 view for the freeform panel. This may map to the full widget view or only the area below the titlebar
    fileprivate let rootView = UIView()
    
    /// Default sizing for the size hint
    fileprivate var panelSize = CGSize(width: 100, height: 50)
    /// The standard widgetSizeHint indicating the minimum size for this widget and preferred aspect ratio
    public override var widgetSizeHint : DUXBetaWidgetSizeHint {
         get { return DUXBetaWidgetSizeHint(preferredAspectRatio: (panelSize.width / panelSize.height), minimumWidth: panelSize.width, minimumHeight: panelSize.height)}
         set {}
     }
    
    /// Boolean for enabling visual debugging labels
    fileprivate var debugAssist = false
    /// Boolean for enabling varying background colors for visual debugging
    fileprivate var debugAssistBackgrounds = false
    // The text color to use for the debugging labels
    fileprivate var debugTextColor: UIColor = .uxsdk_white()
    /// The background color to use for the debugging labels
    fileprivate var debugTextBgColor: UIColor = .uxsdk_black()
    // Color list for debugging to see different panes
    fileprivate let debugColor: [UIColor] = [.uxsdk_errorDanger(), .uxsdk_selectedBlue(), .uxsdk_grayWhite50(), .uxsdk_warning(), .uxsdk_black(), .uxsdk_white()]

    /**
     * Default initialization method.
     */
    override public init() {
        super.init()
    }

    /**
     * Initializer the panel object when loaded for a Storyboard or xib. Configure must be called next.
     */
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /**
     * The init method for creating an instance of a freeform panel with just the varient.
     *
     * - Parameter variant: The variant specifying the type which is only freeform.
     */
    public init(variant: DUXBetaPanelVariant) {
        super.init()
    }

    /**
     * Override of viewDidLoad sets up the main view as the first pane and initializes the UI
     */
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        rootView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rootView)
        
        finalIdentifier += 1
        panesList.append(finalIdentifier)
        paneToPaneInfo[finalIdentifier] = (ident: finalIdentifier, parent: -1, paneView: rootView, controller: nil, installedView: nil, positioning: .centered, constraintList: [], margins: UIEdgeInsets.zero)
        
        setupUI()
    }
    
    open func setupUI() {
        setupTitlebar()
        view.addSubview(titlebar)

        let constraintArray = [
            titlebar.leadingAnchor.constraint(equalTo:view.leadingAnchor),
            titlebar.trailingAnchor.constraint(equalTo:view.trailingAnchor),
            titlebar.topAnchor.constraint(equalTo:view.topAnchor),

            rootView.topAnchor.constraint(equalTo:titlebar.bottomAnchor),
            rootView.leadingAnchor.constraint(equalTo:view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo:view.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo:view.bottomAnchor),
        ]
        NSLayoutConstraint.activate(constraintArray)
        
        view.backgroundColor = panelBackgroundColor
    }
    
    open override func updateUI() {
        
    }
    
    // MARK: - Manipulation methods
    /**
     * The method rootPane always returns the base pane for the entire Freeform panel. At this time, that paneID
     * is always 0, but may change in the future.
     */
    open func rootPane() -> PaneID {
        return 0;
    }
    
    /**
     * Call method splitPane to split the designated pane along either horizontal or vertical lines, with the specified proportions.
     *
     * - Parameters:
     *      - pane:     The paneID to be split.
     *      - along:    The axis to use for the splits. Type DUXBetaFreeformPanelSplitType.
     *      - proportions:  An array of CGFloat values between 0-1.0 specifying the percentage of space each new pane should consume
     *                      during the split operation. All values should sum to no more than 1.0.
     */
    open func splitPane(_ pane: PaneID, along: DUXBetaFreeformPanelSplitType, proportions: [CGFloat]) -> [PaneID] {
        // Two guards needed here. The parent needs to exist, and must also exist in the visible panesList
        guard let parentPaneInfo = paneToPaneInfo[pane] else { return [] }
        guard let visiblePaneIndex = panesList.firstIndex(of: pane) else { return [] }

        // If there was a widget in the pane about to be split, remove it first
        if let _ = parentPaneInfo.controller {
            removeWidgetFromPane(pane)
        } else if let _ = parentPaneInfo.installedView {
            removeViewFromPane(pane)
        }
        
        let newViewsCount = proportions.count
        if newViewsCount == 0 {
            return []
        } else if newViewsCount == 1 {
            // This just made no sense, so return the pane they wanted to split
            return [pane]
        }

        var sum: CGFloat = 0.0
        var dimensionValues = false
        for propValue in proportions {
            if propValue > 1.0 {
                dimensionValues = true      // Values coming in are not proportions! May support dimensions in future
            }
            sum += propValue
        }
        if dimensionValues {
            return [] // This probably should actually be a throw
        }

        // Allow for rounding up to 105% of the panel width for rounding errors. if the splits are more than that
        // just return without making any changes.
        if sum > 1.05 && ((sum - proportions.last!) < 1.0) {
            return []
        }
        
        // At this point we know we have an array of proportions totaling between 0 and 1.05. There are at least two entries.
        // Time to make some new views, lay them out, update the visible panes and the total pane list.
        var newPaneList = [PaneID]()
        var newViews = [UIView]()
        
        for i in 0..<newViewsCount {
            let aView = UIView()
            aView.translatesAutoresizingMaskIntoConstraints = false
            
            parentPaneInfo.paneView.addSubview(aView)

            // Depending on the axis we split along, we need to change the autolayout constrants.
            if (along == .horizontal) {
                if i == 0 {
                    // The first constraint is agains the edge
                    aView.leadingAnchor.constraint(equalTo: parentPaneInfo.paneView.leadingAnchor).isActive = true
                } else {
                    // The rest of the leading constraints follow the previous view
                    aView.leadingAnchor.constraint(equalTo: newViews[i-1].trailingAnchor).isActive = true
                }
                aView.topAnchor.constraint(equalTo: parentPaneInfo.paneView.topAnchor).isActive = true
                aView.bottomAnchor.constraint(equalTo: parentPaneInfo.paneView.bottomAnchor).isActive = true
                
                if (i == newViewsCount - 1) {
                    // The final constraint will take all the space to the trailing edge of the parent view
                    aView.trailingAnchor.constraint(equalTo: parentPaneInfo.paneView.trailingAnchor).isActive = true
                } else {
                    // Non-final constraints will be based on the proportion to the parent view specified
                    aView.widthAnchor.constraint(equalTo: parentPaneInfo.paneView.widthAnchor, multiplier: proportions[i]).isActive = true
                }
            } else {
                if i == 0 {
                    // The first constraint is against the edge
                    aView.topAnchor.constraint(equalTo: parentPaneInfo.paneView.topAnchor).isActive = true
                } else {
                    // The rest of the leading constraints follow the previous view
                    aView.topAnchor.constraint(equalTo: newViews[i-1].bottomAnchor).isActive = true
                }
                aView.leadingAnchor.constraint(equalTo: parentPaneInfo.paneView.leadingAnchor).isActive = true
                aView.trailingAnchor.constraint(equalTo: parentPaneInfo.paneView.trailingAnchor).isActive = true
 
                if (i == newViewsCount - 1) {
                    // The final constraint will take all the space to the bottom edge of the parent view
                    aView.bottomAnchor.constraint(equalTo: parentPaneInfo.paneView.bottomAnchor).isActive = true
                } else {
                    // Non-final constraints will be based on the proportion to the parent view specified
                    aView.heightAnchor.constraint(equalTo: parentPaneInfo.paneView.heightAnchor, multiplier: proportions[i]).isActive = true
                }
            }
            
            if debugAssistBackgrounds {
                let colorIndex = finalIdentifier % debugColor.count
                aView.backgroundColor = debugColor[colorIndex]
            } else {
                aView.backgroundColor = panelBackgroundColor
            }
            newViews.append(aView)
            
            // Now set up the tuple for the mapping dictionary
            finalIdentifier += 1
            let paneTuple: paneInfoTuple = (ident: finalIdentifier, parent: pane, paneView: aView, controller: nil, installedView: nil, positioning: .centered, constraintList: [], margins: UIEdgeInsets.zero)
            paneToPaneInfo[finalIdentifier] = paneTuple
            newPaneList.append(finalIdentifier)
            //And last, after all the internal maintenance has been done, add the debugging info if appropriate
            if debugAssist {
                installDebugLabel(pane: finalIdentifier)
            }
        }
        // Change the parent view background to clear after splitting to allow transparency to work with the panes just created
        parentPaneInfo.paneView.backgroundColor = .clear
        
        // Now clean up the visible pane list. Remove the current pane which was just split and add the new panes in
        panesList.replaceSubrange(visiblePaneIndex...visiblePaneIndex, with: newPaneList)
        return newPaneList
    }
    
    /**
     * Call method mergeChildren to merge all the children of a pane back to form the original pane. This deletes all the children
     * and their sub-children and re-exposes the parent pane.
     *
     * - Parameters:
     *      - parentPane:     The paneID to be revealed after removing the child panes.
     */
    open func mergeChildren(_ parentPane: PaneID) {
        var mergePanes = [PaneID]()
        for (key, info) in paneToPaneInfo {
            if info.parent == parentPane {
                mergePanes.append(key)
            }
        }
        
        for childPane in mergePanes {
            // Recursively delete any splits done in the children
            mergeChildren(childPane)
            
            // Sub children cleaned. Now remove this child view controller and its view, and finally the pane info
            if let paneInfo = paneToPaneInfo[childPane] {
                if let childController = paneInfo.controller {
                    childController.view.removeFromSuperview()
                    childController.removeFromParent()
                }
                if let childView = paneInfo.installedView {
                    childView.removeFromSuperview()     // No controller manipulation needed. This is only really needed if somebody is retaining the paneView, which they shouldn't.
                }
                paneInfo.paneView.removeFromSuperview()
                paneToPaneInfo[childPane] = nil
                if let firstIndex = panesList.firstIndex(of: childPane) {
                    panesList.remove(at: firstIndex)
                }
            }
        }
        // All children removed. panesList cleaned up. Add the parent back into the visible panes list
        panesList.append(parentPane)
        // Reset the background color for the now re-exposed panel to the panel background color. This will possibly
        // be the wrong behavior if the pane had a custom background color set. The developer will need to reset the
        // color in that case. This is the result of allowing transparency to work after a split.
        backgroundViewForPane(parentPane)?.backgroundColor = panelBackgroundColor
    }
    
    /**
     * Call method mergeSiblings to merge all the siblings of a pane back to form the original pane. This deletes all the siblings and
     * their children and re-exposes the parent pane.
     *
     * - Parameters:
     *      - pane: The paneID to be merged with its siblimgs and removed to reveal the parent pane.
     */
    open func mergeSiblings(_ pane: PaneID) -> PaneID {
        //    typealias paneInfoTuple = (ident: PaneID, parent: Int, view: UIView, controller: UIViewController?, installedView: UIView?)
        let parentPane = getParentID(pane)
        if parentPane != -1 {
            mergeChildren(parentPane)
        }
        return parentPane;
    }
    
    
    /**
     * The method addWidget installs a DUXBetaBaseWidget descendent widget into the designated pane, removing any existing widget already there
     *  and positions it as requested inside the pane. This method is called by the the install(in:pane:position:) extension to DUXBetaBaseWidget
     *  and is also exposed as a direct call.
     *
     * - Parameters:
     *      - widget: The widget to be added to the freeform panel.
     *      - toPane: The paneID the widget should be added into.
     *      - position: What position in the pane the widget should be added at. One of the 9 posiitons defined by DUXBetaFreformPanelWidgetAlignment.
     *      - margins: Optional argument to add insets from the pane edge when positioning.
     */
    open func addWidget(_ widget: DUXBetaBaseWidget, toPane: PaneID, position: DUXBetaFreformPanelWidgetAlignment = .centered, margins: UIEdgeInsets = UIEdgeInsets.zero) {
        if let _ = widgetInPane(toPane) {
            removeWidgetFromPane(toPane)
        }
        if let _ = viewInPane(toPane) {
            removeViewFromPane(toPane)
        }
        guard let installView = backgroundViewForPane(toPane) else { return }
        
        widget.install(in: self, insideSubview: installView)
        // Now we just have to do the aligment
        installConstraints(newView: widget.view, inPane: toPane, alignment: position, margins: margins)
        
        // Finally, update the paneInfo to contain the new widget added
        if var paneInfo = paneToPaneInfo[toPane] {
            paneInfo.controller = widget
            paneInfo.positioning = position
            paneToPaneInfo[toPane] = paneInfo
        }
    }
    
    /**
     * The method addView installs a UIView descendent into the designated pane, removing any existing widget or view already there
     *  and positions it as requested inside the pane. This method is exposed as a direct call for adding non-widget view into the
     *  freeform panel.
     *
     * - Parameters:
     *      - view: The view to be added to the freeform panel.
     *      - toPane: The paneID the widget should be added into.
     *      - position: What position in the pane the view should be added at. One of the 9 posiitons defined by DUXBetaFreformPanelWidgetAlignment.
     *      - margins: Optional argument to add insets from the pane edge when positioning.
     */
    open func addView(_ inView: UIView, toPane: PaneID, position: DUXBetaFreformPanelWidgetAlignment = .centered, margins: UIEdgeInsets = UIEdgeInsets.zero) {
        if let _ = widgetInPane(toPane) {
            removeWidgetFromPane(toPane)
        }
        if let _ = viewInPane(toPane) {
            removeViewFromPane(toPane)
        }
        guard let installView = backgroundViewForPane(toPane) else { return }
        var debugSubview: UIView? = nil
        if debugAssist {
            // The debug view should be present. Put this below the debug view if it does exist
            for item in installView.subviews {
                if let debugInfoView = item as? FreeformPaneDebugTabLabel {
                    debugSubview = debugInfoView
                    break
                }
            }
        }

        installView.addSubview(inView)
        // Now we just have to do the aligment
        installConstraints(newView: inView, inPane: toPane, alignment: position, margins: margins)

        // If we were debugging, move the debugging info on top again
        if let topPane = debugSubview {
            installView.bringSubviewToFront(topPane)
        }

        // Finally, update the paneInfo to contain the new widget added
        if var paneInfo = paneToPaneInfo[toPane] {
            paneInfo.installedView = inView
            paneInfo.positioning = position
            paneToPaneInfo[toPane] = paneInfo
        }
    }

    /**
     * The method removeWidgetFromPane removes the widget from the specified pane.
     *
     * - Parameters:
     *      - pane: The paneID the widget should be removed from.
     */
    open func removeWidgetFromPane(_ pane: PaneID) {
        // Lots of housekeeping to do here
        var paneInfo = paneToPaneInfo[pane]
        // Remove the widget from the tuple
        if let widget = paneInfo?.controller {
            paneInfo?.controller = nil;
            widget.removeFromParent()
            widget.view.removeFromSuperview()
            paneToPaneInfo[pane] = paneInfo
        }
    }
    
    /**
     * The method removeViewFromPane removes any inserted view from the specified pane.
     *
     * - Parameters:
     *      - pane: The paneID the views should be removed from.
     */
    open func removeViewFromPane(_ pane: PaneID) {
        var paneInfo = paneToPaneInfo[pane]
        // Remove the installedView from the tuple
        if let installedView = paneInfo?.installedView {
            installedView.removeFromSuperview()
            paneInfo?.installedView = nil
            paneToPaneInfo[pane] = paneInfo
        }
    }

    // MARK: - Utility functions
    /**
     * The method findPaneWithWidget searches the freeform panel for the designated widget and returns the PaneID it is installed in.
     * If the widget is not installed in the freeform pane, this method returns -1.
     *
     * - Parameters:
     *      - widget: The widget to find in the freeform panel.
     *
     * - Returns: Either the found PaneID or -1 if the widget was not found.
     */

    open func findPaneWithWidget(_ widget: DUXBetaBaseWidget) -> PaneID {
        for (key, info) in paneToPaneInfo {
            if info.controller == widget {
                return key
            }
        }
        return -1
    }
    
    /**
     * The method widgetInPane returns the widget installed in the pane or nil.
     *
     * - Parameters:
     *      - pane: The pane to look at to get the widget.
     *
     * - Returns: Either the DUXBetaBaseWidget or nil if no widget was found.
     */
    open func widgetInPane(_ pane: PaneID) -> DUXBetaBaseWidget? {
        if let paneInfo = paneToPaneInfo[pane] {
            return paneInfo.controller as? DUXBetaBaseWidget
        }
        
        return nil
    }
    
    /**
     * The method viewInPane returns the view installed in the pane or nil.
     *
     * - Parameters:
     *      - pane: The pane to look at to get the widget.
     *
     * - Returns: Either the UIView or nil if no widget was found.
     */
    open func viewInPane(_ pane: PaneID) -> UIView? {
        if let paneInfo = paneToPaneInfo[pane] {
            return paneInfo.installedView
        }
        
        return nil
    }

    
    /**
     * The method getSiblingsList returns all the PaneIDs of the siblings of the designated pane, including the originl PaneID.
     * The result is a sorted, inclusive list of the siblings.
     *
     * - Parameters:
     *      - pane: The pane whose siblings are wanted.
     *
     * - Returns: A sorted array of PaneIDs.
     */
    open func getSiblingsList(_ pane: PaneID) -> [PaneID] {
        let parentPane = paneToPaneInfo[pane]?.parent ?? -1
        if parentPane == -1 {
            return []
        }
        
        var sibsArray = [PaneID]()
        for (key, info) in paneToPaneInfo {
            if info.parent == parentPane {
                sibsArray.append(key)
            }
        }

        return sibsArray.sorted()
    }

    /**
     * The method getParentID returns the parent PaneID of the requestd Pane
     *
     * - Parameters:
     *      - pane: The pane whose parent is wanted.
     *
     * - Returns: the parent PaneID or -1 if there is no parent (i.e. the root pane)
     */
    open func getParentID(_ pane: PaneID) -> PaneID {
        var parentPane = -1
        if let paneInfo = paneToPaneInfo[pane] {
            parentPane = paneInfo.parent
        }
        return parentPane;
    }
    
    /**
     * The method backgroundViewForPane(_ forPane:) returns the parent PaneID of the requested Pane
     *
     * - Parameters:
     *      - pane: The pane whose parent is wanted.
     *
     * - Returns: the parent PaneID or -1 if there is no parent (i.e. the root pane)
     */
    open func backgroundViewForPane(_ forPane: PaneID) -> UIView? {
        if let tuple = paneToPaneInfo[forPane] {
            return tuple.paneView
        } else {
            return nil
        }
    }
    
    /**
     * The method setBackgroundColor is a convenience method for setting the background color of a pane.
     *
     * - Parameters:
     *      - backgroundColor: The new color for the background. Pass nil to remove existing color.
     *      - pane: The pane whose background should be set.
     */
    open func setBackgroundColor(_ backgroundColor: UIColor?, forPane: PaneID) {
        if let tuple = paneToPaneInfo[forPane] {
            tuple.paneView.backgroundColor = backgroundColor;
        }
    }
    
    /**
     * The method paneID(forView: UIView) returns the parent PaneID for the pane containing the requested view.
     * This works for nested views as well as top level view.
     *
     * - Parameters:
     *      - forView: The view whose paneID is wanted.
     *
     * - Returns: the PaneID for the view or -1 if no visible pane contains the view.
     */
    open func paneID(forView: UIView) -> PaneID {
        for testPaneID in panesList {
            if let testView = backgroundViewForPane(testPaneID) {
                if testView == forView {
                    return testPaneID
                }
                if forView.isDescendant(of: testView) {
                    return testPaneID
                }
            }
        }
        return -1;
    }
    
    /**
     * The method panePositioning returns the positioning for a widget or view in a pane. If the paneID is invalid it returns .centered as the default.
     *
     * - Parameters:
     *      - paneID: The paneID to get positioning for.
     *
     * - Returns: the positioning value for the PaneID contents or .centered if paneID is invalid.
     */
    open func panePositioning(_ paneID: PaneID) -> DUXBetaFreformPanelWidgetAlignment {
        if let tuple = paneToPaneInfo[paneID] {
            return tuple.positioning
        }
        return .centered
    }
    
    /**
     * The method setPositioning changes the positioning info for the give paneID contents.
     *
     * - Parameters:
     *      - paneID: The paneID to change the positioning for.
     *      - positioning: The new positioning orientation
     *      - margins: Optional argument to add insets from the pane edge when positioning.
     */
    open func setPositioning(_ paneID: PaneID, positioning: DUXBetaFreformPanelWidgetAlignment, margins: UIEdgeInsets = UIEdgeInsets.zero) {
        guard let tuple = paneToPaneInfo[paneID] else { return }
        guard let installView = tuple.installedView else { return }
        if tuple.positioning != positioning {
            installConstraints(newView: installView, inPane: paneID, alignment: positioning, margins: margins)
        }
    }
    
    // MARK: - Debugging Tools
    /**
     * The method enablePaneDebug activates or deactivates some visual debugging tools for the freeform panel. These tools can help you
     * quickly debug how your panes are appearing and where, and how large they are.
     *
     * - Parameters:
     *      - assist:           Turns debugging PaneIDs on or off in each pane.
     *      - backgroundAssist: This optional boolean sets the background color of panes using a rotating list of colors to help visualize where
     *                          each pane displays. Defaults to off.
     *      - textColor:        This optional parameter sets the UIColor of the text label for each pane created after the assist is turned on.
     *                          Defaults to .uxsdk_white().
     *      - textBackground:   This optional parameter sets the UIColor to use as the background color of the text label.
     *                          Defaults to .uxsdk_black().
     */
    open func enablePaneDebug(assist: Bool, backgroundAssist : Bool = false, textColor: UIColor? = nil, textBackground: UIColor? = nil) {
        if let textColor = textColor {
            debugTextColor = textColor
        }
        if let textBackground = textBackground {
            debugTextBgColor = textBackground
        }
        
        if (debugAssist == assist) && (backgroundAssist == debugAssistBackgrounds) {
            return
        }
        debugAssist = assist
        debugAssistBackgrounds = backgroundAssist

        if debugAssist {
            if finalIdentifier >= 0 {
                for pane in 0...finalIdentifier {
                    installDebugLabel(pane: pane)
                }
            }
        } else {
            for (_, paneInfo) in paneToPaneInfo {
                // Find the UILabel and remove it
                var labelToRemove : FreeformPaneDebugTabLabel?
                for maybeLabel in paneInfo.paneView.subviews {
                    labelToRemove = maybeLabel as? FreeformPaneDebugTabLabel
                    if let _ = labelToRemove {
                        break;
                    }
                }
                labelToRemove?.removeFromSuperview()
            }
        }
    }
    
    // MARK: -  Internal Methods
    
    func installConstraints(newView: UIView, inPane: PaneID, alignment: DUXBetaFreformPanelWidgetAlignment, margins: UIEdgeInsets) {
        guard var tuple = paneToPaneInfo[inPane] else { return }
        let installView = tuple.paneView
        // Deactivate existing constraints to allow repositioning
        if tuple.constraintList.count > 0 {
            NSLayoutConstraint.deactivate(tuple.constraintList)
        }
        
        var constraintArray = [NSLayoutConstraint]()
        switch alignment {
            case .centered:
                constraintArray = [
                    newView.centerXAnchor.constraint(equalTo:installView.centerXAnchor),
                    newView.centerYAnchor.constraint(equalTo:installView.centerYAnchor),
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .topLeading:
                constraintArray = [
                    newView.topAnchor.constraint(equalTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(equalTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .top:
                constraintArray = [
                    newView.centerXAnchor.constraint(equalTo:installView.centerXAnchor),
                    newView.topAnchor.constraint(equalTo: installView.topAnchor),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .topTrailing:
                constraintArray = [
                    newView.topAnchor.constraint(equalTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(equalTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .leading:
                constraintArray = [
                    newView.centerYAnchor.constraint(equalTo:installView.centerYAnchor),
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(equalTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .trailing:
                constraintArray = [
                    newView.centerYAnchor.constraint(equalTo:installView.centerYAnchor),
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(lessThanOrEqualTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(equalTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .bottomLeading:
                constraintArray = [
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(equalTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(equalTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .bottom:
                constraintArray = [
                    newView.centerXAnchor.constraint(equalTo:installView.centerXAnchor),
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(equalTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(lessThanOrEqualTo: installView.trailingAnchor, constant: -margins.right),
                ]
            case .bottomTrailing:
                constraintArray = [
                    newView.topAnchor.constraint(greaterThanOrEqualTo: installView.topAnchor, constant: margins.top),
                    newView.bottomAnchor.constraint(equalTo: installView.bottomAnchor, constant: -margins.bottom),
                    newView.leadingAnchor.constraint(greaterThanOrEqualTo: installView.leadingAnchor, constant: margins.left),
                    newView.trailingAnchor.constraint(equalTo: installView.trailingAnchor, constant: -margins.right),
                ]
        }
        NSLayoutConstraint.activate(constraintArray)
        tuple.constraintList = constraintArray
        tuple.margins = margins
        paneToPaneInfo[inPane] = tuple
    }
        
    func installDebugLabel(pane: PaneID) {
        if let theView = backgroundViewForPane(pane) {
            // Make sure one doesn't already exist
            for item in theView.subviews {
                if let _ = item as? FreeformPaneDebugTabLabel {
                    return
                }
            }
            let debugLabel = FreeformPaneDebugTabLabel()
            debugLabel.translatesAutoresizingMaskIntoConstraints = false
            debugLabel.textColor = debugTextColor
            debugLabel.backgroundColor = debugTextBgColor
            debugLabel.textAlignment = .left
            debugLabel.text = "\(pane)"

            theView.addSubview(debugLabel)
            NSLayoutConstraint.activate([
                debugLabel.topAnchor.constraint(equalTo: theView.topAnchor, constant:4.0),
                debugLabel.leadingAnchor.constraint(equalTo: theView.leadingAnchor, constant: 4.0),
                debugLabel.widthAnchor.constraint(equalToConstant: 30.0),
                debugLabel.heightAnchor.constraint(equalToConstant: 20.0)
            ])
        }
    }
}

// MARK: -  DebugTabLabel
/**
 * This class is a trivial subclass of UILabel for allowing distinguishing debugging labels from normal UILabels.
 */
@objc open class FreeformPaneDebugTabLabel : UILabel {
    
}

// MARK: - Widget Installation Extension/Category
/**
 * Extension (category) on DUXBetaBaseWidget to specically handle adding a widget into a DUXBetaFreeformPanelWidget. It adds a required and an
 * option parameter to the standard install(in:) method.
 */
extension DUXBetaBaseWidget {
    /**
     * The method install(in:pane:position:) extends the UXBaseWidget to allow consistent adding of widgets to freeform panes, like adding
     * widgets into other panels or widgets.
     *
     * - Parameters:
     *      - in:   The freeform widget to install this widget into.
     *      - pane: The PaneID where the widget should be installeed.
     *      - position: The option pane relative positioning to be used when installing the widget in a pane. Defaults to .centered.
     *      - margins: Optional argument to add insets from the pane edge when positioning.
     */
    @objc open func install(in panelWidget: DUXBetaFreeformPanelWidget, pane: PaneID, position: DUXBetaFreformPanelWidgetAlignment = .centered, margins: UIEdgeInsets = UIEdgeInsets.zero) {
        panelWidget.addWidget(self, toPane: pane, position: position, margins: margins)
    }

}
