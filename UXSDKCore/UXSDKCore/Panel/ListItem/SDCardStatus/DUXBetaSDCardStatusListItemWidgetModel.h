//
//  DUXBetaSDCardStatusListItemWidgetModel.h
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

#import "DUXBetaBaseWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Model for the SystemStatusList widget to show the current status/free space on the RC card for a camera.
*/

@interface DUXBetaSDCardStatusListItemWidgetModel : DUXBetaBaseWidgetModel
/**
 * The operationState for the SD Card installed in the drone SD card slot
 */
@property (nonatomic, readonly) DJICameraSDCardOperationState sdOperationState;

/**
 * The camera index this model is currently observing. Defaults to camera 0.
 */
@property (nonatomic, readwrite) NSUInteger preferredCameraIndex;

/**
 * The size of storage still available on the SD card in one megabyte increments. 1024 Megabytes to the Gigabyte.
 */
@property (nonatomic, readonly) NSInteger   freeStorageInMB;

/**
 * Boolean value indicating if an SD Card is currenlty inserted.
 */
@property (nonatomic, readonly) BOOL        isSDCardInserted;

/**
 * Boolean value indicating if formatting an SD Card had an immediate error.
 */
@property (nonatomic, readwrite) BOOL        sdCardFormatError;

/**
 * The error description value send by the SDK if formatting an SD Card had an immediate error.
*/
@property (nonatomic, readonly) NSString     *formatErrorDescription;


- (void)formatSDCard;

@end

NS_ASSUME_NONNULL_END
