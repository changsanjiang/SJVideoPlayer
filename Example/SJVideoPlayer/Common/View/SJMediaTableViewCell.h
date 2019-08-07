//
//  SJMediaTableViewCell.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJMediaTableViewCellDataSource, SJMediaTableViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJMediaTableViewCell : UITableViewCell
+ (void)registerWithTableView:(UITableView *)tableView;
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak, nullable) id<SJMediaTableViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJMediaTableViewCellDelegate> delegate;
@end

@protocol SJMediaTableViewCellDataSource
@property (nonatomic, readonly) NSInteger coverTag;
@property (nonatomic, copy, readonly, nullable) NSString *cover;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, readonly, nullable) NSString *avatar;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *username;
@end

@protocol SJMediaTableViewCellDelegate
- (void)tappedCoverOnTheTableViewCell:(SJMediaTableViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
