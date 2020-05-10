//
//  SJVideoTableViewCell.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/6/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SJVideoTableViewCellDataSource, SJVideoTableViewCellDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoTableViewCell : UITableViewCell
+ (void)registerWithTableView:(UITableView *)tableView;
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, weak, nullable) id<SJVideoTableViewCellDataSource> dataSource;
@property (nonatomic, weak, nullable) id<SJVideoTableViewCellDelegate> delegate;
@end

@protocol SJVideoTableViewCellDataSource
@property (nonatomic, copy, readonly, nullable) NSString *cover;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *mediaTitle;
@property (nonatomic, copy, readonly, nullable) NSString *avatar;
@property (nonatomic, copy, readonly, nullable) NSAttributedString *username;
@end

@protocol SJVideoTableViewCellDelegate
- (void)coverItemWasTapped:(SJVideoTableViewCell *)cell;
@end
NS_ASSUME_NONNULL_END
