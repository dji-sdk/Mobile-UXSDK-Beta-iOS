//
//  DUXBetaWarningMessage.m
//  DJIUXSDKCore
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

#import <Foundation/Foundation.h>
#import "DUXBetaWarningMessage.h"

@implementation DUXBetaWarningMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        _level = DUXBetaWarningMessageLevelUnknown;
        _type = DUXBetaWarningMessageWarningTypeOther;
        _action = DUXBetaWarningMessageActionUnknown;
    }
    return self;
}

- (DUXBetaImmutableWarningMessage *)copy {
    return [[DUXBetaImmutableWarningMessage alloc] initWithMutableMessage:self];
}

@end

@implementation DUXBetaImmutableWarningMessage

- (instancetype)initWithMutableMessage:(DUXBetaWarningMessage *)message {
    self = [super init];
    if (self) {
        _code = message.code;
        _subCode = message.subCode;
        _componentIndex = message.componentIndex;
        _reason = message.reason;
        _solution = message.solution;
        _level = message.level;
        _type = message.type;
        _action = message.action;
        _showDuration = message.showDuration;
    }
    return self;
}

- (DUXBetaWarningMessage *)mutableCopy {
    DUXBetaWarningMessage *copy = [[DUXBetaWarningMessage alloc] init];
    
    if (copy) {
        copy.code = self.code;
        copy.subCode = self.subCode;
        copy.componentIndex = self.componentIndex;
        copy.reason = [self.reason copy];
        copy.solution = [self.solution copy];
        copy.level = self.level;
        copy.type = self.type;
        copy.action = self.action;
        copy.showDuration = self.showDuration;
    }
    return copy;
}
@end
