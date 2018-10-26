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
@implementation SJEdgeControlButtonItem
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
    item.placeholderType = placeholderType;
    if ( placeholderType == SJButtonItemPlaceholderType_49xFill ) item.fill = YES;
    return item;
}
+ (instancetype)placeholderWithSize:(CGFloat)size tag:(SJEdgeControlButtonItemTag)tag {
    SJEdgeControlButtonItem *item = [[SJEdgeControlButtonItem alloc] initWithTag:tag];
    item.placeholderType = SJButtonItemPlaceholderType_49xSpecifiedSize;
    item.size = size;
    return item;
}
- (void)setPlaceholderType:(SJButtonItemPlaceholderType)placeholderType {
    objc_setAssociatedObject(self, @selector(placeholderType), @(placeholderType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJButtonItemPlaceholderType)placeholderType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setSize:(CGFloat)size {
    objc_setAssociatedObject(self, @selector(size), @(size), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)size {
    return (CGFloat)[objc_getAssociatedObject(self, _cmd) doubleValue];
}
@end
NS_ASSUME_NONNULL_END
