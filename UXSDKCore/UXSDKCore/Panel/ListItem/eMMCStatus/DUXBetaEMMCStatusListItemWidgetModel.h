//
//  DUXBetaEMMStatusListItemWidgetModel.h
//  
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

@interface DUXBetaEMMCStatusListItemWidgetModel : DUXBetaBaseWidgetModel
/**
 * Boolean value indicating if internal storage supported on this aircraft.
 */
@property (nonatomic, readonly) BOOL        isInternalStorageSupported;

/**
 * The operationState for the SD Card used for internal storage.
 */
@property (nonatomic, readonly) DJICameraSDCardOperationState internalStorageOperationState;

/**
 * The size of storage still available on the internal storage in one megabyte increments. 1024 Megabytes per Gigabyte.
 */
@property (nonatomic, readonly) NSInteger   freeStorageInMB;

/**
 * Boolean value indicating if an internal SD Card is currenlty inserted.
 */
@property (nonatomic, readonly) BOOL        isInternalStorageInserted;

/**
 * Boolean value indicating if formatting the internal SD Card had an immediate error.
 */
@property (nonatomic, readwrite) BOOL        sdCardFormatError;

/**
 * The error description value send by the SDK if formatting the internal SD Card had error.
 */
@property (nonatomic, readonly) NSString     *formatErrorDescription;


- (void)formatSDCard;

@end

NS_ASSUME_NONNULL_END
