//
//  DemoTableViewCell.h
//  MJRefreshDemo
//
//  Created by BlueDancer on 2019/5/4.
//  Copyright © 2019 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol DemoTableViewCellDataSoruce, DemoTableViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface DemoTableViewCell : UITableViewCell
@property (nonatomic, weak, nullable) id<DemoTableViewCellDataSoruce> dataSource;
@property (nonatomic, weak, nullable) id<DemoTableViewCellDelegate> delegate;
@end

@protocol DemoTableViewCellDataSoruce
@property (nonatomic, readonly) NSInteger coverTag;
@property (nonatomic, copy, readonly, nullable) NSString *title;
@property (nonatomic, copy, readonly, nullable) NSString *coverURL;
@end

@protocol DemoTableViewCellDelegate
@optional
- (void)demoTableViewCell:(DemoTableViewCell *)cell clickedOnTheCover:(UIImageView *)cover;
@end
NS_ASSUME_NONNULL_END
