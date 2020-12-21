//
//  DUXBetaCustomValueConfirmation.h
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

@interface DUXBetaCustomValueConfirmation : NSObject

/**
 *  info, you can custom the info to transfer.
 */
@property (strong, nonatomic) NSDictionary * _Nullable info;

/**
 *  Accept this action with setting value.
 */
- (void)accept;

/**
 *  Accept this action with value.
 *
 *  @param value value
 */
- (void)acceptWithValue:(nullable id)value;

/**
 *  Decline this action with error.
 *
 *  @param error the reason cause failed.
 */
- (void)declineWithError:(nonnull NSError *)error;

/**
 *  If error is nil, will accept this action, if error is not nil, will decline this action.
 *
 *  @param error error the reason cause failed.
 */
- (void)confirmWithError:(nullable NSError *)error;

@end
