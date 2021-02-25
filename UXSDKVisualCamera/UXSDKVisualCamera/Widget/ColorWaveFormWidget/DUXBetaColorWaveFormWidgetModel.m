//
//  DUXBetaColorWaveFormWidgetModel.m
//  UXSDKVisualCamera
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

#import "DUXBetaColorWaveFormWidgetModel.h"
#import <UXSDKCore/UXSDKCore-Swift.h>

@interface DUXBetaColorWaveFormWidgetModel ()

@property (strong, nonatomic, readwrite) DJIMovieGLView *internalGLView;

@property (strong, nonatomic, readwrite) UIView *renderedColorWaveFormView;

@property (strong, nonatomic, readwrite) DJIVideoPreviewer *previewer;

@property (strong, nonatomic, readwrite) NSString *productName;

@property (assign, nonatomic, readwrite) BOOL colorWaveFormSupported;

@end

@implementation DUXBetaColorWaveFormWidgetModel

- (instancetype)initWithVideoPreviewer:(DJIVideoPreviewer *)previewer {
    self = [super init];
    if (self) {
        _previewer = previewer;
        _displayMode = DJILiveViewColorMonitorDisplayTypeCombine;
        _productName = DJIAircraftModelNameUnknownAircraft;
        _colorWaveFormSupported = NO;
    }
    
    return self;
}

- (void)inSetup {
    DJIVideoPreviewer* preview = self.previewer;
    weakSelf(target);
    [preview duxbeta_addCustomObserver:self forKeyPath:@RKVOKeypath(preview.internalGLView) block:^(id  _Nullable oldValue, id  _Nullable newValue) {
        [target enableColorMonitor];
        target.internalGLView = preview.internalGLView;
    }];
    
    [preview duxbeta_addCustomObserver:self forKeyPath:@RKVOKeypath(preview.internalGLView.colorMonitor.renderedColorWaveFormView) block:^(id  _Nullable oldValue, id  _Nullable newValue) {
        [target setMonitorContent];
        target.renderedColorWaveFormView = preview.internalGLView.colorMonitor.renderedColorWaveFormView;
    }];
    
    BindSDKKey([DJIProductKey keyWithParam:DJIProductParamModelName], productName);
    BindRKVOModel(self, @selector(productNameChanged),productName);
    
    [self enableColorMonitor];
    [self setMonitorContent];
}

- (void)inCleanup {
    UnBindSDK;
    UnBindRKVOModel(self);
}

- (void)enableColorMonitor {
    self.previewer.internalGLView.enableColorMonitor = YES;
}

- (void)productNameChanged {
    self.colorWaveFormSupported = [self checkProductSupportsColorWaveForm];
}

- (BOOL)checkProductSupportsColorWaveForm {
    return [ProductUtil isColorWaveFormSupportedProduct];
}

- (BOOL)colorWaveFormSupported {
#if TARGET_OS_SIMULATOR
    return NO;
#else
    return [self checkProductSupportsColorWaveForm];
#endif
}

- (void)setMonitorContent {
    self.previewer.internalGLView.colorMonitor.renderMode = DJILiveViewColorMonitorRenderModeLines;
    self.previewer.internalGLView.colorMonitor.displayType = self.displayMode;
    self.previewer.internalGLView.colorMonitor.intensity = 5.0;    
}

- (void)setDisplayMode:(DJILiveViewColorMonitorDisplayType)displayMode {
    _displayMode = displayMode;
    if (self.previewer.internalGLView.colorMonitor) {
        self.previewer.internalGLView.colorMonitor.displayType = self.displayMode;
    }
}

@end
