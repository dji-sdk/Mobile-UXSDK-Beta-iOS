//
//  DUXLiveStreamFacebookStartViewController.m
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

#import "DUXLiveStreamFacebookStartViewController.h"
#import "DUXLiveStreamFacebookMetadataViewController.h"
#import "DUXLiveStreamControlWidget.h"
#import <UXSDKCore/UIImage+DUXAssets.h>

@interface DUXLiveStreamFacebookStartViewController ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIView *loginButton;
@property (strong, nonatomic) UIView *avatarView;
@property (strong, nonatomic) NSString *tokenString;
@property (assign, nonatomic) BOOL startedLiveStreaming;
@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *goLiveButton;

@end

@implementation DUXLiveStreamFacebookStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startedLiveStreaming = NO;
    self.avatarView = self.context.avatarView;
    self.loginButton = self.context.loginButton;
    self.titleLabel = [[UILabel alloc] init];
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.goLiveButton = [UIButton buttonWithType:UIButtonTypeSystem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [self setupUI];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    self.avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.avatarView];
    [self.avatarView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.avatarView.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30.0].active = YES;
    [self.avatarView.heightAnchor constraintEqualToConstant:50].active = YES;
    [self.avatarView.widthAnchor constraintEqualToConstant:50].active = YES;

    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];
    [self.titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.titleLabel.topAnchor constraintEqualToAnchor:self.avatarView.bottomAnchor constant:15.0].active = YES;
    [self.titleLabel.widthAnchor constraintEqualToConstant:self.view.frame.size.width/1.5].active = YES;
    self.titleLabel.text = NSLocalizedString(@"Please Login to Start Live Broadcast", "Prompt to login for Live Streaming");
    
    self.goLiveButton.backgroundColor = [UIColor colorWithRed:66/255.0 green:103/255.0 blue:178/255.0 alpha:1.0];
    [self.goLiveButton setTitle:NSLocalizedString(@"Go Live", @"Title for button to start LiveStream") forState:UIControlStateNormal];
    [self.goLiveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.goLiveButton addTarget:self action:@selector(goLiveAction) forControlEvents:UIControlEventTouchUpInside];
    self.goLiveButton.layer.cornerRadius = 3.0;
    self.goLiveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.goLiveButton];
    [self.goLiveButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.goLiveButton.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.goLiveButton.heightAnchor constraintEqualToConstant:44.0].active = YES;
    [self.goLiveButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:30.0].active = YES;
    [self.goLiveButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30.0].active = YES;
    self.goLiveButton.hidden = self.tokenString != nil ? NO : YES;

    self.loginButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.loginButton];
    [self.loginButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.loginButton.topAnchor constraintEqualToAnchor:self.goLiveButton.bottomAnchor constant:20.0].active = YES;
    [self.loginButton.heightAnchor constraintEqualToConstant:44.0].active = YES;
    
    [self.closeButton setImage:[UIImage dux_imageWithAssetNamed:@"XButton" forClass:[self class]] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeViewController) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.closeButton];
    [self.closeButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:5.0].active = YES;
    [self.closeButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:5.0].active = YES;
    [self.closeButton.heightAnchor constraintEqualToConstant:20.0].active = YES;
    [self.closeButton.widthAnchor constraintEqualToConstant:20.0].active = YES;
}

- (void)updateUI {
    self.titleLabel.font = self.titleFont;
}

- (void)updateLoginStatusWithProfileName: (NSString *)profileName andTokenString: (NSString *)tokenString {
    self.goLiveButton.hidden = NO;
    self.titleLabel.text = profileName;
    self.tokenString = tokenString;
}

- (void)goLiveAction {
    [self.context.widgetModel startPageNeedsMetadata];
}

- (void)closeViewController {
    [self.parentViewController willMoveToParentViewController:nil];
    [self.parentViewController.view removeFromSuperview];
    [self.parentViewController removeFromParentViewController];
    [self.parentViewController didMoveToParentViewController:nil];
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    [self updateUI];
}

@end
