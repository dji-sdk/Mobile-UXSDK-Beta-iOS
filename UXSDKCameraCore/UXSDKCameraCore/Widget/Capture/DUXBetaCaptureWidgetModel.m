//
//  DUXBetaCaptureWidgetModel.m
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

#import "DUXBetaCaptureWidgetModel.h"
#import "DUXBetaRecordVideoWidget.h"
#import "DUXBetaShootPhotoWidget.h"

@interface DUXBetaCaptureWidgetModel ()

@property (nonatomic, strong) DUXBetaFlatCameraModule *flatModule;
@property (nonatomic, assign, readwrite) DJICameraMode cameraMode;

@end

@implementation DUXBetaCaptureWidgetModel

- (instancetype)init {
    return [self initWithPreferredCameraIndex:0];
}

- (instancetype)initWithPreferredCameraIndex:(NSUInteger)preferredCameraIndex {
    self = [super init];
    
    if (self) {
        _cameraIndex = preferredCameraIndex;
        _flatModule = [DUXBetaFlatCameraModule new];
        
        [self addModule:_flatModule];
    }
    
    return self;
}

- (void)inSetup {
    BindRKVOModel(self, @selector(updateCameraMode), flatModule.currentCameraMode);
}

- (void)updateCameraMode {
    self.cameraMode = self.flatModule.currentCameraMode;
}

@end
