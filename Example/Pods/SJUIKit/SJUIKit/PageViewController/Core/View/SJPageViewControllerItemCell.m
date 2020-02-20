//
//  SJPageViewControllerItemCell.m
//  SJPageViewController_Example
//
//  Created by 畅三江 on 2020/1/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageViewControllerItemCell.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPageViewControllerItemCell {
    NSMutableDictionary *_m;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _m = [NSMutableDictionary dictionaryWithCapacity:2];
    }
    return self;
}

- (void)setItem:(nullable __kindof UIViewController *)item {
    if ( _item != item ) {
        UIViewController *_Nullable oldValue = _item;
        UIViewController *_Nullable newValue = item;
        _item = item;
        _m[SJItemChangeKeyOldKey] = oldValue;
        _m[SJItemChangeKeyNewKey] = newValue;
        [self.delegate pageViewControllerItemCell:self itemDidChange:_m];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.delegate pageViewControllerItemCellDidLayoutSubviews:self];
}

SJItemChangeKey const SJItemChangeKeyNewKey = @"new";
SJItemChangeKey const SJItemChangeKeyOldKey = @"old";
@end
NS_ASSUME_NONNULL_END
