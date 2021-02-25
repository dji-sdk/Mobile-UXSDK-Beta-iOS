//
//  DUXBetaCaptureBaseWidgetModel.m
//  UXSDKCameraCore
//
//  MIT License
//  
//  Copyright © 2018-2021 DJI
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

#import "DUXBetaCaptureBaseWidgetModel.h"

@interface DUXBetaCaptureBaseWidgetModel()

@property (nonatomic, strong) NSString *cameraDisplayName;
@property (nonatomic, assign, readwrite) BOOL isCameraConnected;
@property (nonatomic, strong, readwrite) DUXBetaStorageModule *storageModule;

@end


@implementation DUXBetaCaptureBaseWidgetModel

- (instancetype)init {
    return [self initWithPreferredCameraIndex:0];
}

- (instancetype)initWithPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    self = [super init];
    
    if (self) {
        _storageModule = [DUXBetaStorageModule new];
        _cameraIndex = preferredCameraIndex;
        
        [self addModule:self.storageModule];
    }
    
    return self;
}

/**
 * Override of parent inSetup method that binds properties to keys
 * and attaches method callbacks on properties updates.
 */
- (void)inSetup {
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJIParamConnection], isCameraConnected);
    BindSDKKey([DJICameraKey keyWithIndex:self.cameraIndex andParam:DJICameraParamDisplayName], cameraDisplayName);
}

/**
 * Override of parent inCleanup method that unbinds properties from keys
 * and detaches methods callbacks.
 */
- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

#pragma mark - Setters

- (void)setCameraIndex:(NSUInteger)preferredCameraIndex {
    [self inCleanup];
    _cameraIndex = preferredCameraIndex;
    [self inSetup];
}

#pragma mark - Helper Methods

@end
