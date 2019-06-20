//
//  DUXBetaVisionWidget.h
//  DJIUXSDK
//  
//  Copyright © 2018-2019 DJI. All rights reserved.
//

#import <DJIUXSDKWidgets/DUXBetaBaseWidget.h>
#import "DUXBetaVisionWidgetModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  Widget to display the vision status/collision avodance status, of the aircraft.
 *  Depending on sensors availability, flight mode, and aircraft type.
 */

@interface DUXBetaVisionWidget : DUXBetaBaseWidget

@property (nonatomic, strong) DUXBetaVisionWidgetModel *widgetModel;

/**
 *  Set image for given vision status
 */
- (void)setImage:(UIImage *)image forVisionStatus:(DUXBetaVisionStatus)status;

/**
 *  Get image for given vision status
 */
- (UIImage *)imageForVisionStatus:(DUXBetaVisionStatus)status;

@end

NS_ASSUME_NONNULL_END
