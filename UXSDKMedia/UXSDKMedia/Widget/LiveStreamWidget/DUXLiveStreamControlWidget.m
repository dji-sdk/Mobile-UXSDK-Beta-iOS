//
//  DUXLiveStreamControlWidget.m
//  DJIUXSDK
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

#import "DUXLiveStreamControlWidget.h"
#import "DUXLiveStreamContext.h"
#import "DUXLiveStreamFacebookContext.h"
#import <UXSDKCore/UIImage+DUXAssets.h>

@interface DUXLiveStreamControlWidget ()

@property (nonatomic, strong) UIViewController *currentChildViewController;

@end

@implementation DUXLiveStreamControlWidget

+ (nonnull instancetype)liveStreamControlWidget{
    DUXLiveStreamControlWidget *liveStreamControlWidget = [[self alloc] init];
    return liveStreamControlWidget;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.widgetModel.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    UIViewController *startViewController = [self.widgetModel.context getStartLiveStreamView];
    [self addChildViewController:startViewController];
    [self.view addSubview:startViewController.view];
    self.currentChildViewController = startViewController;
}

- (CGFloat)preferredWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 360;
    } else {
        return 240;
    }
}

- (void)needsMetadataForStream {
    [self.currentChildViewController.view removeFromSuperview];
    [self.currentChildViewController removeFromParentViewController];
    self.currentChildViewController = [self.widgetModel.context getMetadataEntryView];
    [self addChildViewController:self.currentChildViewController];
    self.currentChildViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.currentChildViewController viewWillAppear:NO];
    [self.view addSubview:self.currentChildViewController.view];
    [self.currentChildViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.currentChildViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    [self.currentChildViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.currentChildViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
}

- (void)readyToStream {
    //
}

- (void)startedStreaming {
    //
}

- (void)stoppedStreaming {
    //
}

@end
