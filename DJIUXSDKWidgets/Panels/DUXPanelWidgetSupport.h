//
//  DUXPanelWidgetSupport.h
//  DJIUXSDK
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
#ifndef DUXPanelWidgetSupport_h
#define DUXPanelWidgetSupport_h

/**
 * @protocol: The DUXToolbarPanelSupportProtocol is a protocol to be adoped by any widget which will be added into a
 * Toobar panel (DUXToolbarPanel). It defines two optional methods, at least one of the two methods must be implemented
 * for the tool widget to become visible in the Toolbar.
 *
 * - toolbatItemTitle - Returns a string which will be used to label the selectable tool.
 * - toolbarItemIcon - Returns a UIImage for the icon for the tool to be shown in the toolbar area.
 */
@protocol DUXToolbarPanelSupportProtocol
@optional
/**
 * This method, if implemented, returns the title to use for labeling the tool item in the toolbar.
 *
 * @return NSString
 */
- (NSString * _Nullable) toolbarItemTitle;

/**
 * This method, if implemented, returns the icon to use for showing the tool item in the toolbar.
 *
 * @return DUXListSelectOne UIImage
*/
- (UIImage * _Nullable) toolbarItemIcon;
@end

/**
 * DUXListType defines the type and behavior of a DUXListPanelWidget and the type of objects it will accept to
 * construct the list.
 */
typedef NS_ENUM(NSInteger, DUXListType) {
    /// Default value which indicates the list is unconfigured
    DUXListNone = 0,
    /// List will show a number of string options, only allowing a single option to be selected
    DUXListSelectOne,
    /// List will show a number of string options, only allowing a single option to be selected. List returns to parent list on selection
    DUXListSelectOneAndReturn,
    /// List will show widgets which have already been created and setup for display.
    DUXListWidgets,
    /// List will take an widget classnames and create the widgets internally
    DUXListWidgetNames
};

@class DUXListPanelWidget, DUXBetaBaseWidget;

@protocol DUXListPanelSupportProtocol

@optional
/**
 * hasDetailList indicates if this item has a sublist which can be displayed. If YES, the detail accessory will be addded to
 * the display cell. Not implementing this method is the same as always returning NO.
 * The widget must also include the following protocol methods:
 *
 * Additional required protocol methods:
 *
 *   detailsTitle
 *
 *   detailTypeList
 *
 * Required methods for single item selection sub-lists:
 *
 *   selectionUpdate
 *
 *   oneOfListOptions
 *
 * @return BOOL value. YES for has detail list, no for no detail list.
 */
- (BOOL)hasDetailList;

/**
 * This method supplies the title to be used in the titlebar for the sublist.
 *
 * @return NSString of the sublist title.
 */
- (NSString *_Nonnull)detailsTitle;

/**
 * This method returns the type of the sublist to be displayed. This is one of the standard list types.
 *
 * @return DUXListType.
 */
- (DUXListType)detailListType;


/**
 * selectionUpdate returns the executable block which will be called whenever a selection is made lists of type
 * DUXListSelectOne or DUXListSelectOneAndReturn.
 *
 * @return an executable block taking a single integer index for the selected item.
 *
 * @code
 *   typedef void (^selectionUpdateBlock)(NSInteger selectionIndex);
 * @endcode
 *
 * The functional signature of the callback block, passing in the selected index from the list.
*/
- (void(^_Nonnull)(NSInteger))selectionUpdate;

/**
 * Implement this for DUXListSublistSelectOne and DUXListSublistSelectOneAndReturn
 * The returned dictionary contains two keys.
 *
 * Dictionary keys
 *
 * "current": An NSNumber containing the default selected value. Return NSNumber(-1) for no selection.
 * "list"   : An NSArray containting the strings to be displayed as options.
 *
 * @return An NSDictionary containing two keys, "current":NSNumber(default selection) and "list":NSArray<NSString*>*.
 *
 */
- (NSDictionary<NSString*, id>* _Nonnull)oneOfListOptions;

/**
 * This method is caled if the sublist type is DUXListSublistWidgetNames. It returns the names of the widgets to create
 * and populate into the sublist.
 *
 * @return NSArray of classnames.
 */
- (NSArray<NSString*> * _Nonnull)listOfSubwidgetNames;

/**
 * This method is caled if the sublist type is DUXListSublistWidgets. It returns an array of widgets to populate into the sublist.
 *
 * @return NSArray of widgets descended from DUXBetaBaseWidget.
*/
- (NSArray<DUXBetaBaseWidget*> * _Nonnull)listOfSubwidgets;

@end

#endif /* DUXPanelWidgetSupport_h */
