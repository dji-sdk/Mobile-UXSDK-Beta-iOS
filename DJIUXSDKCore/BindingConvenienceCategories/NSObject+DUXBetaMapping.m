//
//  NSObject+DUXBetaMapping.m
//  DJIUXSDK
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

#import "NSObject+DUXBetaMapping.h"
#import <objc/runtime.h>
#import <objc/message.h>

typedef NS_ENUM(NSUInteger, DUXBetaPropertyType) {
    // unknown
    DUXBetaPropertyType_Unknown,
    // basic data type
    DUXBetaPropertyType_Void,
    DUXBetaPropertyType_Bool,
    DUXBetaPropertyType_Int8,
    DUXBetaPropertyType_UInt8,
    DUXBetaPropertyType_Int16,
    DUXBetaPropertyType_UInt16,
    DUXBetaPropertyType_Int32,
    DUXBetaPropertyType_UInt32,
    DUXBetaPropertyType_Int64,
    DUXBetaPropertyType_UInt64,
    DUXBetaPropertyType_Float,
    DUXBetaPropertyType_Double,
    DUXBetaPropertyType_LongDouble,
    // C data type
    DUXBetaPropertyType_Class,
    DUXBetaPropertyType_Pointer,
    DUXBetaPropertyType_Selector,
    DUXBetaPropertyType_CFString,
    DUXBetaPropertyType_CFArray,
    DUXBetaPropertyType_CFUnion,
    DUXBetaPropertyType_CFStruct,
    DUXBetaPropertyType_CFBitFiled,
    // objc data type
    DUXBetaPropertyType_Id,
    DUXBetaPropertyType_Block,
    DUXBetaPropertyType_NSString,
    DUXBetaPropertyType_NSMutableString,
    DUXBetaPropertyType_NSValue,
    DUXBetaPropertyType_NSNumber,
    DUXBetaPropertyType_NSDecimalNumber,
    DUXBetaPropertyType_NSData,
    DUXBetaPropertyType_NSMutableData,
    DUXBetaPropertyType_NSDate,
    DUXBetaPropertyType_NSURL,
    DUXBetaPropertyType_NSArray,
    DUXBetaPropertyType_NSMutableArray,
    DUXBetaPropertyType_NSDictionary,
    DUXBetaPropertyType_NSMutableDictionary,
    DUXBetaPropertyType_NSSet,
    DUXBetaPropertyType_NSMutableSet,
    DUXBetaPropertyType_NSCustomObject
};

static inline Class NSBlockClass() {
    static Class cls;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^block)(void) = ^{};
        cls = ((NSObject *)block).class;
        while (class_getSuperclass(cls) != [NSObject class]) {
            cls = class_getSuperclass(cls);
        }
    });
    return cls;
}

static inline const char* DUXBetaObjCTypeEncodingFromProperty(objc_property_t property) {
    unsigned int count = 0;
    objc_property_attribute_t* attributes = property_copyAttributeList(property, &count);
    const char *typeEncoding = NULL;
    
    for (int i = 0; i < count; i ++) {
        const char* attributesName = attributes[i].name;
        if (attributesName[0] == 'T') {
            typeEncoding = attributes[i].value;
            return typeEncoding;
        }
    }
    
    return typeEncoding;
}

@interface DUXBetaBaseWidgetModelProperty : NSObject
@property (nonatomic) DUXBetaPropertyType propertyType;
@property (nonatomic) const char* objcType;
@property (nonatomic, copy) NSString* ivarName;
@property (nonatomic, copy) NSString* setterName;
@end
@implementation DUXBetaBaseWidgetModelProperty
@end

static void* kDUXBetaBaseWidgetModelMappingKey = &kDUXBetaBaseWidgetModelMappingKey;

@implementation NSObject (DUXBetaMapping)

- (void)duxbeta_setCustomMappingValue:(id)value forKey:(NSString *)key {
    if (!value || [value isEqual:[NSNull null]] || key.length == 0) {
        return;
    }
    DUXBetaBaseWidgetModelProperty* property = [self propertyTypeFromPropertyName:key];
    DUXBetaPropertyType propertyType = property.propertyType;
    switch (propertyType) {
        case DUXBetaPropertyType_Unknown:
        case DUXBetaPropertyType_Void:{
            NSAssert(0, @"the property type unknown ..");
            return;
        }
        case DUXBetaPropertyType_Bool:
        case DUXBetaPropertyType_Int8:
        case DUXBetaPropertyType_UInt8:
        case DUXBetaPropertyType_Int16:
        case DUXBetaPropertyType_UInt16:
        case DUXBetaPropertyType_Int32:
        case DUXBetaPropertyType_UInt32:
        case DUXBetaPropertyType_Int64:
        case DUXBetaPropertyType_UInt64:
        case DUXBetaPropertyType_Float:
        case DUXBetaPropertyType_Double:
        case DUXBetaPropertyType_LongDouble: {
            if ([value isKindOfClass:[NSNumber class]]) {
                [self setValue:value forKey:key];
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        case DUXBetaPropertyType_Id:
        case DUXBetaPropertyType_NSString:
        case DUXBetaPropertyType_NSMutableString:
        case DUXBetaPropertyType_NSValue:
        case DUXBetaPropertyType_NSNumber:
        case DUXBetaPropertyType_NSDecimalNumber:
        case DUXBetaPropertyType_NSData:
        case DUXBetaPropertyType_NSMutableData:
        case DUXBetaPropertyType_NSDate:
        case DUXBetaPropertyType_NSURL:
        case DUXBetaPropertyType_NSArray:
        case DUXBetaPropertyType_NSMutableArray:
        case DUXBetaPropertyType_NSDictionary:
        case DUXBetaPropertyType_NSMutableDictionary:
        case DUXBetaPropertyType_NSSet:
        case DUXBetaPropertyType_NSMutableSet:
        case DUXBetaPropertyType_NSCustomObject: {
            Class cls = [self customObjectClassFromAttributesValue:property.objcType];
            if (cls && [value isKindOfClass:cls]) {
                [self setValue:value forKey:key];
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        case DUXBetaPropertyType_Class:
        case DUXBetaPropertyType_Pointer:
        case DUXBetaPropertyType_Selector:
        case DUXBetaPropertyType_CFString:
        case DUXBetaPropertyType_CFArray:
        case DUXBetaPropertyType_CFUnion:
        case DUXBetaPropertyType_CFBitFiled:
        case DUXBetaPropertyType_CFStruct:
        case DUXBetaPropertyType_Block: [self internalSetCustomValueWithMsgSend:value forKey:key property:property];
            break;
    }
}

- (void)internalSetCustomValueWithMsgSend:(id)value forKey:(NSString *)key property:(DUXBetaBaseWidgetModelProperty *)property {
    SEL setterSelector = NSSelectorFromString(property.setterName);
    BOOL isNull = (value == (id)kCFNull);
    switch (property.propertyType) {
        case DUXBetaPropertyType_CFArray:
        case DUXBetaPropertyType_CFUnion:
        case DUXBetaPropertyType_CFBitFiled:
        case DUXBetaPropertyType_CFStruct: {
            if ([value isKindOfClass:[NSValue class]]) {
                const char* valueType = ((NSValue *)value).objCType;
                // Invert how property.ivarName is created, remove _ prefix
                NSString *propertyName = [[property.ivarName mutableCopy] substringFromIndex:1];
                objc_property_t propertyStructure = class_getProperty([self class], [propertyName UTF8String]);
                const char* metaType = DUXBetaObjCTypeEncodingFromProperty(propertyStructure);
                if (metaType != NULL) {
                    if (valueType && strcmp(valueType, metaType) == 0) {
                        [self setValue:value forKey:key];
                    }
                }
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        case DUXBetaPropertyType_Class: {
            if (isNull) {
                void (* msgSendPtr) (id, SEL, Class) = (void (*)(id, SEL, Class))objc_msgSend;
                msgSendPtr((id)self, setterSelector,(Class) NULL);
            }
            else {
                if ([value isKindOfClass:[NSString class]]) {
                    Class cls = NSClassFromString(value);
                    if (cls) {
                        void (* msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL, Class))objc_msgSend;
                        msgSendPtr(self, setterSelector,(Class)cls);
                    }
                }
                else {
                    Class cls = object_getClass(value);
                    if (cls) {
                        if (class_isMetaClass(cls)) {
                            void (* msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL, Class))objc_msgSend;
                            msgSendPtr(self, setterSelector,(Class)value);
                        } else {
                            void (* msgSendPtr) (id, SEL,Class) = (void (*)(id, SEL, Class))objc_msgSend;
                            msgSendPtr(self, setterSelector,(Class)cls);
                        }
                    }
                }
            }
        }
            break;
        case DUXBetaPropertyType_CFString:
        case DUXBetaPropertyType_Pointer: {
            if (isNull) {
                void (* msgSendPtr)(id, SEL,void *) = (void (*)(id, SEL,void*))objc_msgSend;
                msgSendPtr(self, setterSelector, (void *)NULL);
            }
            else if ([value isKindOfClass:[NSValue class]]) {
                NSValue* nsValue = value;
                if (nsValue.objCType && strcmp(nsValue.objCType, "^v") == 0) {
                    void (* msgSendPtr) (id, SEL, void *) = (void (*)(id, SEL, void *))objc_msgSend;
                    msgSendPtr(self, setterSelector,nsValue.pointerValue);
                }
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        case DUXBetaPropertyType_Selector: {
            if (isNull) {
                void (* msgSendPtr)(id, SEL,SEL) = (void (*)(id, SEL, SEL))objc_msgSend;
                msgSendPtr(self,setterSelector,(SEL)NULL);
            }
            else if ([value isKindOfClass:[NSString class]]) {
                SEL theSel = NSSelectorFromString(value);
                if (theSel) {
                    void (*msgSendPtr)(id, SEL, SEL) = (void (*)(id, SEL, SEL))objc_msgSend;
                    msgSendPtr(self,setterSelector,theSel);
                }
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        case DUXBetaPropertyType_Block: {
            if (isNull) {
                void (* msgSendPtr) (id, SEL, void (^)(void)) = (void (*)(id, SEL, void (^)(void)))objc_msgSend;
                msgSendPtr(self,setterSelector, (void (^)(void))NULL);
            } else if ([value isKindOfClass:NSBlockClass()]) {
                void (* msgSendPtr) (id, SEL, void (^)(void)) = (void (*)(id, SEL, void (^)(void)))objc_msgSend;
                msgSendPtr(self, setterSelector,(void (^)(void))value);
            }
            else {
                NSAssert(0, @"the property's type does not match ..");
            }
        }
            break;
        default:break;
    }
}

- (DUXBetaBaseWidgetModelProperty *)propertyTypeFromPropertyName:(NSString *)propertyName {
    //If we already have cached values
    if ([self.propertyTypeMap objectForKey:propertyName]) {
        return [self.propertyTypeMap objectForKey:propertyName];
    }
    //No cached values
    DUXBetaBaseWidgetModelProperty* property = [[DUXBetaBaseWidgetModelProperty alloc] init];
    objc_property_t p = class_getProperty([self class],propertyName.UTF8String);
    property.setterName = [NSString stringWithFormat:@"set%@%@:",[propertyName substringToIndex:1].uppercaseString,[propertyName substringFromIndex:1]];
    property.ivarName = [NSString stringWithFormat:@"_%@",propertyName];
    unsigned int count = 0;
    objc_property_attribute_t* attributes = property_copyAttributeList(p, &count);
    for (int i = 0; i < count; i ++) {
        const char* attributesName = attributes[i].name;
        switch (attributesName[0]) {
            // Type
            case 'T': {
                const char* attributeValue = attributes[i].value;
                DUXBetaPropertyType propertyType = [self typeFromPropertyAttributeValue:attributeValue];
                property.propertyType = propertyType;
                property.objcType = attributeValue;
            }
                break;
            // Setter
            case 'S': {
                const char* attributeValue = attributes[i].value;
                if (attributeValue) {
                    property.setterName = [NSString stringWithUTF8String:attributeValue];
                }
            }
                break;
            // IVar
            case 'V': {
                const char* attributeValue = attributes[i].value;
                if (attributeValue) {
                    property.ivarName = [NSString stringWithUTF8String:attributeValue];
                }
            }
                break;
            default:break;
        }
    }
    [self.propertyTypeMap setObject:property forKey:propertyName];
    return property;
}

- (NSMutableDictionary *)propertyTypeMap {
    NSMutableDictionary* propertyTypeMap = objc_getAssociatedObject(self, kDUXBetaBaseWidgetModelMappingKey);
    if (!propertyTypeMap) {
        propertyTypeMap = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(self, kDUXBetaBaseWidgetModelMappingKey, propertyTypeMap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return propertyTypeMap;
}

- (DUXBetaPropertyType)typeFromPropertyAttributeValue:(const char *)attributesValue {
    size_t len = strlen(attributesValue);
    if (len == 0 ) {
        return DUXBetaPropertyType_Unknown;
    }
    switch (*attributesValue) {
        case 'v': return  DUXBetaPropertyType_Void;
        case 'B': return  DUXBetaPropertyType_Bool;
        case 'c': return  DUXBetaPropertyType_Int8;
        case 'C': return  DUXBetaPropertyType_UInt8;
        case 's': return  DUXBetaPropertyType_Int16;
        case 'S': return  DUXBetaPropertyType_UInt16;
        case 'i': return  DUXBetaPropertyType_Int32;
        case 'I': return  DUXBetaPropertyType_UInt32;
        case 'l': return  DUXBetaPropertyType_Int32;
        case 'L': return  DUXBetaPropertyType_UInt32;
        case 'q': return  DUXBetaPropertyType_Int64;
        case 'Q': return  DUXBetaPropertyType_UInt64;
        case 'f': return  DUXBetaPropertyType_Float;
        case 'd': return  DUXBetaPropertyType_Double;
        case 'D': return  DUXBetaPropertyType_LongDouble;
        case '#': return  DUXBetaPropertyType_Class;
        case '^': return  DUXBetaPropertyType_Pointer;
        case ':': return  DUXBetaPropertyType_Selector;
        case '*': return  DUXBetaPropertyType_CFString;
        case '[': return  DUXBetaPropertyType_CFArray;
        case '(': return  DUXBetaPropertyType_CFUnion;
        case '{': return  DUXBetaPropertyType_CFStruct;
        case 'b': return  DUXBetaPropertyType_CFBitFiled;
        case '@':{
            if (len == 2 && *(attributesValue + 1) == '?') {
                return DUXBetaPropertyType_Block;
            }
            else {
                if (len == 1) {
                    return DUXBetaPropertyType_Id;
                }
                //Other ObjC object types except blocks and ID types
                Class cls = [self customObjectClassFromAttributesValue:attributesValue];
                if (cls) {
                    return [self propertyTypeFromClass:cls];
                }
                return DUXBetaPropertyType_Id;
            }
        default:
            return DUXBetaPropertyType_Unknown;
        }
    }
}

- (Class)customObjectClassFromAttributesValue:(const char*)attributesValue {
    size_t len = strlen(attributesValue);
    if (len > 3) {
        char name[len - 2];
        name[len - 3] = '\0';
        memcpy(name, attributesValue + 2, len - 3);
        Class cls = objc_getClass(name);
        return cls;
    }
    return nil;
}

- (DUXBetaPropertyType)propertyTypeFromClass:(Class)cls {
    if (!cls) return  DUXBetaPropertyType_Unknown;
    if ([cls isSubclassOfClass:[NSString class]]) return  DUXBetaPropertyType_NSString;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return  DUXBetaPropertyType_NSMutableString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return  DUXBetaPropertyType_NSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return  DUXBetaPropertyType_NSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return  DUXBetaPropertyType_NSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return  DUXBetaPropertyType_NSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return  DUXBetaPropertyType_NSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return  DUXBetaPropertyType_NSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return  DUXBetaPropertyType_NSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return  DUXBetaPropertyType_NSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return  DUXBetaPropertyType_NSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return  DUXBetaPropertyType_NSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return  DUXBetaPropertyType_NSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return  DUXBetaPropertyType_NSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return  DUXBetaPropertyType_NSSet;
    return  DUXBetaPropertyType_NSCustomObject;
}

- (NSString *)propetyTypeNameWithType:(DUXBetaPropertyType)type {
    switch (type) {
        case DUXBetaPropertyType_Unknown:return @"DUXBetaPropertyType_Unknown";
        case DUXBetaPropertyType_Void:return @"DUXBetaPropertyType_Void";
        case DUXBetaPropertyType_Bool:return @"DUXBetaPropertyType_Bool";
        case DUXBetaPropertyType_Int8:return @"DUXBetaPropertyType_Int8";
        case DUXBetaPropertyType_UInt8:return @"DUXBetaPropertyType_UInt8";
        case DUXBetaPropertyType_Int16:return @"DUXBetaPropertyType_Int16";
        case DUXBetaPropertyType_UInt16:return @"DUXBetaPropertyType_UInt16";
        case DUXBetaPropertyType_Int32:return @"DUXBetaPropertyType_Int32";
        case DUXBetaPropertyType_UInt32:return @"DUXBetaPropertyType_UInt32";
        case DUXBetaPropertyType_Int64:return @"DUXBetaPropertyType_Int64";
        case DUXBetaPropertyType_UInt64:return @"DUXBetaPropertyType_UInt64";
        case DUXBetaPropertyType_Float:return @"DUXBetaPropertyType_Float";
        case DUXBetaPropertyType_Double:return @"DUXBetaPropertyType_Double";
        case DUXBetaPropertyType_LongDouble:return @"DUXBetaPropertyType_LongDouble";
        case DUXBetaPropertyType_Class:return @"DUXBetaPropertyType_Class";
        case DUXBetaPropertyType_Pointer:return @"DUXBetaPropertyType_Pointer";
        case DUXBetaPropertyType_Selector:return @"DUXBetaPropertyType_Selector";
        case DUXBetaPropertyType_CFString:return @"DUXBetaPropertyType_CFString";
        case DUXBetaPropertyType_CFArray:return @"DUXBetaPropertyType_CFArray";
        case DUXBetaPropertyType_CFUnion:return @"DUXBetaPropertyType_CFUnion";
        case DUXBetaPropertyType_CFStruct:return @"DUXBetaPropertyType_CFStruct";
        case DUXBetaPropertyType_CFBitFiled:return @"DUXBetaPropertyType_CFBitFiled";
        case DUXBetaPropertyType_Id:return @"DUXBetaPropertyType_Id";
        case DUXBetaPropertyType_Block:return @"DUXBetaPropertyType_Block";
        case DUXBetaPropertyType_NSString:return @"DUXBetaPropertyType_NSString";
        case DUXBetaPropertyType_NSMutableString:return @"DUXBetaPropertyType_NSMutableString";
        case DUXBetaPropertyType_NSValue:return @"DUXBetaPropertyType_NSValue";
        case DUXBetaPropertyType_NSNumber:return @"DUXBetaPropertyType_NSNumber";
        case DUXBetaPropertyType_NSDecimalNumber:return @"DUXBetaPropertyType_NSDecimalNumber";
        case DUXBetaPropertyType_NSData:return @"DUXBetaPropertyType_NSData";
        case DUXBetaPropertyType_NSMutableData:return @"DUXBetaPropertyType_NSMutableData";
        case DUXBetaPropertyType_NSDate:return @"DUXBetaPropertyType_NSDate";
        case DUXBetaPropertyType_NSURL:return @"DUXBetaPropertyType_NSURL";
        case DUXBetaPropertyType_NSArray:return @"DUXBetaPropertyType_NSArray";
        case DUXBetaPropertyType_NSMutableArray:return @"DUXBetaPropertyType_NSMutableArray";
        case DUXBetaPropertyType_NSDictionary:return @"DUXBetaPropertyType_NSDictionary";
        case DUXBetaPropertyType_NSMutableDictionary:return @"DUXBetaPropertyType_NSMutableDictionary";
        case DUXBetaPropertyType_NSSet:return @"DUXBetaPropertyType_NSSet";
        case DUXBetaPropertyType_NSMutableSet:return @"DUXBetaPropertyType_NSMutableSet";
        case DUXBetaPropertyType_NSCustomObject:return @"DUXBetaPropertyType_NSCustomObject";
    }
}

@end
