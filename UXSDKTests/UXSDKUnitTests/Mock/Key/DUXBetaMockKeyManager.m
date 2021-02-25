//
//  DUXBetaMockKeyManager.m
//  UXSDKUnitTests
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

#import "DUXBetaMockKeyManager.h"
#import "DUXBetaMockKeyedValue.h"

@implementation DUXBetaMockKeyManager

- (void)startListeningForChangesOnKey:(DJIKey *)key
                         withListener:(id)listener
                       andUpdateBlock:(DJIKeyedListenerUpdateBlock)updateBlock {
    DUXBetaMockKey *mockKey = [DUXBetaMockKey mockKeyWithKey:key];
    
    DUXBetaMockKeyedValue *mockValue = self.mockKeyValueDictionary[mockKey];
    if (mockValue) {
        if (updateBlock) {
            updateBlock(nil, mockValue);
        }
    } else {
        [super startListeningForChangesOnKey:key
                                withListener:listener
                              andUpdateBlock:updateBlock];
    }
}

- (DJIKeyedValue *)getValueForKey:(DJIKey *)key {
    DUXBetaMockKey *mockKey = [DUXBetaMockKey mockKeyWithKey:key];
    
    id mockValue = self.mockKeyValueDictionary[mockKey];
    if (mockValue) {
        return mockValue;
    } else {
        return [super getValueForKey:key];
    }
}

@end
