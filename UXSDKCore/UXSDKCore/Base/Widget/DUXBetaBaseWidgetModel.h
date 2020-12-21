//
//  DUXBetaBaseWidgetModel.h
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

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>

#import "DUXBetaKeyManager.h"
#import "DUXBetaRKVOHeaders.h"
#import "DUXBetaBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Enum that defines all the possible states of a widget model.
 */
typedef NS_ENUM(NSUInteger, DUXBetaVMState) {
    DUXBetaVMStateCreated,
    DUXBetaVMStateSettingUp,
    DUXBetaVMStateSetUp,
    DUXBetaVMStateCleaningUp,
    DUXBetaVMStateCleanedUp,
};

@class DUXBetaUnitTypeModule;

/**
 * Base WidgetModel class to be extended by all the individual
 * widget models
 */
@interface DUXBetaBaseWidgetModel : NSObject

/**
 * The boolean value indicating if there's a product connected.
 */
@property (assign, nonatomic, readonly) BOOL isProductConnected;

/**
 * The state of the widget model.
 */
@property (nonatomic) DUXBetaVMState vmState;

/**
 * Set up the widget model by initializing all the required resources.
 */
- (void)setup;

/**
 * Setup method for initialization that must be implemented.
 */
- (void)inSetup;

/**
 * Clean up the widget model by destroying all the resources used.
 */
- (void)cleanup;

/**
 * Cleanup method for post-usage destruction that must be implemented.
 */
- (void)inCleanup;

/**
 * Method for adding a module abstraction.
 */
- (void)addModule:(DUXBetaBaseModule *)module;

@end

NS_ASSUME_NONNULL_END
