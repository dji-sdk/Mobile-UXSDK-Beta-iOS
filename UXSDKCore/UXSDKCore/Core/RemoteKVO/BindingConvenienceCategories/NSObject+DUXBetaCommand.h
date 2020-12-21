//
//  NSObject+DUXBetaCommand.h
//  UXSDKCore
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

#ifndef BindRKVOCommnad
#define BindRKVOCommnad(__TARGET__, __KEY__, __SELECTOR__) [self duxbeta_bindRKVOCommandWithTarget:__TARGET__ Key:__KEY__ selector:__SELECTOR__]
#endif


#ifndef PostRKVOCommand
#define PostRKVOCommand(__KEY__, __OBJECT__) [self duxbeta_postRKVOCommandWithKey:__KEY__ object:__OBJECT__]
#endif

#ifndef UnBindRKVOCommandForKey
#define UnBindRKVOCommandForKey(__TARGET__, __KEY__) [self duxbeta_unBindRKVOCommandWithTarget:__TARGET__ key:__KEY__]
#endif


#ifndef UnBindRKVOCommand
#define UnBindRKVOCommand(__TARGET__) [self duxbeta_unBindAllRKVOCommandWithTaget:__TARGET__]
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (DUXBetaCommand)

- (void)duxbeta_postRKVOCommandWithKey:(NSString *)key object:(id)object;
- (void)duxbeta_bindRKVOCommandWithTarget:(id)target Key:(NSString *)key selector:(SEL)selector;

- (void)duxbeta_unBindRKVOCommandWithTarget:(id)target key:(NSString *)key;
- (void)duxbeta_unBindAllRKVOCommandWithTaget:(id)target;

@end

NS_ASSUME_NONNULL_END
