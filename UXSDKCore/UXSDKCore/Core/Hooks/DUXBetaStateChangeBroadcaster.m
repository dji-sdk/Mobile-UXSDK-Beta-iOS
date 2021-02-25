//
//  DUXBetaStateChangeBroadcaster.m
//  UXSDKCore
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

#import "DUXBetaStateChangeBroadcaster.h"
#import "DUXBetaStateChangeBaseData.h"

@interface OwnerHandlerTuple : NSObject
@property (nonatomic, strong) id<NSCopying> ownerKey;
@property (nonatomic, strong) AnalyticsHandler handler;

- (instancetype)initWithOwner:(id)owner handler:(AnalyticsHandler)handler;
@end

@implementation OwnerHandlerTuple
- (instancetype)initWithOwner:(id)owner handler:(AnalyticsHandler)handler {
    if (self = [super init]) {
        _ownerKey = @((long long)owner);    // This matches the instanceToKey method in StateChangeBroadcaster below
        _handler = handler;                 // This is a handler block which is always callable, even if the owning instance has been released
    }
    return self;
}
@end

@interface DUXBetaStateChangeBroadcaster ()
// The handlersDict is a dictionary of classnames as keys and an array of the handlers to
// call when an item of that class is sent.
@property (atomic, strong) NSMutableDictionary<NSString*, NSMutableArray<OwnerHandlerTuple*> *> *handlersDict;
// The listenersDict is a dictionary of the objects and all the classnames that it listens for.
// It is used to register and unregister listener classes efficiently. the strings in the set
// will match keys in the handlersDict for efficient removal.
@property (atomic, strong) NSMutableDictionary<id, NSMutableSet<NSString*>*> *listenersDict;

@property (nonatomic, strong, readonly) dispatch_queue_t syncQueue;
@end


@implementation DUXBetaStateChangeBroadcaster

+ (DUXBetaStateChangeBroadcaster *)instance {
    static DUXBetaStateChangeBroadcaster *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DUXBetaStateChangeBroadcaster alloc] init];
    });
    return manager;
}

// Convenience method to just send
+ (void)send:(DUXBetaStateChangeBaseData*)analyticsData {
    [[self instance] send:analyticsData];
}


- (instancetype)init {
    if (self = [super init]) {
        _handlersDict = [[NSMutableDictionary alloc] init];
        _listenersDict = [[NSMutableDictionary alloc] init];
        _syncQueue = dispatch_queue_create("analytics delivery", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc {
    
}

// TODO: Wrap this in the sequential queue
- (void)registerListener:(id)listener analyticsClassName:(NSString*)analyticsClassName handler:(AnalyticsHandler)block {

    id<NSCopying> listenerKey = [self instanceToKey:listener];
    NSMutableSet<NSString*> *classSet = _listenersDict[listenerKey];   // Get the class set for this particular listener
    if (classSet == nil) {
        classSet = [NSMutableSet setWithObject:analyticsClassName];
        self.listenersDict[listenerKey] = classSet;
    } else {
        [classSet addObject:analyticsClassName]; // Since a set is unique, when isEqual: is called on each member, strings are treated as strings, not object pointers for the comparison.
    }
    
    // Now add the handler to the handlersDict
    OwnerHandlerTuple *tuple = [[OwnerHandlerTuple alloc] initWithOwner:listener handler:block];
    NSMutableArray<OwnerHandlerTuple*> *workArray = _handlersDict[analyticsClassName];
    if (workArray == nil) {
        workArray = [[NSMutableArray<OwnerHandlerTuple*> alloc] init];
        _handlersDict[analyticsClassName] = workArray;
    }
    [workArray addObject:tuple];
}

- (void)unregisterListener:(id)listener {
    id<NSCopying> listenerKey = [self instanceToKey:listener];

    NSMutableSet<NSString*> *theClassNames = _listenersDict[listenerKey];
    for(NSString *classname in theClassNames) {
        [self unregisterListener:listener forClassName:classname];
    }
    [_listenersDict removeObjectForKey:listenerKey];
}

- (void)unregisterListener:(id)listener forClassName:(NSString*)analyticsClassNane {
    // Iterate in any order. We are removing unique entries.
    id<NSCopying> listenerKey = [self instanceToKey:listener];
     NSMutableArray<OwnerHandlerTuple*> *handlersList = _handlersDict[analyticsClassNane];
     NSMutableArray *removeObjects = [[NSMutableArray alloc] init];
     for (OwnerHandlerTuple *tuple in handlersList) {
         if ([(NSObject*)tuple.ownerKey isEqual:listenerKey]) {
             [removeObjects addObject:tuple];
         }
     }
     [handlersList removeObjectsInArray:removeObjects];
    if (handlersList.count == 0) {
        [_handlersDict removeObjectForKey:analyticsClassNane];
    } else {
        _handlersDict[analyticsClassNane] = handlersList;
    }
}

- (id<NSCopying>)instanceToKey:(id)listener {
    return @((long long) listener);
}

- (void)send:(DUXBetaStateChangeBaseData*)analyticsData {
    NSString *classname = NSStringFromClass([analyticsData class]);
    NSMutableArray<OwnerHandlerTuple*> *handlersList = _handlersDict[classname];
    for (OwnerHandlerTuple *ownerHandler in handlersList) {
        AnalyticsHandler handler = ownerHandler.handler;
        dispatch_async(_syncQueue, ^(){
            handler(analyticsData);
        });
    }
}
@end
