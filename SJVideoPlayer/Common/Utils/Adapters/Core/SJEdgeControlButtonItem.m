//
//  SJEdgeControlButtonItem.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItem.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
NSNotificationName const SJEdgeControlButtonItemPerformedActionNotification = @"SJEdgeControlButtonItemPerformedActionNotification";

@implementation SJEdgeControlButtonItem {
    SJButtonItemPlaceholderType _placeholderType;
    CGFloat _size;
    BOOL _isFrameLayout;
    NSMutableArray<SJEdgeControlButtonItemAction *> *_Nullable _actions;
}
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _title = title;
    if ( target != nil && action != NULL ) {
        [self addAction:[SJEdgeControlButtonItemAction actionWithTarget:target action:action]];
    }
    return self;
}
- (instancetype)initWithImage:(nullable UIImage *)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _image = image;
    if ( target != nil && action != NULL ) {
        [self addAction:[SJEdgeControlButtonItemAction actionWithTarget:target action:action]];
    }
    return self;
}
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(SJEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _customView = customView;
    return self;
}
- (instancetype)initWithTag:(NSInteger)tag {
    self = [super init];
    if ( !self ) return nil;
    _tag = tag;
    _numberOfLines = 1;
    _alpha = 1;
    return self;
}

- (nullable NSArray<SJEdgeControlButtonItemAction *> *)actions {
    return _actions.count != 0 ? _actions : nil;
}

- (void)addAction:(SJEdgeControlButtonItemAction *)action {
    if ( action != nil ) {
        if ( _actions == nil ) {
            _actions = NSMutableArray.array;
        }
        [_actions addObject:action];
    }
}

- (void)removeAction:(SJEdgeControlButtonItemAction *)action {
    if ( action != nil )
        [_actions removeObject:action];
}

- (void)removeAllActions {
    [_actions removeAllObjects];
}

- (void)performActions {
    for ( SJEdgeControlButtonItemAction *action in _actions ) {
        if ( action.handler != nil ) {
            action.handler(action);
        }
        else if ( [action.target respondsToSelector:action.action] ) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [action.target performSelector:action.action withObject:self];
#pragma clang diagnostic pop
        }
    }
    [NSNotificationCenter.defaultCenter postNotificationName:SJEdgeControlButtonItemPerformedActionNotification object:self];
}
@end


@implementation SJEdgeControlButtonItem(Placeholder)
+ (instancetype)placeholderWithType:(SJButtonItemPlaceholderType)placeholderType tag:(SJEdgeControlButtonItemTag)tag {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTag:tag];
    item->_placeholderType = placeholderType;
    if ( placeholderType == SJButtonItemPlaceholderType_49xFill ) item.fill = YES;
    return item;
}
+ (instancetype)placeholderWithSize:(CGFloat)size tag:(SJEdgeControlButtonItemTag)tag {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTag:tag];
    item->_placeholderType = SJButtonItemPlaceholderType_49xSpecifiedSize;
    item.size = size;
    return item;
}
- (SJButtonItemPlaceholderType)placeholderType {
    return _placeholderType;
}
- (void)setSize:(CGFloat)size {
    _size = size;
}
- (CGFloat)size {
    return _size;
}
@end


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@implementation SJEdgeControlButtonItem(SJDeprecated)
- (void)addTarget:(id)target action:(nonnull SEL)action {
    [self removeAllActions];
    [self addAction:[SJEdgeControlButtonItemAction actionWithTarget:target action:action]];
}

- (void)performAction {
    [self performActions];
}
@end
#pragma clang diagnostic pop

@implementation SJEdgeControlButtonItem(FrameLayout)
+ (instancetype)frameLayoutWithCustomView:(__kindof UIView *)customView tag:(SJEdgeControlButtonItemTag)tag {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithCustomView:customView tag:tag];
    item->_isFrameLayout = YES;
    return item;
}
- (BOOL)isFrameLayout {
    return _isFrameLayout;
}
@end

@implementation SJEdgeControlButtonItemAction
+ (instancetype)actionWithTarget:(id)target action:(SEL)action {
    return [[self alloc] initWithTarget:target action:action];
}

+ (instancetype)actionWithHandler:(void(^)(SJEdgeControlButtonItemAction *action))handler {
    return [[self alloc] initWithHandler:handler];
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if ( self ) {
        _target = target;
        _action = action;
    }
    return self;
}
- (instancetype)initWithHandler:(void(^)(SJEdgeControlButtonItemAction *action))handler {
    self = [super init];
    if ( self ) {
        _handler = handler;
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
