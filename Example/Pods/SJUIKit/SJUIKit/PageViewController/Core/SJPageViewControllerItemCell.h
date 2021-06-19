//
//  SJPageViewControllerItemCell.h
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/1/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJPageViewControllerItemCell : UICollectionViewCell
@property (nonatomic, weak, nullable) __kindof UIViewController *viewController;
@end
NS_ASSUME_NONNULL_END
