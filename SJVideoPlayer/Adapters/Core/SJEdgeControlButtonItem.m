//
//  SJEdgeControlButtonItem.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItem.h"
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN
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
    return self;
}

- (void)addTarget:(id)target action:(nonnull SEL)action {
    _target = target;
    _action = action;
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
