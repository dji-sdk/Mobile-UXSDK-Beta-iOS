//
//  DUXBetaAirSenseHtmlViewController.m
//  DJIUXSDKWidgets
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

#import "DUXBetaAirSenseHtmlViewController.h"
#import <WebKit/WebKit.h>
#import "DUXStateChangeBroadcaster.h"
#import "DUXBetaAirSenseWidgetUIState.h"

static NSInteger const DUXAirSenseHTMLBackButtonSideLength = 44;

@interface DUXBetaAirSenseHtmlViewController ()

@property (strong, nonatomic)WKWebView *htmlView;

@end

@implementation DUXBetaAirSenseHtmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupWebviewBounds];
    [super viewDidAppear:NO];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[DUXStateChangeBroadcaster instance] send:[DUXBetaAirSenseWidgetUIState termsDialogDismiss]];
}

- (void)setupWebviewBounds {
    CGPoint htmlFrameOrigin = CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y + DUXAirSenseHTMLBackButtonSideLength);
    CGSize htmlFrameSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - DUXAirSenseHTMLBackButtonSideLength);
    self.htmlView.frame = (CGRect) {
        .origin = htmlFrameOrigin,
        .size = htmlFrameSize
    };
}

- (void)setupView {
    NSString *localeID = [[NSLocale preferredLanguages] firstObject];
    NSDictionary *localeComponents = [NSLocale componentsFromLocaleIdentifier:localeID];
    NSString *language = localeComponents[NSLocaleLanguageCode];
    NSString *path;
    
    if ([language isEqualToString:@"zh"]) {
        path = [[NSBundle bundleForClass:[self class]] pathForResource:@"air_sense_terms_of_use_chinese"
                                                                          ofType:@"html"];
    } else {
        path = [[NSBundle bundleForClass:[self class]] pathForResource:@"air_sense_terms_of_use"
                                                                          ofType:@"html"];
    }
    
    NSString *html = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    self.htmlView = [[WKWebView alloc] init];
    self.htmlView.opaque = NO;
    
    [self.htmlView setBackgroundColor:[UIColor clearColor]];
    [self.htmlView loadHTMLString:[html description] baseURL:nil];

    //Offset htmlFrame to not overlap back button
    [self.view addSubview:self.htmlView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self addBackButton];
}

- (void)addBackButton {
    UIButton *backButton = [[UIButton alloc] init];
    CGRect backButtonFrame = CGRectMake(0, 0, DUXAirSenseHTMLBackButtonSideLength, DUXAirSenseHTMLBackButtonSideLength);
    backButton.frame = backButtonFrame;
    [backButton setTitle:@"<" forState:UIControlStateNormal];
    [backButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setBackgroundColor:[UIColor clearColor]];
    [backButton addTarget:self action:@selector(dismissTerms) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)dismissTerms {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
