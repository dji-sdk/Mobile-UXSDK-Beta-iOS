//
//  DUXBetaListItemSwitchWidgetModel.h
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

#import <DJIUXSDKWidgets/DUXBetaBaseWidgetModel.h>

/**
 * @brief DUXBetaWidgetModelActionCompletionBlock defines the action block to be called when the widget switch changes state.
 * @param error Any NSError which was generated trying to change the switch state.
 */
typedef void (^DUXBetaWidgetModelActionCompletionBlock)(NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

/**
 * @class DUXBetaListItemSwitchWidgetModel is a Widget class descending from DUXBetaBaseWidgetModel, meant to be used in DUXBetaListPanelWidgets. It implements
 * a simple switch using a DJIKey which references a boolean value. The switch widget updates the actual key when a value changes and calls
 * the specified DUXBetaWidgetModelActionCompletionBlock to allow additonal action to be taken on the state change.
 */
@interface DUXBetaListItemSwitchWidgetModel : DUXBetaBaseWidgetModel
// A generic boolean value to hold the current key state for easy reading.
@property (nonatomic, readwrite) BOOL genericBool;

/**
 * @brief Call initWithKey when allocating the widget, passing in the DJIKey which will be monitored.
 * @param theKey DJIKey which as been created and is associated with a Boolean value.
 * @return The newly initialzied instance of DUXBetaListItemSwitchWidgetModel.
 */
- (instancetype)initWithKey:(DJIKey*)theKey;

/**
 * @brief The method toggleSettingsWithCompletionBlock is used to set the completion callback block when the switch setting changes. This allows additional
 * processing to be done on boolean state change.
 * @param completionBlock A block of type DUXBetaWidgetModelActionCompletionBlock.
 */
- (void)toggleSettingWithCompletionBlock:(DUXBetaWidgetModelActionCompletionBlock)completionBlock;

@end

NS_ASSUME_NONNULL_END
