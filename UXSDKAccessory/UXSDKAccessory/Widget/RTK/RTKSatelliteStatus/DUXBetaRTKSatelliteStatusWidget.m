//
//  DUXBetaRTKSatelliteStatusWidget.m
//  UXSDKAccessory
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
#import <UXSDKCore/DUXBetaStateChangeBaseData.h>

@import UXSDKCore;

static CGSize const kDesignSize = {500.0, 500.0};
static NSString *const kConnectionStatusTitleEnding = @" Status: ";

static const float kMarginForTitles = 15.0;
static const float kMarginThin = 10.0;
static const float kTableLineWidth = 1.0;
static const float kDefaultFontSize = 12.0;
static const float kSingleRowHeight = 30.0;

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

@property (strong, nonatomic) NSLayoutConstraint *row5HeightConstraint;

@property (strong, nonatomic) UIView *antennaRowHeightSpacer;

@property (strong, nonatomic) NSMutableDictionary <NSNumber *, UIColor *> *statusLabelColors;

@property (strong, nonatomic) UIImageView *aircraftOrientationImageView;

@property (strong, nonatomic) UIStackView *standardDeviationStackView;

@property (strong, nonatomic) NSMutableArray *titleLabels;
@property (strong, nonatomic) NSMutableArray *valueLabels;
@property (assign, nonatomic) uint8_t visibleConstellationCount;

@end


/**
 * RTKSatelliteStatusModelState contains the model hooks for the DUXBetaRTKSatelliteStatusWidget.
 * It implements the hooks:
 *
 * Key: productConnected         Type: NSNumber - Sends a boolean value as an NSNumber indicating the connected state of
 *                                        the device when it changes.
 *
 * Key: rtkConnectionUpdated     Type: NSNumber - Sends a boolean value as an NSNumber indicating if the current device
 *                                          supports RTK.
 * Key: rtkStateUpdated          Type: DJIRTKState - Sends a DJIRTKState when received from the widget model.
 * Key: modelUpdated             Type: NSString - Sends the model name of the product when updated.
 * Key: rtkSignalUpdated         Type: DJIRTKReferenceStationSource - Sends the type of base station reference source used.
 * Key: standardDeviationUpdated        Type: DJILocationStandardDeviation - Sends the standard deviation of the aircraft's location when updated.
 * Key: rtkBaseStationStateUpdated      Type: DUXBetaRTKConnectionStatus - Sends the status of the base station when updated.
 * Key: rtkNetworkServiceStateUpdated   Type: DJIRTKNetworkServiceState - Sends the RTK network service state when updated.
*/
@interface RTKSatelliteStatusModelState : DUXBetaStateChangeBaseData

+ (instancetype)productConnected:(BOOL)isConnected;

+ (instancetype)rtkConnectionUpdated:(BOOL)isConnected;

+ (instancetype)rtkStateUpdated:(DJIRTKState *)rtkState;

+ (instancetype)modelUpdated:(NSString *)modelName;

+ (instancetype)rtkSignalUpdated:(DJIRTKReferenceStationSource)rtkSignal;

+ (instancetype)standardDeviationUpdated:(DJILocationStandardDeviation *)locationStandardDeviation;

+ (instancetype)rtkBaseStationStateUpdated:(DUXBetaRTKConnectionStatus)connectionStatus;

+ (instancetype)rtkNetworkServiceStateUpdated:(DJIRTKNetworkServiceState *)networkServiceState;


@end

@implementation DUXBetaRTKSatelliteStatusWidget

- (instancetype)init {
    self = [super init];
    if (self) {
        _titleLabelTextColor = [UIColor uxsdk_whiteColor];
        _titleLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _titleLabelBackgroundColor = [UIColor uxsdk_clearColor];
        _valueLabelTextColor = [UIColor uxsdk_whiteColor];
        _valueLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _valueLabelBackgroundColor = [UIColor uxsdk_clearColor];
        
        _statusTitleLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _statusTitleLabelTextColor = [UIColor uxsdk_whiteColor];
        _statusTitleLabelBackgroundColor = [UIColor uxsdk_clearColor];
        
        _statusLabelFont = [UIFont systemFontOfSize:kDefaultFontSize];
        _statusLabelBackgroundColor = [UIColor uxsdk_clearColor];
        
        _isBeidouCountVisible = YES;
        _isGlonassCountVisible = YES;
        _isGalileoCountVisible = YES;
        
        _visibleConstellationCount = 4;
        
        _aircraftHeadingValidImage = [UIImage duxbeta_imageWithAssetNamed:@"OrientationValid" forClass:[self class]];
        _aircraftHeadingInvalidImage = [UIImage duxbeta_imageWithAssetNamed:@"OrientationInvalid" forClass:[self class]];

        _statusLabelColors = [[NSMutableDictionary alloc] initWithDictionary:@{
            @(DUXBetaRTKConnectionStatusInUse) : [UIColor uxsdk_goodColor],
            @(DUXBetaRTKConnectionStatusNotInUse) : [UIColor uxsdk_warningColor],
            @(DUXBetaRTKConnectionStatusDisconnected) : [UIColor uxsdk_errorDangerColor]
        }];
        
        _tableColor = [UIColor uxsdk_rtkTableBorderColor];
        _backgroundColor = [UIColor uxsdk_clearColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.translatesAutoresizingMaskIntoConstraints = NO;

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
    BindRKVOModel(self.widgetModel, @selector(sendrtkConnectionUpdated), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKStateUpdate), rtkState);
    BindRKVOModel(self.widgetModel, @selector(sendModelUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKSignalUpdate), rtkSupported);
    BindRKVOModel(self.widgetModel, @selector(sendRTKStandardDeviationUpdate), rtkState.mobileStationStandardDeviation);
    BindRKVOModel(self.widgetModel, @selector(sendrtkBaseStationStateUpdated), rtkSupported);
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
    self.view.backgroundColor = [UIColor uxsdk_blackColor];
    [self.view.widthAnchor constraintEqualToConstant:kDesignSize.width].active = YES;
    
    NSString *connectionStatus = [[self stringForReferenceStationSource:self.widgetModel.rtkSignal] stringByAppendingString:kConnectionStatusTitleEnding];
    self.statusTitleLabel = [self tableLabelWithTitle:connectionStatus textColor:[UIColor uxsdk_whiteColor] andFont:[UIFont systemFontOfSize:kDefaultFontSize]];
    
    [self.view addSubview:self.statusTitleLabel];
    
    [self.statusTitleLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kMarginForTitles].active = YES;
    [self.statusTitleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:kMarginThin].active = YES;
    [self.statusTitleLabel.heightAnchor constraintEqualToConstant:20.0].active = YES;
    
    UIColor *statusInitialColor = [self.statusLabelColors objectForKey:@(DUXBetaRTKConnectionStatusDisconnected)];
    self.statusLabel = [self tableLabelWithTitle:@"Disconnected" textColor:statusInitialColor andFont:[UIFont systemFontOfSize:kDefaultFontSize]];
    [self.view addSubview:self.statusLabel];
    
    [self.statusLabel.centerYAnchor constraintEqualToAnchor:self.statusTitleLabel.centerYAnchor].active = YES;
    [self.statusLabel.leadingAnchor constraintEqualToAnchor:self.statusTitleLabel.trailingAnchor].active = YES;
    [self.statusLabel.heightAnchor constraintEqualToAnchor:self.statusTitleLabel.heightAnchor].active = YES;
    
    // Setup RTK Satellite Status Table
    self.tableBorderView = [[UIView alloc] init];
    self.tableBorderView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableBorderView.layer.borderWidth = kTableLineWidth;
    self.tableBorderView.layer.cornerRadius = 15.0;
    [self.view addSubview:self.tableBorderView];
    
    [self.tableBorderView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:kMarginForTitles].active = YES;
    [self.tableBorderView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-kMarginForTitles].active = YES;
    [self.tableBorderView.topAnchor constraintEqualToAnchor:self.statusTitleLabel.bottomAnchor constant:kMarginThin].active = YES;
    [self.tableBorderView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    
    // Part 1, create all the guides for positioning.
    
    UILayoutGuide *column1Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column1Guide];
    [column1Guide.widthAnchor constraintEqualToAnchor:self.tableBorderView.widthAnchor multiplier:0.25].active = YES;
    [column1Guide.leadingAnchor constraintEqualToAnchor:self.tableBorderView.leadingAnchor].active = YES;
    
    UILayoutGuide *column2Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column2Guide];
    [column2Guide.leadingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor].active = YES;
    [column2Guide.widthAnchor constraintEqualToAnchor:self.tableBorderView.widthAnchor multiplier:(1.0-0.25)/2.0].active = YES;

    UILayoutGuide *column3Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:column3Guide];
    [column3Guide.leadingAnchor constraintEqualToAnchor:column2Guide.trailingAnchor].active = YES;
    [column3Guide.trailingAnchor constraintEqualToAnchor:self.tableBorderView.trailingAnchor].active = YES;
    
    UILayoutGuide *row1Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row1Guide];
    UILayoutGuide *row2Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row2Guide];

    // Row 1 guide is fixed height and sits below row 1
    [row1Guide.topAnchor constraintEqualToAnchor:self.tableBorderView.topAnchor].active = YES;
    [row1Guide.heightAnchor constraintEqualToConstant:kSingleRowHeight].active = YES;
    
    UILayoutGuide *row3Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row3Guide];
    
    // The antenna row guide sits between rows 3 and 4 of the table.
    // It shows the titles Antenna 1 and Antenna 2 and is dynamically hidden when the drone has one rtk antenna.
    UILayoutGuide *antennaLabelRowGuide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:antennaLabelRowGuide];
    
    UILayoutGuide *row4Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row4Guide];
    
    UILayoutGuide *row5Guide = [[UILayoutGuide alloc] init];
    [self.view addLayoutGuide:row5Guide];
    

    // Part 2. Set up all the default label strings and add identifiers to the guides for easier identificaton in the layout
    self.aircraftColumnLabel = [self titleLabelWithTitle:@"Aircraft"];
    self.baseStationColumnLabel = [self titleLabelWithTitle:@"Base Station"];
    
    self.orientationRowLabel = [self titleLabelWithTitle:@"Orientation:"];
    self.positioningRowLabel = [self titleLabelWithTitle:@"Positioning:"];
    
    self.latitudeTitleLabel = [self titleLabelWithTitle:@"Latitude:"];
    self.longitudeTitleLabel = [self titleLabelWithTitle:@"Longitude:"];
    self.altitudeTitleLabel = [self titleLabelWithTitle:@"Altitude:"];
    self.courseAngleTitleLabel = [self titleLabelWithTitle:@"Course Angle:"];
    
    self.antenna1TitleLabel = [self titleLabelWithTitle:@"Antenna 1"];
    self.antenna2TitleLabel = [self titleLabelWithTitle:@"Antenna 2"];
    
    self.antenna1GPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1BeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1GlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna1GalileoCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2GPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2BeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2GlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.antenna2GalileoCountLabel = [self valueLabelWithTitle:@"N/A"];
    
    self.aircraftLatitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftLongitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftAltitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftCourseAngleLabel = [self valueLabelWithTitle:@"N/A"];
    
    self.baseStationLatitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationLongitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationAltitudeLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationGPSCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationBeidouCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationGlonassCountLabel = [self valueLabelWithTitle:@"N/A"];
    self.baseStationGalileoCountLabel = [self valueLabelWithTitle:@"N/A"];

    self.aircraftOrientationLabel = [self valueLabelWithTitle:@"N/A"];
    self.aircraftPositioningLabel = [self valueLabelWithTitle:@"N/A"];

    self.standardDeviationTitleLabel = [self titleLabelWithTitle:@"Standard Deviation:"];
    self.latitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];
    self.longitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];
    self.altitudeStandardDeviationLabel = [self valueLabelWithTitle:@"N/A"];


    column1Guide.identifier = @"column1Guide";
    column2Guide.identifier = @"column2Guide";
    column3Guide.identifier = @"column3Guide";
    row1Guide.identifier = @"row1Guide";
    row2Guide.identifier = @"row2Guide";
    row3Guide.identifier = @"row3Guide";
    antennaLabelRowGuide.identifier = @"antennaLabelRowGuide";
    row4Guide.identifier = @"row4Guide";
    row5Guide.identifier = @"row5Guide";
    

    // Part 3. Build a container for every section in the table to allow easier content management with internal constraints
    [self.view addSubview:self.aircraftColumnLabel];
    [self.view addSubview:self.baseStationColumnLabel];
    [self.view addSubview:self.antenna1TitleLabel];
    [self.view addSubview:self.antenna2TitleLabel];


    UIStackView *precisionTitlesStackView = [self stackViewInsertedInto:self.view];
    precisionTitlesStackView.accessibilityIdentifier = @"precisionTitlesStackView";
    [precisionTitlesStackView addArrangedSubview:self.orientationRowLabel];
    [precisionTitlesStackView addArrangedSubview:self.positioningRowLabel];

    UIStackView *locationTitlesStackView = [self stackViewInsertedInto:self.view];
    locationTitlesStackView.accessibilityIdentifier = @"locationTitlesStackView";
    [locationTitlesStackView addArrangedSubview:self.latitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.longitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.altitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.courseAngleTitleLabel];
    
    UIStackView *constellationNameStackView = [self buildConstellationNameStackView];
    constellationNameStackView.accessibilityIdentifier = @"constellationNameStackView";
    [self.view addSubview:constellationNameStackView];

    // Part 4. Assign constraints to the containers for the layout. This builds all the rows to set up the vertical positioning sequentially.
    // Row heights are now based on the stacks inserted into the rows, so changing a stack height dynamically will collapse the rows appropriately.
    [self.aircraftColumnLabel.leadingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor constant:kMarginForTitles].active = YES;
    [self.aircraftColumnLabel.trailingAnchor constraintEqualToAnchor:column2Guide.trailingAnchor constant:-kMarginForTitles].active = YES;
    [self.aircraftColumnLabel.centerYAnchor constraintEqualToAnchor:row1Guide.centerYAnchor].active = YES;

    [self.baseStationColumnLabel.leadingAnchor constraintEqualToAnchor:column2Guide.trailingAnchor constant:kMarginForTitles].active = YES;
    [self.baseStationColumnLabel.trailingAnchor constraintEqualToAnchor:column3Guide.trailingAnchor constant:-kMarginForTitles].active = YES;
    [self.baseStationColumnLabel.centerYAnchor constraintEqualToAnchor:row1Guide.centerYAnchor].active = YES;
    
    [precisionTitlesStackView.topAnchor constraintEqualToAnchor:row1Guide.bottomAnchor constant:kMarginForTitles].active = YES;
    [row2Guide.topAnchor constraintEqualToAnchor:row1Guide.bottomAnchor].active = YES;
    [row2Guide.bottomAnchor constraintEqualToAnchor:precisionTitlesStackView.bottomAnchor constant:kMarginForTitles].active = YES;
    [row3Guide.topAnchor constraintEqualToAnchor:row2Guide.bottomAnchor].active = YES;
    
    [locationTitlesStackView.topAnchor constraintEqualToAnchor:row3Guide.topAnchor constant:kMarginForTitles].active = YES;
    [row3Guide.bottomAnchor constraintEqualToAnchor:locationTitlesStackView.bottomAnchor constant:kMarginForTitles].active = YES;
    [antennaLabelRowGuide.topAnchor constraintEqualToAnchor:row3Guide.bottomAnchor].active = YES;

    [self.antenna1TitleLabel.topAnchor constraintEqualToAnchor:antennaLabelRowGuide.topAnchor constant:kMarginForTitles].active = YES;
    [self.antenna1TitleLabel.leadingAnchor constraintEqualToAnchor:column2Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    
    [self.antenna2TitleLabel.leadingAnchor constraintEqualToAnchor:self.antenna1TitleLabel.trailingAnchor constant:kMarginForTitles].active = YES;
    [self.antenna2TitleLabel.topAnchor constraintEqualToAnchor:antennaLabelRowGuide.topAnchor constant:kMarginForTitles].active = YES;
    [self.antenna2TitleLabel.widthAnchor constraintEqualToAnchor:self.antenna1TitleLabel.widthAnchor].active = YES;

    self.antennaRowHeightSpacer = [[UIView alloc] init];
    self.antennaRowHeightSpacer.translatesAutoresizingMaskIntoConstraints = NO;
    UIStackView *spacerStack = [self makeAntennaSpacerStack:self.antennaRowHeightSpacer insertInto:self.view];
    spacerStack.accessibilityIdentifier = @"antennaSpacerStack";
    [spacerStack.topAnchor constraintEqualToAnchor:antennaLabelRowGuide.topAnchor].active = YES;
    [spacerStack.leadingAnchor constraintEqualToAnchor:column1Guide.leadingAnchor].active = YES;
    [antennaLabelRowGuide.bottomAnchor constraintEqualToAnchor:spacerStack.bottomAnchor].active = YES;

    [row4Guide.topAnchor constraintEqualToAnchor:antennaLabelRowGuide.bottomAnchor].active = YES;
    [constellationNameStackView.topAnchor constraintEqualToAnchor:row4Guide.topAnchor constant:kMarginForTitles].active = YES;
    [row4Guide.bottomAnchor constraintEqualToAnchor:constellationNameStackView.bottomAnchor constant:4].active = YES;

    // The row5Guide connects to the bottom of the table and may be used for a standard deviation row depending on aircraft model.
    [row5Guide.topAnchor constraintEqualToAnchor:row4Guide.bottomAnchor constant:kMarginForTitles].active = YES;
    [precisionTitlesStackView.leadingAnchor constraintEqualToAnchor:column1Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    [precisionTitlesStackView.trailingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor constant:-kMarginForTitles].active = YES;
    [locationTitlesStackView.leadingAnchor constraintEqualToAnchor:column1Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    [locationTitlesStackView.trailingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor constant:-kMarginForTitles].active = YES;
    [constellationNameStackView.leadingAnchor constraintEqualToAnchor:column1Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    [constellationNameStackView.trailingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor constant:-kMarginForTitles].active = YES;
    
    // Set up the two stacks of antenna counts
    UIStackView *antenna1StackView = [self stackViewInsertedInto:self.view];
    antenna1StackView.accessibilityIdentifier = @"antenna1StackView";
    
    [antenna1StackView addArrangedSubview:self.antenna1GPSCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1BeidouCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1GlonassCountLabel];
    [antenna1StackView addArrangedSubview:self.antenna1GalileoCountLabel];
    
    [antenna1StackView.leadingAnchor constraintEqualToAnchor:self.antenna1TitleLabel.leadingAnchor].active = YES;
    [antenna1StackView.topAnchor constraintEqualToAnchor:row4Guide.topAnchor constant:kMarginForTitles].active = YES;

    UIStackView *antenna2StackView = [self stackViewInsertedInto:self.view];
    antenna2StackView.accessibilityIdentifier = @"antenna2StackView";

    [antenna2StackView addArrangedSubview:self.antenna2GPSCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2BeidouCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2GlonassCountLabel];
    [antenna2StackView addArrangedSubview:self.antenna2GalileoCountLabel];
    
    [antenna2StackView.leadingAnchor constraintEqualToAnchor:self.antenna2TitleLabel.leadingAnchor].active = YES;
    [antenna2StackView.topAnchor constraintEqualToAnchor:row4Guide.topAnchor constant:kMarginForTitles].active = YES;

    // Set up the aircraft precision/orientation label stack
    UIStackView *aircraftPrecisionStackView = [self stackViewInsertedInto:self.view];
    aircraftPrecisionStackView.accessibilityIdentifier = @"aircraftPrecisionStackView";
    self.aircraftOrientationImageView = [[UIImageView alloc] initWithImage:self.orientationInvalidImage];
    self.aircraftOrientationLabel.hidden = YES;
    self.aircraftOrientationImageView.hidden = YES;
    
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftOrientationLabel];
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftOrientationImageView];
    [aircraftPrecisionStackView addArrangedSubview:self.aircraftPositioningLabel];
    
    [aircraftPrecisionStackView.topAnchor constraintEqualToAnchor:row2Guide.topAnchor constant:kMarginForTitles].active = YES;
    [aircraftPrecisionStackView.leadingAnchor constraintEqualToAnchor:column2Guide.leadingAnchor constant:kMarginForTitles].active = YES;


    // Set up the location labels stack
    UIStackView *aircraftLocationStackView = [self stackViewInsertedInto:self.view];
    aircraftLocationStackView.accessibilityIdentifier = @"aircraftLocationStackView";
    [aircraftLocationStackView addArrangedSubview:self.aircraftLatitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftLongitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftAltitudeLabel];
    [aircraftLocationStackView addArrangedSubview:self.aircraftCourseAngleLabel];
    
    [aircraftLocationStackView.topAnchor constraintEqualToAnchor:row3Guide.topAnchor constant:kMarginForTitles].active = YES;
    [aircraftLocationStackView.leadingAnchor constraintEqualToAnchor:column2Guide.leadingAnchor constant:kMarginForTitles].active = YES;

    // Set up the base startion labels stack
    UIStackView *baseStationLocationStackView = [self stackViewInsertedInto:self.view];
    baseStationLocationStackView.accessibilityIdentifier = @"baseStationLocationStackView";

    [baseStationLocationStackView addArrangedSubview:self.baseStationLatitudeLabel];
    [baseStationLocationStackView addArrangedSubview:self.baseStationLongitudeLabel];
    [baseStationLocationStackView addArrangedSubview:self.baseStationAltitudeLabel];
    
    [baseStationLocationStackView.topAnchor constraintEqualToAnchor:row3Guide.topAnchor constant:kMarginForTitles].active = YES;
    [baseStationLocationStackView.leadingAnchor constraintEqualToAnchor:column3Guide.leadingAnchor constant:kMarginForTitles].active = YES;

    // Set up the base station constellation counts in a stack
    UIStackView *baseStationCountStackView = [self stackViewInsertedInto:self.view];
    baseStationLocationStackView.accessibilityIdentifier = @"baseStationLocationStackView";
    [baseStationCountStackView addArrangedSubview:self.baseStationGPSCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationBeidouCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationGlonassCountLabel];
    [baseStationCountStackView addArrangedSubview:self.baseStationGalileoCountLabel];
    
    [baseStationCountStackView.topAnchor constraintEqualToAnchor:row4Guide.topAnchor constant:kMarginForTitles].active = YES;
    [baseStationCountStackView.leadingAnchor constraintEqualToAnchor:column3Guide.leadingAnchor constant:kMarginForTitles].active = YES;

    // Setup the standard deviation label positioning based on the flexible height row5Guide
    self.standardDeviationTitleLabel.numberOfLines = 2;
    [self.view addSubview:self.standardDeviationTitleLabel];

    [self.standardDeviationTitleLabel.topAnchor constraintEqualToAnchor:row4Guide.bottomAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationTitleLabel.leadingAnchor constraintEqualToAnchor:column1Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationTitleLabel.trailingAnchor constraintEqualToAnchor:column1Guide.trailingAnchor constant:-kMarginForTitles].active = YES;

    // Set up the standard devation values. (These aren't labeled on the display.) The stack for these is set up slightly
    // differently. It has internal edge margins. If the aircraft doesn't support standard deviation, the internal labels
    // are hidden, collapsing the stack. Margins are inside this stack to allow them to be added or removed conveniently to
    // collapse the stack. The row5Guide height is based on this stack height. When the stack collapses and margins set to 0,
    // row5Guide height becomes 0, and row4Guide then moves to the bottom of the table view, removing the standard deviation row entirely.
    self.standardDeviationStackView = [self stackViewInsertedInto:self.view];
    self.standardDeviationStackView.layoutMarginsRelativeArrangement = YES;
    self.standardDeviationStackView.layoutMargins = UIEdgeInsetsMake(kMarginForTitles, 0, kMarginForTitles, 0);

    [self.standardDeviationStackView addArrangedSubview:self.latitudeStandardDeviationLabel];
    [self.standardDeviationStackView addArrangedSubview:self.longitudeStandardDeviationLabel];
    [self.standardDeviationStackView addArrangedSubview:self.altitudeStandardDeviationLabel];

    [self.standardDeviationStackView.leadingAnchor constraintEqualToAnchor:column2Guide.leadingAnchor constant:kMarginForTitles].active = YES;
    [self.standardDeviationStackView.topAnchor constraintEqualToAnchor:row4Guide.bottomAnchor constant:0].active = YES;
    [self.standardDeviationStackView.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor].active = YES;
    
    // Part 5. Define the divider views and position them
    self.horizontalDivider1 = [self createDivider];
    [self.horizontalDivider1.leadingAnchor constraintEqualToAnchor:self.tableBorderView.leadingAnchor].active = YES;
    [self.horizontalDivider1.heightAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.horizontalDivider1.trailingAnchor constraintEqualToAnchor:self.tableBorderView.trailingAnchor].active = YES;
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
    [self.verticalDivider1.centerXAnchor constraintEqualToAnchor:column1Guide.trailingAnchor].active = YES;
    
    self.verticalDivider2 = [self createDivider];
    [self.verticalDivider2.topAnchor constraintEqualToAnchor:self.tableBorderView.topAnchor].active = YES;
    [self.verticalDivider2.widthAnchor constraintEqualToConstant:kTableLineWidth].active = YES;
    [self.verticalDivider2.bottomAnchor constraintEqualToAnchor:self.tableBorderView.bottomAnchor].active = YES;
    [self.verticalDivider2.centerXAnchor constraintEqualToAnchor:column2Guide.trailingAnchor].active = YES;
}

#pragma mark - Stack View Builders
- (UIStackView *)buildConstellationNameStackView {
    UIStackView *constellationNameStackView = [self stackViewInsertedInto:nil];
    // This needs top and bottom anchors in the original
    
    self.gpsTitleLabel = [self titleLabelWithTitle:@"GPS:"];
    self.beidouTitleLabel = [self titleLabelWithTitle:@"BeiDou:"];
    self.glonassTitleLabel = [self titleLabelWithTitle:@"GLONASS:"];
    self.galileoTitleLabel = [self titleLabelWithTitle:@"Galileo:"];
    [constellationNameStackView addArrangedSubview:self.gpsTitleLabel];
    [constellationNameStackView addArrangedSubview:self.beidouTitleLabel];
    [constellationNameStackView addArrangedSubview:self.glonassTitleLabel];
    [constellationNameStackView addArrangedSubview:self.galileoTitleLabel];
    return constellationNameStackView;
}

- (UIStackView *)buidLocationTitlesStackView {
    UIStackView *locationTitlesStackView = [self stackViewInsertedInto:nil];
    
    self.latitudeTitleLabel = [self titleLabelWithTitle:@"Latitude:"];
    self.longitudeTitleLabel = [self titleLabelWithTitle:@"Longitude:"];
    self.altitudeTitleLabel = [self titleLabelWithTitle:@"Altitude:"];
    self.courseAngleTitleLabel = [self titleLabelWithTitle:@"Course Angle:"];
    
    [locationTitlesStackView addArrangedSubview:self.latitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.longitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.altitudeTitleLabel];
    [locationTitlesStackView addArrangedSubview:self.courseAngleTitleLabel];
    return locationTitlesStackView;
}

- (UIStackView *)makeAntennaSpacerStack:(UIView*)spacerView insertInto:(UIView*)hostView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing = 0;
    [hostView addSubview:stackView];
    
    [stackView addArrangedSubview:spacerView];
    
    [spacerView.widthAnchor constraintEqualToConstant:1].active = YES;
    [spacerView.heightAnchor constraintEqualToConstant:kSingleRowHeight].active = YES;
    
    return stackView;
}

- (UIStackView *)buildAntennaCountsStackView:(UILabel*)gps beidou:(UILabel *)beidou glonass:(UILabel *)glonass galileo:(UILabel *)galileo {
    UIStackView *antennaStackView = [self stackViewInsertedInto:self.view];
    gps = [self valueLabelWithTitle:@"N/A"];
    beidou = [self valueLabelWithTitle:@"N/A"];
    glonass = [self valueLabelWithTitle:@"N/A"];
    galileo = [self valueLabelWithTitle:@"N/A"];
    
    [antennaStackView addArrangedSubview:gps];
    [antennaStackView addArrangedSubview:beidou];
    [antennaStackView addArrangedSubview:glonass];
    [antennaStackView addArrangedSubview:galileo];
    
    return antennaStackView;
}

#pragma mark - Helpers
// Helper method to create divider
- (UIView *)createDivider {
    UIView *divider = [[UIView alloc] init];
    divider.translatesAutoresizingMaskIntoConstraints = NO;
    divider.backgroundColor = [UIColor uxsdk_grayWhite50];
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
    titleLabel.textColor = [UIColor uxsdk_whiteColor];
    titleLabel.font = self.titleLabelFont;
    titleLabel.text = NSLocalizedString(labelTitle, @"Table Label Title");
    return titleLabel;
}

// Helper method to create a stack view constrained by the layout guides.
// Pass nil to layout guide to avoid constraining that dimension.
- (UIStackView *)stackViewInsertedInto:(UIView*)destView {
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionEqualSpacing;
    stackView.alignment = UIStackViewAlignmentLeading;
    stackView.spacing = kMarginThin;
    if (destView) {
        [destView addSubview:stackView];
    }
    return stackView;
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
    NSArray *aircraftWithOrientation = @[DJIAircraftModelNameMatrice210RTK, DJIAircraftModelNameMatrice210RTKV2];
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
        
        self.antennaRowHeightSpacer.hidden = YES;
    } else {
        self.antenna1TitleLabel.hidden = NO;
        self.antenna2TitleLabel.hidden = NO;
        self.antenna2GPSCountLabel.hidden = NO;
        self.antenna2BeidouCountLabel.hidden = !self.isBeidouCountVisible;
        self.antenna2GlonassCountLabel.hidden = !self.isGlonassCountVisible;
        self.antenna2GalileoCountLabel.hidden = !self.isGalileoCountVisible;
        
        self.antennaRowHeightSpacer.hidden = NO;
    }
    
    // Standard Deviation
    BOOL hideStandardDeviation = YES;
    if ([self.widgetModel.modelName isEqualToString:DJIAircraftModelNamePhantom4RTK]) {
        hideStandardDeviation = NO;
        // Also change the margins if there is standard deviation so it has margins inside the stack to allow full row collapse
        self.standardDeviationStackView.layoutMargins = UIEdgeInsetsMake(kMarginForTitles, 0, kMarginForTitles, 0);
    } else {
        // Also change the margins if there is standard deviation so it has margins inside the stack to allow full row collapse
        self.standardDeviationStackView.layoutMargins = UIEdgeInsetsZero;
    }
    
    self.horizontalDivider4.hidden = hideStandardDeviation;
    self.standardDeviationTitleLabel.hidden = hideStandardDeviation;
    // Hiding/showing these will collapse the stack view which also collapse/expands row5Guide to hide the bottom row
    self.latitudeStandardDeviationLabel.hidden = hideStandardDeviation;
    self.longitudeStandardDeviationLabel.hidden = hideStandardDeviation;
    self.altitudeStandardDeviationLabel.hidden = hideStandardDeviation;

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
    return [UIImage duxbeta_imageWithAssetNamed:@"GPSSignalIcon" forClass:[self class]];
}

#pragma mark - Send Updates
- (void)sendIsProductConnected {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState productConnected:self.widgetModel.isProductConnected]];
}

- (void)sendrtkConnectionUpdated {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState rtkConnectionUpdated:self.widgetModel.rtkSupported]];
}

- (void)sendRTKStateUpdate {
    if (self.widgetModel.rtkState != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState rtkStateUpdated:self.widgetModel.rtkState]];
    }
}

- (void)sendModelUpdate {
    if (self.widgetModel.modelName != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState modelUpdated:self.widgetModel.modelName]];
    }
}

- (void)sendRTKSignalUpdate {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState rtkSignalUpdated:self.widgetModel.rtkSignal]];
}

- (void)sendRTKStandardDeviationUpdate {
    if (self.widgetModel.rtkState.mobileStationStandardDeviation != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState standardDeviationUpdated:self.widgetModel.rtkState.mobileStationStandardDeviation]];
    }
}

- (void)sendrtkBaseStationStateUpdated {
    [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState rtkBaseStationStateUpdated:self.widgetModel.rtkConnectionStatus]];
}

- (void)sendNetRTCMStatusUpdate {
    if (self.widgetModel.networkServiceState != nil) {
        [[DUXBetaStateChangeBroadcaster instance] send:[RTKSatelliteStatusModelState rtkNetworkServiceStateUpdated:self.widgetModel.networkServiceState]];
    }
}


@end

@implementation RTKSatelliteStatusModelState

+ (instancetype)productConnected:(BOOL)isConnected {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"productConnected" number:[NSNumber numberWithBool:isConnected]];
}

+ (instancetype)rtkConnectionUpdated:(BOOL)isRTKConnected {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"rtkConnectionUpdated" number:[NSNumber numberWithBool:isRTKConnected]];
}

+ (instancetype)rtkStateUpdated:(DJIRTKState *)rtkState {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"rtkStateUpdated" object:rtkState];
}

+ (instancetype)modelUpdated:(NSString *)modelName {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"modelUpdated" string:modelName];
}

+ (instancetype)rtkSignalUpdated:(DJIRTKReferenceStationSource)rtkSignal {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"rtkSignalUpdated" number:[NSNumber numberWithUnsignedChar:rtkSignal]];
}

+ (instancetype)standardDeviationUpdated:(DJILocationStandardDeviation *)locationStandardDeviation {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"standardDeviationUpdated" object:locationStandardDeviation];
}

+ (instancetype)rtkBaseStationStateUpdated:(DUXBetaRTKConnectionStatus)connectionStatus {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"rtkBaseStationStateUpdated" number:[NSNumber numberWithUnsignedLong:connectionStatus]];
}

+ (instancetype)rtkNetworkServiceStateUpdated:(DJIRTKNetworkServiceState *)networkServiceState {
    return [[RTKSatelliteStatusModelState alloc] initWithKey:@"rtkNetworkServiceStateUpdated" object:networkServiceState];
}

@end

