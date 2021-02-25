//
//  DUXBetaRuntimeMappingCTests.m
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

#import <XCTest/XCTest.h>
#import <UXSDKCore/NSObject+DUXBetaMapping.h>

typedef struct {
    CGFloat testFloat;
} DUXBetaTestStruct;

typedef union {
    CGFloat testFloat;
} DUXBetaTestUnion;


@interface DUXBetaBindClass : NSObject

@property (assign, nonatomic) DUXBetaTestStruct testStruct;
@property (assign, nonatomic) DUXBetaTestUnion testUnion;

@end

@implementation DUXBetaBindClass

- (instancetype)init {
    self = [super init];
    if (self) {
        DUXBetaTestStruct exampleStruct = {0.0};
        self.testStruct = exampleStruct;
        
        DUXBetaTestUnion exampleUnion = {0.0};
        self.testUnion = exampleUnion;
    }
    return self;
}

@end

@interface DUXBetaRuntimeMappingCTests : XCTestCase

@property (strong, nonatomic) DUXBetaBindClass *bindClass;

@end

@implementation DUXBetaRuntimeMappingCTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.bindClass = [DUXBetaBindClass new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.bindClass = nil;
}

- (void)testStruct {
    DUXBetaTestStruct testStruct = {1.0};
    [self.bindClass duxbeta_setCustomMappingValue:[NSValue value:&testStruct withObjCType:@encode(DUXBetaTestStruct)] forKey:@"testStruct"];
    XCTAssert(self.bindClass.testStruct.testFloat == 1.0);
}

/*
 *  Key Value Coding for C unions is broken:
 *  https://stackoverflow.com/questions/14295505/objective-c-kvo-doesnt-work-with-c-unions
 *  https://openradar.appspot.com/radar?id=5033038689861632
 */

//- (void)testUnion {
//    DUXBetaTestUnion testUnion = {1.0};
//    [self.bindClass duxbeta_setCustomMappingValue:[NSValue value:&testUnion withObjCType:@encode(DUXBetaTestUnion)] forKey:@"testUnion"];
//    XCTAssert(self.bindClass.testUnion.testFloat == 1.0);
//}

@end
