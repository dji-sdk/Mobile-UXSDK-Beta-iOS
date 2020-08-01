//
//  DUXBetaRTKSatelliteStatusWidget.m
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

#import "DUXBetaRTKSatelliteStatusWidget.h"
#import "DUXBetaRTKSatelliteStatusWidgetModel.h"
#import "UIImage+DUXBetaAssets.h"
#import "UIFont+DUXBetaFonts.h"
@import DJIUXSDKCore;
#import <DJIUXSDKWidgets/DUXBetaPanelWidgetSupport.h>
#import <DJIUXSDKWidgets/NSLayoutConstraint+DUXBetaMultiplier.h>

static CGSize const kDesignSize = {500.0, 500.0};
static NSString *const kConnectionStatusTitleEnding = @" Status: ";

static const float kMarginForTitles = 15.0;
static const float kMarginThin = 10.0;
static const float kTableLineWidth = 1.0;
static const float kDefaultFontSize = 12.0;

@interface DUXBetaRTKSatelliteStatusWidget () <DUXBetaToolbarPanelSupportProtocol>

@property (strong, nonatomic) UILabel *statusTitleLabel;
@property (strong, nonatomic) UILabel *statusLabel;

@property (strong, nonatomic) UIView *tableBorderView;
@property (strong, nonatomic) UIView *verticalDivider1;
@property (strong, nonatomic) UIView *verticalDivider2;
@property (strong, nonatomic) UIView *horizontalDivider1;
@property (strong, nonatomic) UIView *horizontalDivider2;
@property (strong, nonatomic) UIView *horizontalDivider3;
@property (strong, nonatomic) UIView *horizontalDivider4;

@property (strong, nonatomic) UILabel *aircraftColumnLabel;
@property (strong, nonatomic) UILabel *baseStationColumnLabel;

@property (strong, nonatomic) UILabel *orientationRowLabel;
@property (strong, nonatomic) UILabel *positioningRowLabel;

@property (strong, nonatomic) UILabel *aircraftOrientationLabel;

@property (strong, nonatomic) UIImage *aircraftHeadingValidImage;
@property (strong, nonatomic) UIImage *aircraftHeadingInvalidImage;

@property (strong, nonatomic) UILabel *aircraftPositioningLabel;

@property (strong, nonatomic) UILabel *latitudeTitleLabel;
@property (strong, nonatomic) UILabel *longitudeTitleLabel;
@property (strong, nonatomic) UILabel *altitudeTitleLabel;
@property (strong, nonatomic) UILabel *courseAngleTitleLabel;

@property (strong, nonatomic) UILabel *aircraftLatitudeLabel;
@property (strong, nonatomic) UILabel *aircraftLongitudeLabel;
@property (strong, nonatomic) UILabel *aircraftAltitudeLabel;
@property (strong, nonatomic) UILabel *aircraftCourseAngleLabel;

@property (strong, nonatomic) UILabel *baseStationLatitudeLabel;
@property (strong, nonatomic) UILabel *baseStationLongitudeLabel;
@property (strong, nonatomic) UILabel *baseStationAltitudeLabel;

@property (strong, nonatomic) UILabel *gpsTitleLabel;
@property (strong, nonatomic) UILabel *beidouTitleLabel;
@property (strong, nonatomic) UILabel *glonassTitleLabel;
@property (strong, nonatomic) UILabel *galileoTitleLabel;

@property (strong, nonatomic) UILabel *antenna1TitleLabel;
@property (strong, nonatomic) UILabel *antenna1GPSCountLabel;
@property (strong, nonatomic) UILabel *antenna1BeidouCountLabel;
@property (strong, nonatomic) UILabel *antenna1GlonassCountLabel;
@property (strong, nonatomic) UILabel *antenna1GalileoCountLabel;

@property (strong, nonatomic) UILabel *antenna2TitleLabel;
@property (strong, nonatomic) UILabel *antenna2GPSCountLabel;
@property (strong, nonatomic) UILabel *antenna2BeidouCountLabel;
@property (strong, nonatomic) UILabel *antenna2GlonassCountLabel;
@property (strong, nonatomic) UILabel *antenna2GalileoCountLabel;

@property (strong, nonatomic) UILabel *baseStationGPSCountLabel;
@property (strong, nonatomic) UILabel *baseStationBeidouCountLabel;
@property (strong, nonatomic) UILabel *baseStationGlonassCountLabel;
@property (strong, nonatomic) UILabel *baseStationGalileoCountLabel;

@property (strong, nonatomic) UILabel *standardDeviationTitleLabel;

@property (strong, nonatomic) UILabel *latitudeStandardDeviationLabel;
@property (strong, nonatomic) UILabel *longitudeStandardDeviationLabel;
@property (strong, nonatomic) UILabel *altitudeStandardDeviationLabel;

@property (strong, nonatomic) NSLayoutConstraint *row4ConstraintToRow5;
@property (strong, nonatomic) NSLayoutConstraint *row4ConstraintToBorder;
@property (strong, nonatomic) NSLayoutConstraint *row5ConstraintToBorder;

@property (strong, nonatomic) NSLayoutConstraint *antennaRowTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *row2ToRow3Constraint;

@property (strong, nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *statusLabelColors;

@property (strong, nonatomic) UIImageView *aircraftOrientationImageView;

@property (strong, nonatomic) UIStackView *standardDeviationStackView;

@property (strong, nonatomic) NSMutableArray *titleLabels;
@property (strong, nonatomic) NSMutableArray *valueLabels;
@property (assign, nonatomic) uint8_t visibleConstellationCount;

@property (strong, nonatomic) NSMutableSet *countStackViewTopConstraints;

@end


/**
 * RTKSatelliteStatusWidgetModelState contains the model hooks for the DUXBetaRTKSatelliteStatusWidget.
 * It implements the hooks:
 *
 * Key: productConnected         Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                        the device when it changes.
 *
 * Key: rtkConnectedUpdate       Type: NSNumber - Sends a boolean value as an NSNumber indicating if the current device
 *                                          supports RTK.
 * Key: rtkStateUpdate           Type: DJIRTKState - Sends a DJIRTKState when received from the widget model.
 * Key: modelUpdate              Type: NSString - Sends the model name of the product when updated.
 * Key: rtkSignalUpdate          Type: DJIRTKReferenceStationSource - Sends the type of base station reference source used.
 * Key: standardDeviationUpdate  Type: DJILocationStandardDeviation - Sends the standard deviation of the aircraft's location when updated.
 * Key: baseStationStatusUpdate  Type: DUXBetaRTKConnectionStatus - Sends the status of the base station when updated.
 * Key: rtkNetRTCMStatusUpdate   Type: DJIRTKNetworkServiceState - Sends the RTK network service state when updated.
*/
@interface RTKSatelliteStatusWidgetModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

+ (instancetype)rtkConnectedUpdate:(BOOL)isConnected;

+ (instancetype)rtkStateUpdate:(DJIRTKState *)rtkState;

+ (instancetype)modelUpdate:(NSString *)modelName;

+ (instancetype)rtkSignalUpdate:(DJIRTKReferenceStationSource)rtkSignal;

+ (instancetype)standardDeviationUpdate:(DJILocationStandardDeviation *)locationStandardDeviation;

+ (instancetype)baseStationStatusUpdate:(DUXBetaRTKConnectionStatus)connectionStatus;

+ (instancetype)rtkNetRTCMStatusUpdate:(DJIRTKNetworkServiceState *)networkServiceState;


@end

@implementation DUXBetaRTKSatelliteStatusWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleLabelTextColor = [UIColor duxbeta_whiteColor];
        _titleLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _titleLabelBackgroundColor = [UIColor duxbeta_clearColor];
        _valueLabelTextColor = [UIColor duxbeta_whiteColor];
        _valueLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _valueLabelBackgroundColor = [UIColor duxbeta_clearColor];
        
        _statusTitleLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _statusTitleLabelTextColor = [UIColor duxbeta_whiteColor];
        _statusTitleLabelBackgroundColor = [UIColor duxbeta_clearColor];
        
        _statusLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _statusLabelBackgroundColor = [UIColor duxbeta_clearColor];
        
        _isBeidouCountVisible = YES;
        _isGlonassCountVisible = YES;
        _isGalileoCountVisible = YES;
        
        _visibleConstellationCount = 4;
        
        _aircraftHeadingValidImage = [UIImage duxbeta_imageWithAssetNamed:@"OrientationValid"];
        _aircraftHeadingInvalidImage = [UIImage duxbeta_imageWithAssetNamed:@"OrientationInvalid"];

        _statusLabelColors = [[NSMutableDictionary alloc] initWithDictionary:@{
            @(DUXBetaRTKConnectionStatusInUse) : [UIColor duxbeta_systemStatusWidgetGreenColor],
            @(DUXBetaRTKConnectionStatusNotInUse) : [UIColor duxbeta_yellowColor],
            @(DUXBetaRTKConnectionStatusDisconnected) : [UIColor duxbeta_systemStatusWidgetRedColor]
        }];
        
        _tableColor = [UIColor duxbeta_rtkTableBorderColor];
        _countStackViewTopConstraints = [[NSMutableSet alloc] init];
        _backgroundColor = [UIColor duxbeta_clearColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgetModel = [[DUXBetaRTKSatelliteStatusWidgetModel alloc] init];
    [self.widgetModel setup];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Update Values
    BindRKVOModel(self.widgetModel, @selector(updateConnectionStatus), isProductConnected, rtkEnabled, rtkInUse, networkServiceState.channelState, rtkConnectionStatus);
    BindRKVOModel(self.widgetModel, @selector(updatePrecisionValues), modelName, isHeadingValid, locationState, rtkState);
    BindRKVOModel(self.widgetModel, @selector(updateLocationAndCountValues), rtkState, modelName);
    BindRKVOModel(self.widgetModel, @selector(updateReferenceStationSource), rtkSignal);
    BindRKVOModel(self.widgetModel, @selector(updateFieldVisibilities), modelName, isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(updateStandardDeviations), rtkState.mobileStationStandardDeviation);
    
    // Update Customizations
    BindRKVOModel(self, @selector(customizeConnectionStatus), statusTitleLabelFont, statusTitleLabelTextColor, statusTitleLabelBackgroundColor);
    BindRKVOModel(self, @selector(updatePrecisionValues), orientationValidImage, orientationInvalidImage, orientationValidTint, orientationInvalidTint);
    BindRKVOModel(self, @selector(customizeTitles), titleLabelFont, titleLabelTextColor, titleLabelBackgroundColor);
    BindRKVOModel(self, @selector(customizeValues), valueLabelFont, valueLabelTextColor, valueLabelBackgroundColor);
    BindRKVOModel(self, @selector(customizeBackground), tableColor, backgroundColor);
    BindRKVOModel(self, @selector(updateFieldVisibilities), isBeidouCountVisible, isGlonassCountVisible, isGalileoCountVisible);
    
    // Send Hooks
    BindRKVOModel(self.widgetModel, @selector(sendIsProductConnected), isProductConnected);
    BindRKVOModel(self.widgetModel, @selector(sendRTKConnectedUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKStateUpdate), rtkState);
    BindRKVOModel(self.widgetModel, @selector(sendModelUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKSignalUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKStandardDeviationUpdate), rtkState.mobileStationStandardDeviation);
    BindRKVOModel(self.widgetModel, @selector(sendBaseStationStatusUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendNetRTCMStatusUpdate), rtkSupported);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UnBindRKVOModel(self.widgetModel);
}

- (void)dealloc {
    [self.widgetModel cleanup];
}

- (void)setupUI {
    // Setup Elements Above Table:
    self.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view.widthAnchor constraintEqualToConstant:kDesignSize.width].active = YES;
    
    self.view.backgroundColor = [UIColor duxbeta_blackColor];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

    NSString *connectionStatus = [[self stringForReferenceStationSource:self.widgetModel.rtkSignal] stringByAppendingString:kConnectionStatusTitleEnding];
    self.statusTitleLabel = [self tableLabelWithTitle:connectionStatus textColor:[UIColor duxbeta_whiteColor] andFont:[UIFont systemFontOfSize:kDefaultFontSize]];

    [self.view addSubview:self.statusTitleLabel];
    
    [self.statusTitleLabel.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:kMarginForTitles].active = YES;
    [self.statusTitleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMarginThin].active = YES;
    [self.statusTitleLabel.heightAnchor constraintEqualToConstant:20.0].active = YES;
    
    UIColor *statusInitialColor = [self.statusLabelColors objectForKey:@(DUXBetaRTKConnectionStatusDisconnected)];
    self.statusLabel = [self tableLabelWithTitle:@"Disconnected" textColor:statusInitialColor andFont:[UIFont systemFontOfSize:kDefaultFontSize]];
    [self.view addSubview:self.statusLabel];
    
    [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.statusTitleLabel.centerYAnchor].active = YES;
    [self.statusLabel.leftAnchor constraintEqualToAnchor:self.statusTitleLabel.rightAnchor].active = YES;
    [self.statusLabel.heightAnchor constraintEqualToAnchor:self.statusTitleLabel.heightAnchor].active = YES;
    
    // Setup RTK Satellite Status Table
    self.tableBorderView = [[UIView alloc] init];
    self.tableBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableBorderView.layer.borderWidth = kTableLineWidth;
    self.tableBorderView.layer.cornerRadius = 15.0;
    [self.view addSubview:self.tableBorderView];

    [self.tableBorderView.leftAnchor constraintEqualToAnchor:self.view.leftAnchor constant:kMarginForTitles].active = YES;
    [self.tableBorderView.rightAnchor constraintEqualToAnchor:self.view.rightAnchor constant:-kMarginForTitles].active = YES;
    [self.tableBorderView.topAnchor constraintEqualToAnchor:self.statusTitleLabel.bottomAnchor constant:kMarginThin].active = YES;
    [self.tableBorderView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    UILayoutGuide *column1Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column1Guide];
    [column1Guide.widthAnchor constraintEqualToAnchor:self.tableBorderView.widthAnchor multiplier:0.25].active = YES;
    [column1Guide.leftAnchor constraintEqualToAnchor:self.tableBorderView.leftAnchor].active = YES;
    
    UILayoutGuide *column2Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column2Guide];
    [column2Guide.leftAnchor constraintEqualToAnchor:column1Guide.rightAnchor].active = YES;
    
    UILayoutGuide *column3Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column3Guide];
    [column3Guide.leftAnchor constraintEqualToAnchor:column2Guide.rightAnchor].active = YES;
    [column3Guide.rightAnchor constraintEqualToAnchor:self.tableBorderView.rightAnchor].active = YES;
    [column3Guide.widthAnchor constraintEqualToAnchor:column2Guide.widthAnchor].active = YES;
    
    UILayoutGuide *row1Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row1Guide];
    [row1Guide.topAnchor constraintEqualToAnchor:self.tableBorderView.topAnchor].active = YES;
    [row1Guide.heightAnchor constraintEqualToConstant:30.0].active = YES;
    
    UILayoutGuide *row2Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row2Guide];
    [row2Guide.topAnchor constraintEqualToAnchor:row1Guide.bottomAnchor].active = YES;
    
    UILayoutGuide *row3Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row3Guide];
    [row3Guide.topAnchor constraintEqualToAnchor:row2Guide.bottomAnchor].active = YES;
    
    // The antenna row guide sits between rows 3 and 4 of the table.
    // It shows the titles Antenna 1 and Antenna 2 and is dynamically hidden when the drone has one rtk antenna.
    UILayoutGuide *antennaLabelRowGuide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:antennaLabelRowGuide];
    self.antennaRowTopConstraint = [antennaLabelRowGuide.topAnchor constraintEqualToAnchor:row3Guide.bottomAnchor];
    self.antennaRowTopConstraint.active = YES;
    [antennaLabelRowGuide.heightAnchor constraintEqualToAnchor:row1Guide.heightAnchor multiplier:1].active = YES;
    
    
    UILayoutGuide *row4Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row4Guide];
    [row4Guide.topAnchor constraintEqualToAnchor:antennaLabelRowGuide.bottomAnchor].active = YES;
    self.row2ToRow3Constraint = [row4Guide.topAnchor constraintEqualToAnchor:row3Guide.bottomAnchor];
    self.row2ToRow3Constraint.active = NO;
    
    self.row4ConstraintToBorder = [row4Guide.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor];
    self.row4ConstraintToBorder.active = NO;
    
    UILayoutGuide *row5Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row5Guide];
    
    self.row4ConstraintToRow5 = [row5Guide.topAnchor constraintEqualToAnchor:row4Guide.bottomAnchor];
    self.row4ConstraintToRow5.active = YES;
    
    self.row5ConstraintToBorder = [row5Guide.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor];
    self.row5ConstraintToBorder.active = YES;
        
    self.horizontalDivider1 = [self createDivider];
    [self.horizontalDivider1.leftAnchor constraintEqualToAnchor:self.tableBorderView.leftAnchor].active = YES;
    [self.horizontalDivider1.heightAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.horizontalDivider1.rightAnchor constraintEqualToAnchor:self.tableBorderView.rightAnchor].active = YES;
    [self.horizontalDivider1.centerYAnchor constraintEqualToAnchor:row1Guide.bottomAnchor].active = YES;
    
    self.horizontalDivider2 = [self createDivider];
    [self.horizontalDivider2.leadingAnchor constraintEqualToAnchor:self.tableBorderView.leadingAnchor].active = YES;
    [self.horizontalDivider2.heightAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.horizontalDivider2.trailingAnchor constraintEqualToAnchor:self.tableBorderView.trailingAnchor].active = YES;
    [self.horizontalDivider2.centerYAnchor constraintEqualToAnchor:row2Guide.bottomAnchor].active = YES;
    
    self.horizontalDivider3 = [self createDivider];
    [self.horizontalDivider3.leadingAnchor constraintEqualToAnchor:self.tableBorderView.leadingAnchor].active = YES;
    [self.horizontalDivider3.heightAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.horizontalDivider3.trailingAnchor constraintEqualToAnchor:self.tableBorderView.trailingAnchor].active = YES;
    [self.horizontalDivider3.centerYAnchor constraintEqualToAnchor:row3Guide.bottomAnchor].active = YES;
    
    self.horizontalDivider4 = [self createDivider];
    [self.horizontalDivider4.leadingAnchor constraintEqualToAnchor:self.tableBorderView.leadingAnchor].active = YES;
    [self.horizontalDivider4.heightAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.horizontalDivider4.trailingAnchor constraintEqualToAnchor:self.tableBorderView.trailingAnchor].active = YES;
    [self.horizontalDivider4.centerYAnchor constraintEqualToAnchor:row4Guide.bottomAnchor].active = YES;
    
    self.verticalDivider1 = [self createDivider];
    [self.verticalDivider1.topAnchor constraintEqualToAnchor:self.tableBorderView.topAnchor].active = YES;
    [self.verticalDivider1.widthAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.verticalDivider1.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor].active = YES;
    [self.verticalDivider1.centerXAnchor constraintEqualToAnchor:column1Guide.rightAnchor].active = YES;
    
    self.verticalDivider2 = [self createDivider];
    [self.verticalDivider2.topAnchor constraintEqualToAnchor:self.tableBorderView.topAnchor].active = YES;
    [self.verticalDivider2.widthAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.verticalDivider2.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor].active = YES;
    [self.verticalDivider2.centerXAnchor constraintEqualToAnchor:column2Guide.rightAnchor].active = YES;
    
    self.aircraftColumnLabel = [self titleLabelWithTitle:@"Aircraft"];
    [self.view addSubview:self.aircraftColumnLabel];
    [self.aircraftColumnLabel.leftAnchor constraintEqualToAnchor:column1Guide.rightAnchor constant:kMarginForTitles].active = YES;
    [self.aircraftColumnLabel.rightAnchor constraintEqualToAnchor:column2Guide.rightAnchor constant:-kMarginForTitles].active = YES;
    [self.aircraftColumnLabel.centerYAnchor constraintEqualToAnchor:row1Guide.centerYAnchor].active = YES;
    
    self.baseStationColumnLabel = [self titleLabelWithTitle:@"Base Station"];
    [self.view addSubview:self.baseStationColumnLabel];
    [self.baseStationColumnLabel.leftAnchor constraintEqualToAnchor:column2Guide.rightAnchor constant:kMarginForTitles].active = YES;
    [self.baseStationColumnLabel.rightAnchor constraintEqualToAnchor:column3Guide.rightAnchor constant:-kMarginForTitles].active = YES;
    [self.baseStationColumnLabel.centerYAnchor constraintEqualToAnchor:row1Guide.centerYAnchor].active = YES;
    
    UIStackView *precisionTitlesStackView = [self stackViewWithRowGuide:row2Guide columnGuide:column1Guide];
    
    self.orientationRowLabel = [self titleLabelWithTitle:@"Orientation:"];
    self.positioningRowLabel = [self titleLabelWithTitle:@"Positioning:"];
    
    [precisionTitlesStackView addArrangedSubview:self.orientationRowLabel];
    [precisionTitlesStackView addArrangedSubview:self.positioningRowLabel];
    
    UIStackView *locationTitlesStackView = [self stackViewWithRowGuide:row3Guide columnGuide:column1Guide];
    
    self.latitudeTitleLabel = [self titleLabelWithTitle:@"Latitude:"];
    self.longitudeTitleLabel = [self titleLabelWithTitle:@"Longitude:"];
    self.altitudeTitleLabel = [self titleLabelWithTitle:@"Altitude:"];
    self.courseAngleTitleLabel = [self titleLabelWithTitle:@"Course Angle:"];

    [locationTitlesStackView addArrangedSubview:self.latitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.longitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.altitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.courseAngleTitleLabel];
    
    self.antenna1TitleLabel = [self titleLabelWithTitle:@"Antenna 1"];
    self.antenna2TitleLabel = [self titleLabelWithTitle:@"Antenna 2"];
    [self.view addSubview:self.antenna1TitleLabel];
    [self.view addSubview:self.antenna2TitleLabel];

    [self.antenna1TitleLabel.widthAnchor constraintEqualToAnchor:self.antenna2TitleLabel.widthAnchor].active = YES;
    [self.antenna1TitleLabel.leftAnchor constraintEqualToAnchor:column2Guide.leftAnchor constant:kMarginForTitles].active = YES;
    [self.antenna1TitleLabel.rightAnchor constraintEqualToAnchor:self.antenna2TitleLabel.leftAnchor constant:-kMarginForTitles].active = YES;
    [self.antenna2TitleLabel.rightAnchor constraintEqualToAnchor:column2Guide.rightAnchor constant:-kMarginForTitles].active = YES;
    [self.antenna1TitleLabel.centerYAnchor constraintEqualToAnchor:antennaLabelRowGuide.centerYAnchor].active = YES;
    [self.antenna2TitleLabel.centerYAnchor constraintEqualToAnchor:antennaLabelRowGuide.centerYAnchor].active = YES;
    
    UIStackView *antenna1StackView = [self countStackViewWithRowGuide:row4Guide columnGuide:nil];
    [antenna1StackView.leftAnchor constraintEqualToAnchor:column2Guide.leftAnchor constant:kMarginForTitles].active = YES;
    
    self.antenna1GPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1BeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1GlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1GalileoCountLabel = [self valueLabelWithTitle:@"N/A"];
    
    [antenna1StackView addArrangedSubview:self.antenna1GPSCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1BeidouCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1GlonassCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1GalileoCountLabel];
    
    UIStackView *antenna2StackView = [self countStackViewWithRowGuide:row4Guide columnGuide:nil];

    [antenna2StackView.leftAnchor constraintEqualToAnchor:antenna1StackView.rightAnchor constant:kMarginForTitles].active = YES;
    [antenna2StackView.rightAnchor constraintEqualToAnchor:column2Guide.rightAnchor constant:-kMarginForTitles].active = YES;
    [antenna2StackView.widthAnchor constraintEqualToAnchor:antenna1StackView.widthAnchor].active = YES;
    
    
    self.antenna2GPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2BeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2GlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2GalileoCountLabel = [self valueLabelWithTitle:@"N/A"];

    [antenna2StackView addArrangedSubview:self.antenna2GPSCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2BeidouCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2GlonassCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2GalileoCountLabel];
    
    UIStackView *constellationNameStackView = [self countStackViewWithRowGuide:row4Guide columnGuide:column1Guide];
    
    self.gpsTitleLabel = [self titleLabelWithTitle:@"GPS:"];
    self.beidouTitleLabel = [self titleLabelWithTitle:@"BeiDou:"];
    self.glonassTitleLabel = [self titleLabelWithTitle:@"GLONASS:"];
    self.galileoTitleLabel = [self titleLabelWithTitle:@"Galileo:"];
    [constellationNameStackView addArrangedSubview:self.gpsTitleLabel];
    [constellationNameStackView addArrangedSubview:self.beidouTitleLabel];
    [constellationNameStackView addArrangedSubview:self.glonassTitleLabel];
    [constellationNameStackView addArrangedSubview:self.galileoTitleLabel];
    
    UIStackView *aircraftPrecisionStackView = [self stackViewWithRowGuide:row2Guide columnGuide:column2Guide];
    self.aircraftOrientationLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftOrientationImageView = [[UIImageView alloc] initWithImage:self.orientationInvalidImage];
    self.aircraftPositioningLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftOrientationLabel.hidden = YES;
    self.aircraftOrientationImageView.hidden = YES;
    
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftOrientationLabel];
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftOrientationImageView];
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftPositioningLabel];
    
    UIStackView *aircraftLocationStackView = [self stackViewWithRowGuide:row3Guide columnGuide:column2Guide];
    self.aircraftLatitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftLongitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftAltitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftCourseAngleLabel = [self valueLabelWithTitle:@"N/A"];
    [aircraftLocationStackView addArrangedSubview:self.aircraftLatitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftLongitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftAltitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftCourseAngleLabel];
    
    UIStackView *baseStationLocationStackView = [self stackViewWithRowGuide:nil columnGuide:column3Guide];
    [baseStationLocationStackView.topAnchor constraintEqualToAnchor:row3Guide.topAnchor constant:kMarginForTitles].active = YES;
    
    self.baseStationLatitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationLongitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationAltitudeLabel = [self valueLabelWithTitle:@"N/A"];
    [baseStationLocationStackView addArrangedSubview:self.baseStationLatitudeLabel];
    [baseStationLocationStackView addArrangedSubview:self.baseStationLongitudeLabel];
    [baseStationLocationStackView addArrangedSubview:self.baseStationAltitudeLabel];
    
    UIStackView *baseStationCountStackView = [self countStackViewWithRowGuide:row4Guide columnGuide:column3Guide];
    self.baseStationGPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationBeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationGlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationGalileoCountLabel = [self valueLabelWithTitle:@"N/A"];
    [baseStationCountStackView addArrangedSubview:self.baseStationGPSCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationBeidouCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationGlonassCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationGalileoCountLabel];
    
    self.standardDeviationTitleLabel = [self titleLabelWithTitle:@"Standard Deviation:"];
    self.standardDeviationTitleLabel.numberOfLines = 2;
    [self.view addSubview:self.standardDeviationTitleLabel];
    [self.standardDeviationTitleLabel.topAnchor constraintEqualToAnchor:row5Guide.topAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationTitleLabel.leftAnchor constraintEqualToAnchor:column1Guide.leftAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationTitleLabel.rightAnchor constraintEqualToAnchor:column1Guide.rightAnchor constant:-kMarginForTitles].active = YES;
    
    self.standardDeviationStackView = [self stackViewWithRowGuide:nil columnGuide:column2Guide];
    [self.standardDeviationStackView.topAnchor constraintEqualToAnchor:row5Guide.topAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationStackView.bottomAnchor constraintEqualToAnchor:row5Guide.bottomAnchor constant:-kMarginForTitles].active = YES;
    self.latitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];
    self.longitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];
    self.altitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];
    [self.standardDeviationStackView addArrangedSubview:self.latitudeStandardDeviationLabel];
    [self.standardDeviationStackView addArrangedSubview:self.longitudeStandardDeviationLabel];
    [self.standardDeviationStackView addArrangedSubview:self.altitudeStandardDeviationLabel];
}

// Helper method to create divider
- (UIView *)createDivider {
    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor duxbeta_grayColor];
    [self.view addSubview:divider];
    return divider;
}

// Helper method to create a title label
- (UILabel *)titleLabelWithTitle:(NSString *)labelTitle  {
    if (self.titleLabels == nil) {
        self.titleLabels = [[NSMutableArray alloc] init];
    }
    UILabel *titleLabel = [self tableLabelWithTitle:labelTitle textColor:self.titleLabelTextColor andFont:self.titleLabelFont];
    [self.titleLabels addObject:titleLabel];
    return titleLabel;
}

// Helper method to create a value label
- (UILabel *)valueLabelWithTitle:(NSString *)labelTitle  {
    if (self.valueLabels == nil) {
        self.valueLabels = [[NSMutableArray alloc] init];
    }
    UILabel *valueLabel = [self tableLabelWithTitle:labelTitle textColor:self.valueLabelTextColor andFont:self.valueLabelFont];
    valueLabel.opaque = NO;
    [self.valueLabels addObject:valueLabel];
    return valueLabel;
}

// Helper method to create a label for the rtk satellite status table
- (UILabel *)tableLabelWithTitle:(NSString *)labelTitle textColor:(UIColor *)textColor andFont:(UIFont *)font {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor duxbeta_whiteColor];
    titleLabel.font = self.titleLabelFont;
    titleLabel.text = NSLocalizedString(labelTitle, @"Table Label Title");
    return titleLabel;
}

// Helper method to create a stack view constrained by the layout guides.
// Pass nil to layout guide to avoid constraining that dimension.
- (UIStackView *)stackViewWithRowGuide:(UILayoutGuide *)rowGuide columnGuide:(UILayoutGuide *)columnGuide {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing = kMarginThin;
    [self.view addSubview:stackView];
    if (rowGuide != nil) {
        [stackView.topAnchor constraintEqualToAnchor:rowGuide.topAnchor constant:kMarginForTitles].active = YES;
        [stackView.bottomAnchor constraintEqualToAnchor:rowGuide.bottomAnchor constant:-kMarginForTitles].active = YES;
    }
    if (columnGuide != nil) {
        [stackView.leftAnchor constraintEqualToAnchor:columnGuide.leftAnchor constant:kMarginForTitles].active = YES;
        [stackView.rightAnchor constraintEqualToAnchor:columnGuide.rightAnchor constant:-kMarginForTitles].active = YES;
    }
    return stackView;
}

- (UIStackView *)countStackViewWithRowGuide:(UILayoutGuide *)rowGuide columnGuide:(UILayoutGuide *)columnGuide {
    UIStackView *countStackView = [self stackViewWithRowGuide:nil columnGuide:columnGuide];
    NSLayoutConstraint *stackViewTopConstraint = [countStackView.topAnchor constraintEqualToAnchor:rowGuide.topAnchor constant:0.0];
    stackViewTopConstraint.active = YES;
    [self.countStackViewTopConstraints addObject:stackViewTopConstraint];
    [countStackView.bottomAnchor constraintEqualToAnchor:rowGuide.bottomAnchor constant:-kMarginForTitles].active = YES;
    return countStackView;
}

#pragma mark - Update Methods

- (void)updateReferenceStationSource {
    NSString *sourceString = [self stringForReferenceStationSource:self.widgetModel.rtkSignal];
    self.statusTitleLabel.text = [sourceString stringByAppendingString:kConnectionStatusTitleEnding];
    self.baseStationColumnLabel.text = sourceString;
}

- (NSString *)stringForReferenceStationSource:(DUXBetaRTKSignal)signal {
    switch (signal) {
        case DUXBetaRTKSignalDRTK2:
            return @"D-RTK 2 Mobile Station";
        case DUXBetaRTKSignalBaseStation:
            return @"Base Station";
        case DUXBetaRTKSignalNetworkRTK:
            return @"Network RTK";
        case DUXBetaRTKSignalCustomNetwork:
            return @"Custom Network RTK";
    }
}

- (void)updateConnectionStatus {
    self.statusLabel.textColor = [self.statusLabelColors objectForKey:@(self.widgetModel.rtkConnectionStatus)];
    
    switch (self.widgetModel.rtkSignal) {
        case DUXBetaRTKSignalBaseStation:
        case DUXBetaRTKSignalDRTK2:
            [self updateBaseStationStatus];
            break;
        case DUXBetaRTKSignalNetworkRTK:
        case DUXBetaRTKSignalCustomNetwork:
            [self updateNetworkStatus];
            break;
    }
}

- (void)updateBaseStationStatus {
    switch (self.widgetModel.rtkConnectionStatus) {
        case DUXBetaRTKConnectionStatusInUse:
            self.statusLabel.text = NSLocalizedString(@"RTK connected. RTK data in use", @"Value label");
            break;
        case DUXBetaRTKConnectionStatusNotInUse:
            self.statusLabel.text = NSLocalizedString(@"RTK connected. RTK data not in use", @"Value label");
            break;
        case DUXBetaRTKConnectionStatusDisconnected:
            self.statusLabel.text = NSLocalizedString(@"Not Connected", @"Value label");
            break;
    }
}

- (void)updateNetworkStatus {
    NSString *sourceString = [self stringForReferenceStationSource:self.widgetModel.rtkSignal];
    NSString *localizedInternalError = NSLocalizedString(@"Internal error", @"Value label");
    NSString *internalErrorMessage = [sourceString stringByAppendingFormat:@" %@", localizedInternalError];
    switch (self.widgetModel.networkServiceState.channelState) {
        case DJIRTKNetworkServiceChannelStateTransmitting:
            if (self.widgetModel.rtkInUse) {
                self.statusLabel.text = NSLocalizedString(@"RTK connected. RTK data in use", @"Value label");
            } else {
                self.statusLabel.text = NSLocalizedString(@"RTK connected. RTK data not in use", @"Value label");
            }
            break;
        case DJIRTKNetworkServiceChannelStateLoginFailure:
            self.statusLabel.text = NSLocalizedString(@"Verification Failed", @"Value label");
            break;
        case DJIRTKNetworkServiceChannelStateServiceSuspension:
            self.statusLabel.text = NSLocalizedString(@"Suspending account...", @"Value label");
            break;
        //case DJIRTKNetworkServiceChannelStateAccountExpired:// == ACCOUNT_EXPIRED missing?
            //self.statusLabel.text = @"Time Verification Failed";
            //break;
        case DJIRTKNetworkServiceChannelStateNetworkNotReachable:
            self.statusLabel.text = NSLocalizedString(@"Network Unavailable", @"Value label");
            break;
        case DJIRTKNetworkServiceChannelStateUnknown:
            self.statusLabel.text = internalErrorMessage;
            break;
        case DJIRTKNetworkServiceChannelStateAccountError:
            self.statusLabel.text = NSLocalizedString(@"Account error", @"Value label");
            break;
        case DJIRTKNetworkServiceChannelStateConnecting:
            self.statusLabel.text = NSLocalizedString(@"Connecting to server...", @"Value label");
            break;
        case DJIRTKNetworkServiceChannelStateInvalidRequest:
            self.statusLabel.text = NSLocalizedString(@"Request rejected by server", @"Value label");
            break;
        case DJIRTKNetworkServiceChannelStateServerNotReachable:
            self.statusLabel.text = NSLocalizedString(@"Connecting to server...", @"Value label");
            break;
        default:
            self.statusLabel.text = NSLocalizedString(@"Not Connected", @"Value label");
            break;
    }
}

- (void)updatePrecisionValues {
    // Orientation
    if (self.widgetModel.modelName == DJIAircraftModelNameMatrice210RTK) {
        self.aircraftOrientationLabel.hidden = YES;
        self.aircraftOrientationImageView.hidden = NO;
        if (self.widgetModel.isHeadingValid) {
            if (self.orientationValidTint) {
                self.aircraftOrientationImageView.image = [self.orientationValidImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                self.aircraftOrientationImageView.image = self.aircraftHeadingValidImage;
            }
        } else {
            if (self.orientationInvalidTint) {
                self.aircraftOrientationImageView.image = [self.orientationInvalidImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            } else {
                self.aircraftOrientationImageView.image = self.aircraftHeadingInvalidImage;
            }
        }
    } else if (self.widgetModel.modelName == DJIAircraftModelNameMatrice210RTKV2) {
        self.aircraftOrientationLabel.hidden = NO;
        self.aircraftOrientationImageView.hidden = YES;
        switch (self.widgetModel.rtkState.headingSolution) {
            case DJIRTKHeadingSolutionNone:
                self.aircraftOrientationLabel.text = @"N/A";
                break;
            case DJIRTKHeadingSolutionSinglePoint:
                self.aircraftOrientationLabel.text = NSLocalizedString(@"SINGLE", @"Value label");
                break;
            case DJIRTKHeadingSolutionFloat:
                self.aircraftOrientationLabel.text = NSLocalizedString(@"FLOAT", @"Value label");
                break;
            case DJIRTKHeadingSolutionFixedPoint:
                self.aircraftOrientationLabel.text = NSLocalizedString(@"FIXED", @"Value label");
                break;
            case DJIRTKHeadingSolutionUnknown:
                self.aircraftOrientationLabel.text = NSLocalizedString(@"UNKNOWN", @"Value label");
                break;
            default:
                break;
        }
    }
    
    //Position
    switch (self.widgetModel.locationState) {
        case DUXBetaRTKLocationStateNone:
            self.aircraftPositioningLabel.text = @"N/A";
            break;
        case DUXBetaRTKLocationStateSinglePoint:
            self.aircraftPositioningLabel.text = NSLocalizedString(@"SINGLE", @"Value label");
            break;
        case DUXBetaRTKLocationStateFloat:
        case DUXBetaRTKLocationStateFloatIono:
        case DUXBetaRTKLocationStateFloatNarrow:
            self.aircraftPositioningLabel.text = NSLocalizedString(@"FLOAT", @"Value label");
            break;
        case DUXBetaRTKLocationStateFixedPoint:
            self.aircraftPositioningLabel.text = NSLocalizedString(@"FIXED", @"Value label");
            break;
        default:
            self.aircraftPositioningLabel.text = NSLocalizedString(@"UNKNOWN", @"Value label");
            break;
    }
}

- (void)updateLocationAndCountValues {
    // Update Aircraft Location Values
    if (self.widgetModel.locationState != DUXBetaRTKLocationStateNone) {
        self.aircraftLatitudeLabel.text = [NSString stringWithFormat:@"%.9f", self.widgetModel.rtkState.mobileStationLocation.latitude];
        self.aircraftLongitudeLabel.text = [NSString stringWithFormat:@"%.9f", self.widgetModel.rtkState.mobileStationLocation.longitude];
        self.aircraftAltitudeLabel.text = [NSString stringWithFormat:@"%.3f", self.widgetModel.rtkState.mobileStationAltitude];
        self.baseStationLatitudeLabel.text = [NSString stringWithFormat:@"%.9f", self.widgetModel.rtkState.baseStationLocation.latitude];
        self.baseStationLongitudeLabel.text = [NSString stringWithFormat:@"%.9f", self.widgetModel.rtkState.baseStationLocation.longitude];
        self.baseStationAltitudeLabel.text = [NSString stringWithFormat:@"%.3f", self.widgetModel.rtkState.baseStationAltitude];
        self.aircraftCourseAngleLabel.text = self.widgetModel.isHeadingValid ? [NSString stringWithFormat:@"%.2f", self.widgetModel.rtkState.mobileStationFusionHeading] : @"N/A";
    } else {
        self.aircraftLatitudeLabel.text = @"N/A";
        self.aircraftLongitudeLabel.text = @"N/A";
        self.aircraftAltitudeLabel.text = @"N/A";
        self.aircraftCourseAngleLabel.text = @"N/A";
        
        self.baseStationLatitudeLabel.text = @"N/A";
        self.baseStationLongitudeLabel.text = @"N/A";
        self.baseStationAltitudeLabel.text = @"N/A";
    }
    
    if (self.widgetModel.rtkEnabled) {
        self.antenna1GPSCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver1GPSInfo.satelliteCount];
        self.antenna1BeidouCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver1BeiDouInfo.satelliteCount];
        self.antenna1GlonassCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver1GalileoInfo.satelliteCount];
        self.antenna1GalileoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver1GalileoInfo.satelliteCount];

        self.antenna2GPSCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver2GPSInfo.satelliteCount];
        self.antenna2BeidouCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver2BeiDouInfo.satelliteCount];
        self.antenna2GlonassCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver2GLONASSInfo.satelliteCount];
        self.antenna2GalileoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.mobileStationReceiver2GalileoInfo.satelliteCount];
        
        self.baseStationGPSCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.baseStationReceiverGPSInfo.satelliteCount];
        self.baseStationBeidouCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.baseStationReceiverBeiDouInfo.satelliteCount];
        self.baseStationGlonassCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.baseStationReceiverGLONASSInfo.satelliteCount];
        self.baseStationGalileoCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.widgetModel.rtkState.baseStationReceiverGalileoInfo.satelliteCount];
    } else {
        self.antenna1GPSCountLabel.text = @"N/A";
        self.antenna1BeidouCountLabel.text = @"N/A";
        self.antenna1GlonassCountLabel.text = @"N/A";
        self.antenna1GalileoCountLabel.text = @"N/A";
        
        self.antenna2GPSCountLabel.text = @"N/A";
        self.antenna2BeidouCountLabel.text = @"N/A";
        self.antenna2GlonassCountLabel.text = @"N/A";
        self.antenna2GalileoCountLabel.text = @"N/A";
        
        self.baseStationGPSCountLabel.text = @"N/A";
        self.baseStationBeidouCountLabel.text = @"N/A";
        self.baseStationGlonassCountLabel.text = @"N/A";
        self.baseStationGalileoCountLabel.text = @"N/A";
    }
    [self.view setNeedsDisplay];
}

- (void)updateStandardDeviations {
    self.latitudeStandardDeviationLabel.text = [NSString stringWithFormat:@"%.7f m", self.widgetModel.rtkState.mobileStationStandardDeviation.latitude];
    self.longitudeStandardDeviationLabel.text = [NSString stringWithFormat:@"%.7f m", self.widgetModel.rtkState.mobileStationStandardDeviation.longtitude];
    self.altitudeStandardDeviationLabel.text = [NSString stringWithFormat:@"%.7f m", self.widgetModel.rtkState.mobileStationStandardDeviation.altitude];
}

- (void)updateFieldVisibilities {
    // Orientation
    NSArray *aircraftWithOrientation = @[DJIAircraftModelNameMatrice210RTK, DJIAircraftModelNameMatrice210RTKV2];//TODO: M300 too?
    CGFloat shouldShowOrientation = NO;
    for (NSString *name in aircraftWithOrientation) {
        if ([self.widgetModel.modelName isEqualToString:name]) {
            shouldShowOrientation = YES;
        }
    }
    if (shouldShowOrientation) {
        self.orientationRowLabel.hidden = NO;
        if ([self.widgetModel.modelName isEqualToString: DJIAircraftModelNameMatrice210RTK]) {
            self.aircraftOrientationImageView.hidden = NO;
            self.aircraftOrientationLabel.hidden = YES;
        } else {
            self.aircraftOrientationImageView.hidden = YES;
            self.aircraftOrientationLabel.hidden = NO;
        }
    } else {
        self.orientationRowLabel.hidden = YES;
        self.aircraftOrientationImageView.hidden = YES;
        self.aircraftOrientationLabel.hidden = YES;
    }
    
    // Customize Satellite Constellation Count Visibility
    self.beidouTitleLabel.hidden = !self.isBeidouCountVisible;
    self.antenna1BeidouCountLabel.hidden = !self.isBeidouCountVisible;
    self.baseStationBeidouCountLabel.hidden = !self.isBeidouCountVisible;
    
    self.glonassTitleLabel.hidden = !self.isGlonassCountVisible;
    self.antenna1GlonassCountLabel.hidden = !self.isGlonassCountVisible;
    self.baseStationGlonassCountLabel.hidden = !self.isGlonassCountVisible;
    
    self.galileoTitleLabel.hidden = !self.isGalileoCountVisible;
    self.antenna1GalileoCountLabel.hidden = !self.isGalileoCountVisible;
    self.baseStationGalileoCountLabel.hidden = !self.isGalileoCountVisible;
    
    // Scale Row Height Appropriately
    self.visibleConstellationCount = 4;
    if (!self.isBeidouCountVisible) {
        self.visibleConstellationCount--;
    }
    if (!self.isGlonassCountVisible) {
        self.visibleConstellationCount--;
    }
    if (!self.isGalileoCountVisible) {
        self.visibleConstellationCount--;
    }
    
    // Antenna 2 Values and Antenna 1 Header should be hidden for P4R
    if ([self.widgetModel.modelName isEqualToString:DJIAircraftModelNamePhantom4RTK]) {
        self.antenna1TitleLabel.hidden = YES;
        self.antenna2TitleLabel.hidden = YES;
        self.antenna2GPSCountLabel.hidden = YES;
        self.antenna2BeidouCountLabel.hidden = YES;
        self.antenna2GlonassCountLabel.hidden = YES;
        self.antenna2GalileoCountLabel.hidden = YES;
        
        self.antennaRowTopConstraint.active = NO;
        self.row2ToRow3Constraint.active = YES;
        
        [self toggleRow4TopAnchorMargins:YES];
    } else {
        self.antenna1TitleLabel.hidden = NO;
        self.antenna2TitleLabel.hidden = NO;
        self.antenna2GPSCountLabel.hidden = NO;
        self.antenna2BeidouCountLabel.hidden = !self.isBeidouCountVisible;
        self.antenna2GlonassCountLabel.hidden = !self.isGlonassCountVisible;
        self.antenna2GalileoCountLabel.hidden = !self.isGalileoCountVisible;
        
        self.antennaRowTopConstraint.active = YES;
        self.row2ToRow3Constraint.active = NO;
        
        [self toggleRow4TopAnchorMargins:NO];
    }
    
    // Standard Deviation
    if ([self.widgetModel.modelName isEqualToString:DJIAircraftModelNamePhantom4RTK]) {
        self.row4ConstraintToBorder.active = NO;
        self.row4ConstraintToRow5.active = YES;
        self.horizontalDivider4.hidden = NO;
        self.standardDeviationStackView.hidden = NO;
        self.standardDeviationTitleLabel.hidden = NO;
    } else {
        self.row4ConstraintToBorder.active = YES;
        self.row4ConstraintToRow5.active = NO;
        self.horizontalDivider4.hidden = YES;
        self.standardDeviationStackView.hidden = YES;
        self.standardDeviationTitleLabel.hidden = YES;
    }
}

- (void)toggleRow4TopAnchorMargins:(BOOL)marginsOn {
    for (NSLayoutConstraint *constraint in self.countStackViewTopConstraints)   {
        constraint.constant = marginsOn ? kMarginForTitles : 0.0;
    }
}
#pragma mark - Customization Methods
- (void)customizeConnectionStatus {
    self.statusTitleLabel.font = self.statusTitleLabelFont;
    self.statusTitleLabel.textColor = self.statusTitleLabelTextColor;
    self.statusTitleLabel.backgroundColor = self.statusTitleLabelBackgroundColor;
    
    self.statusLabel.font = self.statusLabelFont;
    self.statusLabel.backgroundColor = self.statusLabelBackgroundColor;
}

- (void)customizeBackground {
    // Customize Widget Background
    self.view.backgroundColor = self.backgroundColor;
    
    // Customize Table Color
    self.tableBorderView.layer.borderColor = self.tableColor.CGColor;
    self.horizontalDivider1.backgroundColor = self.tableColor;
    self.horizontalDivider2.backgroundColor = self.tableColor;
    self.horizontalDivider3.backgroundColor = self.tableColor;
    self.horizontalDivider4.backgroundColor = self.tableColor;
    
    self.verticalDivider1.backgroundColor = self.tableColor;
    self.verticalDivider2.backgroundColor = self.tableColor;
}

- (void)customizeTitles {
    for (UILabel *label in self.titleLabels) {
        label.font = self.titleLabelFont;
        label.textColor = self.titleLabelTextColor;
        label.backgroundColor = self.titleLabelBackgroundColor;
    }
}

- (void)customizeValues {
    for (UILabel *label in self.valueLabels) {
        label.font = self.valueLabelFont;
        label.textColor = self.valueLabelTextColor;
        label.backgroundColor = self.valueLabelBackgroundColor;
    }
}

- (void)setStatusTextColor:(UIColor *)fontColor forConnectionStatus:(DUXBetaRTKConnectionStatus)status {
    [self.statusLabelColors setObject:fontColor forKey:@(status)];
}

- (UIColor *)statusTextColorForConnectionStatus:(DUXBetaRTKConnectionStatus)status {
    return self.statusLabelColors[@(status)];
}

#pragma mark - Miscellanious
- (DUXBetaWidgetSizeHint)widgetSizeHint {
    DUXBetaWidgetSizeHint hint = {kDesignSize.width / kDesignSize.height, kDesignSize.width, kDesignSize.height};
    return hint;
}

- (NSString *)toolbarItemTitle {
    return @"RTK";
}

- (UIImage *)toolbarItemIcon {
    return [UIImage duxbeta_imageWithAssetNamed:@"GPSSignalIcon"];
}

#pragma mark - Send Updates
- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendRTKConnectedUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState rtkConnectedUpdate:self.widgetModel.rtkSupported]];
}

- (void)sendRTKStateUpdate {
    if (self.widgetModel.rtkState != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState rtkStateUpdate:self.widgetModel.rtkState]];
    }
}

- (void)sendModelUpdate {
    if (self.widgetModel.modelName != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState modelUpdate:self.widgetModel.modelName]];
    }
}

- (void)sendRTKSignalUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState rtkSignalUpdate:self.widgetModel.rtkSignal]];
}

- (void)sendRTKStandardDeviationUpdate {
    if (self.widgetModel.rtkState.mobileStationStandardDeviation != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState standardDeviationUpdate:self.widgetModel.rtkState.mobileStationStandardDeviation]];
    }
}

- (void)sendBaseStationStatusUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState baseStationStatusUpdate:self.widgetModel.rtkConnectionStatus]];
}

- (void)sendNetRTCMStatusUpdate {
    if (self.widgetModel.networkServiceState != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusWidgetModelState rtkNetRTCMStatusUpdate:self.widgetModel.networkServiceState]];
    }
}


@end

@implementation RTKSatelliteStatusWidgetModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"productConnected" number:[NSNumber numberWithBool:isConnected]];
}

+ (instancetype)rtkConnectedUpdate:(BOOL)isRTKConnected {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"rtkConnectedUpdate" number:[NSNumber numberWithBool:isRTKConnected]];
}

+ (instancetype)rtkStateUpdate:(DJIRTKState *)rtkState {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"rtkStateUpdate" object:rtkState];
}

+ (instancetype)modelUpdate:(NSString *)modelName {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"modelUpdate" string:modelName];
}

+ (instancetype)rtkSignalUpdate:(DJIRTKReferenceStationSource)rtkSignal {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"modelUpdate" number:[NSNumber numberWithUnsignedChar:rtkSignal]];
}

+ (instancetype)standardDeviationUpdate:(DJILocationStandardDeviation *)locationStandardDeviation {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"standardDeviationUpdate" object:locationStandardDeviation];
}

+ (instancetype)baseStationStatusUpdate:(DUXBetaRTKConnectionStatus)connectionStatus {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"baseStationStatusUpdate" number:[NSNumber numberWithUnsignedLong:connectionStatus]];
}

+ (instancetype)rtkNetRTCMStatusUpdate:(DJIRTKNetworkServiceState *)networkServiceState {
    return [[RTKSatelliteStatusWidgetModelState alloc] initWithKey:@"rtkNetRTCMStatusUpdate" object:networkServiceState];
}

@end

