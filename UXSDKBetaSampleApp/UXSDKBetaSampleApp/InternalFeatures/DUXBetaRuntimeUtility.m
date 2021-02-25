//
//  DUXBetaRuntimeUtility.m
//  UXSDKSampleApp
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

#import "DUXBetaRuntimeUtility.h"
#import <objc/runtime.h>
#import <DJIWidget/DJIWidget.h>
#import <DJIUXSDK/DJIUXSDK.h>

#import <UXSDKMedia/UXSDKMedia.h>
#import <UXSDKVisualCamera/UXSDKVisualCamera.h>

@implementation DUXBetaRuntimeUtility

NSArray *DUXBetaWidgetClassNames(Class parentClass) {
    NSMutableArray <NSString *> *widgetsClassNamesList = [NSMutableArray array];
    
    int classesCount = objc_getClassList(NULL, 0);
    Class *classes = NULL;
    if (classesCount > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * classesCount);
        classesCount = objc_getClassList(classes, classesCount);
        
        for (NSInteger i = 0; i < classesCount; i++)
        {
            Class superClass = classes[i];
            do
            {
                superClass = class_getSuperclass(superClass);
            } while(superClass && superClass != parentClass);
            
            if (superClass == nil)
            {
                continue;
            }
            
            Class foundKlass = classes[i];
            NSString *stringFromClass = NSStringFromClass(foundKlass);
            if (stringFromClass) {
                [widgetsClassNamesList addObject:stringFromClass];
            }
        }
    }
    
    [widgetsClassNamesList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    free(classes);
    return widgetsClassNamesList;
}

+ (nonnull NSArray *)listOfSubclassesOfClassName:(nonnull NSString *)className {
    Class klass = NSClassFromString(className);
    if (klass) {
        return DUXBetaWidgetClassNames(klass);
    } else {
        return [NSMutableArray array];
    }
}

+ (nullable id)instanceOfClass:(Class)klass {
    if (klass == [DUXBetaColorWaveFormWidget class]) {
        DJIVideoPreviewer *preview = [DJIVideoPreviewer instance];
        return [self instanceOfClass:klass withVideoPreviewer:preview];
    } else if (klass == [DUXBetaAccessLockerSetPasswordWidget class] ||
               klass == [DUXBetaAccessLockerChangeRemovePasswordWidget class] ||
               klass == [DUXBetaAccessLockerChangePasswordWidget class] ||
               klass == [DUXBetaAccessLockerRemovePasswordWidget class] ||
               klass == [DUXBetaAccessLockerFormatAircraftWidget class] ||
               klass == [DUXBetaAccessLockerEnterPasswordWidget class] ){
        DUXBetaAccessLockerControlWidgetModel *widgetModel = [[DUXBetaAccessLockerControlWidgetModel alloc] init];
        [widgetModel setup];
        return [[klass alloc] initWithWidgetModel:widgetModel];
    }
    return [[klass alloc] init];
}

+ (nullable id)instanceOfClass:(Class)klass withVideoPreviewer:(DJIVideoPreviewer *)previewer {
    return [[klass alloc] initWithVideoPreviewer:(previewer)];
}

@end
