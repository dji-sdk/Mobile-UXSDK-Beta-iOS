//
//  DUXBetaSingleton.m
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

#import "DUXBetaSingleton.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaSingleton ()

+ (nonnull instancetype)sharedSingleton;

@property (nonatomic, strong, nonnull, readonly) id <ObservableKeyedStore> observableInMemoryKeyedStore;
@property (nonatomic, strong, nonnull, readwrite) id <GlobalPreferences> globalPreferences;

@end

@implementation DUXBetaSingleton

+ (nonnull instancetype)sharedSingleton {
    static dispatch_once_t onceToken;
    static DUXBetaSingleton *_sharedSingleton;
    
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[DUXBetaSingleton alloc] init];
    });
    
    return _sharedSingleton;
}

- (nonnull instancetype)init {
    self = [super init];
    
    if (self) {
        _observableInMemoryKeyedStore = [[ObservableInMemoryKeyedStore alloc] init];
        _globalPreferences = [[DefaultGlobalPreferences alloc] init];
    }
    
    return self;
}

+ (id <ObservableKeyedStore>)sharedObservableInMemoryKeyedStore {
    return [[self sharedSingleton] observableInMemoryKeyedStore];
}

+ (id <GlobalPreferences>)sharedGlobalPreferences {
    return [[self sharedSingleton] globalPreferences];
}

+ (void)setSharedGlobalPreferences:(id <GlobalPreferences>)sharedGlobalPreferences {
    [[self sharedSingleton] setGlobalPreferences:sharedGlobalPreferences];
}

@end
