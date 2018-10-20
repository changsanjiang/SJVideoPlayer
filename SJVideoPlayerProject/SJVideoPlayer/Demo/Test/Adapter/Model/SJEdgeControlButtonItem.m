//
//  SJEdgeControlButtonItem.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/19.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJEdgeControlButtonItem
- (instancetype)initWithTitle:(nullable NSAttributedString *)title
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _target = target;
    _action = action;
    _tag = tag;
    return self;
}
- (instancetype)initWithImage:(nullable UIImage *)image
                       target:(nullable id)target
                       action:(nullable SEL)action
                          tag:(SJEdgeControlButtonItemTag)tag {
    self = [super init];
    if ( !self ) return nil;
    _image = image;
    _target = target;
    _action = action;
    _tag = tag;
    return self;
}
- (instancetype)initWithCustomView:(nullable __kindof UIView *)customView
                               tag:(SJEdgeControlButtonItemTag)tag {
    self = [super init];
    if ( !self ) return nil;
    _customView = customView;
    _tag = tag;
    return self;
}
@end
NS_ASSUME_NONNULL_END
