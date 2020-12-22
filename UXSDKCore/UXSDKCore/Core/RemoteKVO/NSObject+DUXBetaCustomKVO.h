//
//  NSObject+DUXBetaCustomKVO.h
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
#import <UXSDKCore/NSError+DUXBetaCustomKVO.h>
#import <UXSDKCore/DUXBetaCustomValueConfirmation.h>

/**
 *  Those KVO method would be release automatic, no need to worry about that.
 */
@interface NSObject (DUXBetaCustomKVO)

/**
 *  Add custom observer. Just like KVO.
 *
 *  @param observer observer
 *  @param keyPath  keyPath
 *  @param block    custom selector, it must be has two parameters. 
 *  @note if a value was nil or [NSNull null], it only would be nil.
 */
- (void)duxbeta_addCustomObserver:(nonnull NSObject *)observer
               forKeyPath:(nonnull NSString *)keyPath
                    block:(nonnull void(^)(id _Nullable oldValue,id _Nullable newValue))block;

/**
 *  Add custom observer. Just like KVO.
 *
 *  @param observer observer
 *  @param keyPath  keyPath
 *  @param selector custom selector, it must be has two parameters.
 *  @note if a value was nil or [NSNull null], it only would be nil.
 */
- (void)duxbeta_addCustomObserver:(nonnull NSObject *)observer
               forKeyPath:(nonnull NSString *)keyPath
                 selector:(nonnull SEL)selector;

/**
 *  Add custom observer, for multiple block.
 *
 *  @param observer observer
 *  @param keyPaths keypath
 *  @param block    custom selector, it must be has two parameters.
 *  @note if a value was nil or [NSNull null], it only would be nil.
 */
- (void)duxbeta_addCustomObserver:(nonnull NSObject *)observer
               forKeyPaths:(nonnull NSArray *)keyPaths
                 block:(nonnull void(^)(NSString *_Nullable keypath,id _Nullable oldValue,id _Nullable newValue))block;

/**
 *  Remove custom observer with keypath.
 *
 *  @param observer observer
 *  @param keyPath  keyPath
 */
- (void)duxbeta_removeCustomObserver:(nonnull NSObject *)observer
                  forKeyPath:(nonnull NSString *)keyPath;

/**
 *  Remove custom observer with keypath.
 *
 *  @param observer observer
 *  @param keyPaths  keyPaths
 */
- (void)duxbeta_removeCustomObserver:(nonnull NSObject *)observer
                  forKeyPaths:(nonnull NSArray<NSString *> *)keyPaths;

/**
 *  Remove custom observer
 *
 *  @param observer observer
 */
- (void)duxbeta_removeCustomObserver:(nonnull NSObject *)observer;

@end

@interface NSObject (DUXBetaCustomAsyncKVO)

- (nullable id)duxbeta_customValueForKeyPath:(nonnull NSString *)keyPath;

/**
 *  If not replace the async set method, default will call setPropertyName:completion: , PropertyName according to your keyPath last component.
 *
 *  @param value    setting value.
 *  @param keyPath  key path.
 *  @param block    completion block.
 */
- (void)duxbeta_setCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueSetCompletionBlock)block;

/**
 *  If not replace the async get method, default will call getPropertyNameCompletion: , PropertyName according to your keyPath last component.
 *
 *  @param keyPath  key path.
 *  @param block    completion block.
 */
- (void)duxbeta_getCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block;

/**
 *  Used to define a async KVO set method.
 *  Will store the completion until setting done.
 *
 *  @param value   setting value.
 *  @param block   completion block.
 *  @param keyPath key path.
 *
 *  @return a confirmation, you should accept the set action.
 */
- (nullable DUXBetaCustomValueConfirmation *)duxbeta_willSetCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueSetCompletionBlock)block;

/**
 *  The setting value of custom value.
 *
 *  @param keyPath key path
 *
 *  @return setting value, maybe nil.
 */
- (nullable id)duxbeta_settingCustomValueForKeyPath:(nonnull NSString *)keyPath;

/**
 *  Used to define a async KVO get method.
 *  Will store the completion until getting done.
 *
 *  @param block completion block.
 *  @return a confirmation, you should accept the get action.
 */
- (nullable DUXBetaCustomValueConfirmation *)duxbeta_willGetCustomValueForKeyPath:(nonnull NSString *)keyPath completion:(nullable DUXBetaCustomValueGetCompletionBlock)block;

/**
 *  Update value if not setting.
 *
 *  @param value   value
 *  @param keyPath key path
 */
- (void)duxbeta_updateCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath;

/**
 *  Check is setting.
 *
 *  @param keyPath key path.
 *
 *  @return is setting value with key path.
 */
- (BOOL)duxbeta_isSettingCustomValueForKeyPath:(nonnull NSString *)keyPath;

/**
 *  Check is already init.
 *  if value setting cause error, it will be unknown.
 *
 *  @param keyPath key path.
 *
 *  @return is already init.
 */
- (BOOL)duxbeta_isInitCustomValueForKeyPath:(nonnull NSString *)keyPath;

/**
 *  Force init custom value by hand.
 *
 *  @param value   init value
 *  @param keyPath keypath.
 */
- (void)duxbeta_initCustomValue:(nullable id)value forKeyPath:(nonnull NSString *)keyPath;

/**
 *  force deinit custom value by hand.
 *
 *  @param keyPath keypath.
 */
- (void)duxbeta_deinitCustomValueForKeyPath:(nonnull NSString *)keyPath;

@end



@interface NSObject (DUXBetaCustomAsyncKVOReplace)

//Used to replace default setting method.
- (void)duxbeta_replaceSetCustomValueBlock:(nonnull void(^)(id _Nullable value,DUXBetaCustomValueSetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath;
//Used to replace default getting method.
- (void)duxbeta_replaceGetCustomValueBlock:(nonnull void(^)(DUXBetaCustomValueGetCompletionBlock _Nullable completion))method forKeyPath:(nonnull NSString *)keyPath;

//Used to replace default setting method.
- (void)duxbeta_replaceSetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath;
//Used to replace default getting method.
- (void)duxbeta_replaceGetCustomValueMethod:(nonnull SEL)method forKeyPath:(nonnull NSString *)keyPath;

@end
