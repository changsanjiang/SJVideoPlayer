//
//  SJPageViewControllerItemCell.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/1/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageViewControllerItemCell.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJPageViewControllerItemCell
- (void)layoutSubviews {
    [super layoutSubviews];
    UIViewController *vc = _viewController;
    if ( vc != nil ) vc.view.frame = self.bounds;
}
@end
NS_ASSUME_NONNULL_END
