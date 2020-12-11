//
//  SJSQLite3TableClassCache.m
//  AFNetworking
//
//  Created by 畅三江 on 2019/7/26.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import "SJSQLite3TableClassCache.h"

@implementation SJSQLite3TableClassCache {
    NSMutableSet *_set;
}

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _set = NSMutableSet.new;
    }
    return self;
}

- (BOOL)containsClass:(Class)cls {
    if ( cls != nil ) {
        return [_set containsObject:cls];
    }
    return NO;
}
- (void)addClass:(Class)cls {
    if ( cls != nil ) {
        [_set addObject:cls];
    }
}
- (void)addClasses:(NSSet<Class> *)set {
    if ( set ) {
        [_set unionSet:set];
    }
}
- (void)removeClass:(Class)cls {
    if ( cls ) {
        [_set removeObject:cls];
    }
}
- (void)removeClasses:(NSSet<Class> *)set {
    if ( set ) {
        [_set minusSet:set];
    }
}
@end
