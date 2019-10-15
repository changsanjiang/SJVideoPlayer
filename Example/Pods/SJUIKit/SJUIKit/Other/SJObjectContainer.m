//
//  SJObjectContainer.m
//  SJUIKit_Example
//
//  Created by BlueDancer on 2018/12/14.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import "SJObjectContainer.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJObjectContainer {
    NSMutableArray<SJFlagObject *> *_flags;
}
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _flags = [NSMutableArray array];
    return self;
}

- (NSInteger)count {
    return _flags.count;
}
- (void)addFlag:(SJFlagObject *)flagObject {
    if ( !flagObject ) return;
    [_flags addObject:flagObject];
}
- (void)removeFlag:(NSInteger)flag {
    NSUInteger idx = [self indexForFlag:flag];
    if ( idx == NSNotFound ) return;
    [_flags removeObjectAtIndex:idx];
}
- (nullable SJFlagObject *)objectForFlag:(NSInteger)flag {
    for ( SJFlagObject *obj in _flags ) {
        if ( obj.flag == flag ) return obj;
    }
    return nil;
}
- (nullable SJFlagObject *)objectAtIndex:(NSInteger)idx {
    if ( idx < 0 ) return nil;
    if ( idx > _flags.count ) return nil;
    return _flags[idx];
}
- (NSInteger)flagOfObjectAtIndex:(NSInteger)idx {
    return [self objectAtIndex:idx].flag;
}
- (NSUInteger)indexForFlag:(NSInteger)flag {
    for ( NSUInteger i = 0 ; i < _flags.count ; ++ i ) {
        if ( _flags[i].flag == flag ) return i;
    }
    return NSNotFound;
}
- (NSUInteger)indexOfObject:(SJFlagObject *)object{
    if ( !object ) return NSNotFound;
    return [_flags indexOfObject:object];
}
- (void)removeAllObjects {
    [_flags removeAllObjects];
}
@end

@interface SJFlagObject ()
@property (nonatomic, strong, nullable) UIImage *image;
@property (nonatomic, strong, nullable) id title;
@property (nonatomic, strong, nullable) id extra;
@end

@implementation SJFlagObject
- (instancetype)initWithFlag:(NSInteger)flag {
    self = [super init];
    if ( !self ) return nil;
    _flag = flag;
    return self;
}
@end
NS_ASSUME_NONNULL_END
