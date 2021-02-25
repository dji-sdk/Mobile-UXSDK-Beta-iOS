//
//  DUXLiveStreamFacebookContext.m
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

#import "DUXLiveStreamFacebookContext.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "DUXLiveStreamFacebookStartViewController.h"
#import "DUXLiveStreamFacebookMetadataViewController.h"

@interface DUXLiveStreamFacebookContext () <FBSDKLoginButtonDelegate>

@property DUXLiveStreamFacebookStartViewController *startViewController;
@property DUXLiveStreamFacebookMetadataViewController *metadataViewController;
@property (strong, nonatomic) FBSDKLoginButton *loginButton;
@property (strong, nonatomic) FBSDKProfilePictureView *avatarView;
@property (nonatomic, strong) NSString *id;

@end

@implementation DUXLiveStreamFacebookContext
@dynamic loginButton, avatarView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loginButton = [[FBSDKLoginButton alloc] init];
        self.loginButton.publishPermissions = @[@"publish_video", @"manage_pages", @"publish_pages"];
        self.loginButton.readPermissions = @[@"public_profile", @"user_posts", @"read_custom_friendlists", @"user_tagged_places"];
        self.loginButton.delegate = self;
        
        self.avatarView =  [[FBSDKProfilePictureView alloc] init];
        self.avatarView.pictureMode = FBSDKProfilePictureModeSquare;
        [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onProfileUpdated:) name:FBSDKProfileDidChangeNotification object:nil];
    }
    return self;
}

- (UIViewController *)getStartLiveStreamView {
    if (!self.startViewController) {
        self.startViewController = [[DUXLiveStreamFacebookStartViewController alloc] init];
        self.startViewController.context = self;
    }
    return self.startViewController;
}

- (UIViewController *)getMetadataEntryView {
    if (!self.metadataViewController) {
        self.metadataViewController = [[DUXLiveStreamFacebookMetadataViewController alloc] init];
        self.metadataViewController.context = self;
    }
    return self.metadataViewController;
}

- (void) startLiveStream {
    FBSDKAccessToken* token = [FBSDKAccessToken currentAccessToken];
    if (!token.tokenString) {
        return;
    }
    
    NSString* livePath =  [@"/" stringByAppendingPathComponent:[token.userID stringByAppendingPathComponent:@"live_videos"]];
    FBSDKProfile *profile = [FBSDKProfile currentProfile];
    
    if(profile.userID){
        livePath = [@"/" stringByAppendingPathComponent:[profile.userID stringByAppendingPathComponent:@"live_videos"]];
    }

    NSString *privacyParam = [NSString stringWithFormat: @"{\"value\" : \"%@\"}", self.metadataViewController.privacyOptionSelected];
    [[[FBSDKGraphRequest alloc] initWithGraphPath:livePath
                                       parameters:@{ @"privacy": privacyParam, @"description" : self.metadataViewController.descriptionTextField.text}
                                      tokenString:token.tokenString
                                          version:@"v2.6"
                                       HTTPMethod:@"POST"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         
         if (error == nil)
         {
             if (![result isKindOfClass:[NSDictionary class]]) {
                 assert(0);
                 return;
             }
             self.rtmpServerURL = result[@"secure_stream_url"];
             if (!self.rtmpServerURL) {
                 self.rtmpServerURL = result[@"stream_url"];
             }
             self.id = result[@"id"];
             [self.widgetModel startLiveStream];
         }
         else{
             NSString* errorString = error.description;
             if ([error.userInfo isKindOfClass:[NSDictionary class]]) {
                 errorString = error.userInfo[@"com.facebook.sdk:FBSDKErrorDeveloperMessageKey"];
             }
             return;
         }
     }];
}

- (void)stopLiveStream {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:self.id
                                  parameters:@{ @"end_live_video": @"true" }
                                  HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        NSLog(@"Stream Ended: %@", result);
    }];
    [self.widgetModel stopLiveStream];
}

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    [self updateLoginStatus];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self updateLoginStatus];
}

- (void)onProfileUpdated:(NSNotification*)notify{
    [self updateLoginStatus];
}

- (void)updateLoginStatus {
    FBSDKAccessToken* token = [FBSDKAccessToken currentAccessToken];
    FBSDKProfile *profile = [FBSDKProfile currentProfile];

    if (profile && token.tokenString) {
        self.avatarView.profileID = profile.userID;
        [self.startViewController updateLoginStatusWithProfileName:profile.name andTokenString:token.tokenString];
        [self.avatarView setNeedsImageUpdate];
    }
}

@end
