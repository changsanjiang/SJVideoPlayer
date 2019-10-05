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
}
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _title = title;
    _target = target;
    _action = action;
    return self;
}
- (instancetype)initWithImage:(nullable UIImage *)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [self initWithTag:tag];
    if ( !self ) return nil;
    _image = image;
    _target = target;
    _action = action;
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
    return self;
}

- (void)addTarget:(id)target action:(nonnull SEL)action {
    _target = target;
    _action = action;
}

- (void)performAction {
    if ( !_action ) return;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if ( [_target respondsToSelector:_action] ) {
        [_target performSelector:_action withObject:self];
        [NSNotificationCenter.defaultCenter postNotificationName:SJEdgeControlButtonItemPerformedActionNotification object:self];
    }
#pragma clang diagnostic pop
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
NS_ASSUME_NONNULL_END
