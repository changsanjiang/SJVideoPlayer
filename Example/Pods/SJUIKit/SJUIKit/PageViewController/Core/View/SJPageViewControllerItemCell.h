//
//  SJPageViewControllerItemCell.h
//  SJPageViewController_Example
//
//  Created by 畅三江 on 2020/1/10.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJPageViewControllerItemCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJPageViewControllerItemCell : UICollectionViewCell
@property (nonatomic, weak, nullable) id<SJPageViewControllerItemCellDelegate> delegate;
@property (nonatomic, weak, nullable) __kindof UIViewController *item;
@end

typedef NSString *SJItemChangeKey;
extern SJItemChangeKey const SJItemChangeKeyNewKey;
extern SJItemChangeKey const SJItemChangeKeyOldKey;

@protocol SJPageViewControllerItemCellDelegate <NSObject>
- (void)pageViewControllerItemCell:(SJPageViewControllerItemCell *)cell itemDidChange:(nullable NSDictionary<SJItemChangeKey, UIViewController *> *)change;

- (void)pageViewControllerItemCellDidLayoutSubviews:(SJPageViewControllerItemCell *)cell;
@end
NS_ASSUME_NONNULL_END
