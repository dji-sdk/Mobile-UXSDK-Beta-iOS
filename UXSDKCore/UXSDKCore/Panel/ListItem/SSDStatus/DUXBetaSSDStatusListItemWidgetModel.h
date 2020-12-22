//
//  DUXBetaSSDStatusListItemWidgetModel.h
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

#import <UXSDKCore/UXSDKCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DUXBetaSSDStatusListItemWidgetModel : DUXBetaBaseWidgetModel
/**
 * The isSSDConnected indicates if this aircraft/camera combination has a usable SSD (Inspire 2 only). Camera must be attached to show SSD.
 */
@property (nonatomic, readonly) BOOL isSSDConnected;

/**
 * The size of storage still available on the SSD drive in one megabyte increments. 1024 Megabytes to the GigaByte.
 */
@property (nonatomic, readonly) NSUInteger freeStorageInMB;

/**
 * The available recording time still available based on current camera settings. Not currently displayed.
 */
@property (nonatomic, readonly) NSUInteger availableRecordingTimeInSeconds;

/**
 * The current operating state of the SSD drive when attached.
 */
@property (nonatomic, readonly) DJICameraSSDOperationState ssdOperationState;

/**
 * Boolean value indicating if formatting an SSD had an immediate error.
 */
@property (nonatomic, readwrite) BOOL        ssdFormatError;

/**
 * The error description value send by the SDK if formatting an SD Card had an immediate error.
 */
@property (nonatomic, readonly) NSString     *formatErrorDescription;

- (void)formatSSD;

@end

NS_ASSUME_NONNULL_END
