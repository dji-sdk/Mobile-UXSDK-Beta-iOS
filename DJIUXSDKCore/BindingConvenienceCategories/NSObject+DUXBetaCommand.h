//
//  NSObject+DUXBetaCommand.h
//  DJIUXSDK
//  
//  Copyright © 2018-2019 DJI. All rights reserved.
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
