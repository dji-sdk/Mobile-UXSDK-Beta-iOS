//
//  DJIFlyZoneInformation+DUXBetaFlyZoneInformation.m
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

#import "DJIFlyZoneInformation+DUXBetaFlyZoneInformation.h"
#import "NSDateFormatter+DUXBetaDateFormatter.h"

@implementation DJIFlyZoneInformation (DUXBetaFlyZoneInformation)

- (BOOL)isUnlocked {
    if ([self.unlockEndTime isEqualToString:DJIFlyZoneInformationInvalidTimestamp]) {
        return NO;
    } else {
        // Test server vs production server have different date formats, so we try both!
        NSDate *unlockEndDateTime = [[NSDateFormatter duxbeta_utcDateFormatter] dateFromString:self.unlockEndTime];
        if (!unlockEndDateTime) {
            unlockEndDateTime = [[NSDateFormatter duxbeta_utcAlternateDateFormatter] dateFromString:self.unlockEndTime];
        }
        
        if ([[NSDate date] compare:unlockEndDateTime] == NSOrderedDescending) {
            //unlockEndDateTime is in the past, zone no longer unlocked
            return NO;
        } else {
            return YES;
        }
    }
}

@end
