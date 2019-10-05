//
//  SJBaseTableViewCell.h
//  LWZBaseViews_Example
//
//  Created by 畅三江 on 2018/12/11.
//  Copyright © 2018 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseTableViewCell : UITableViewCell
+ (void)registerWithTableView:(UITableView *)tableView;
+ (instancetype)cellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
@end
NS_ASSUME_NONNULL_END
