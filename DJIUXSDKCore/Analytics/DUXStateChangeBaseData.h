//
//  DUXStateChangeBaseData.h
//  DJIUXSDKCore
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

NS_ASSUME_NONNULL_BEGIN
/**
 * This is DUXStateChangeBaseData, the base class for data transmitted by the UI and Model hooks supplied throughtout the UX SDK code base
 * to notify developer of chaniging events.
 * Each instance of this class or it's descendents contains a key and a value for that key. It is dependent on the receiver to know what kind of data to expect
 * with the hook. Convenience methods have been supplied in this class for easy access to the contents.
 *
 * The key can be retrieved as a string, using the key method.
 */
@interface DUXStateChangeBaseData : NSObject
/**
 * Initialization methods for each of the types of data to be delivered.
 */
- (instancetype)initWithKey:(NSString*)key;
- (instancetype)initWithKey:(NSString*)key number:(NSNumber*)number;
- (instancetype)initWithKey:(NSString*)key value:(NSValue*)value;
- (instancetype)initWithKey:(NSString*)key string:(NSString*)string;
- (instancetype)initWithKey:(NSString*)key object:(id)object;

/**
 * Accessors for the contents of the DUXStateChangeBaseData instance.
 */
- (NSString*)key;
- (NSValue*)value;
- (NSNumber*)number;
- (NSString*)string;
- (id)object;

@end

NS_ASSUME_NONNULL_END
