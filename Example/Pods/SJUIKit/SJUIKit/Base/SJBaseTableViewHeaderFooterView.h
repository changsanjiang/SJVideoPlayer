//
//  SJBaseTableViewHeaderFooterView.h
//  AFNetworking
//
//  Created by BlueDancer on 2018/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJBaseTableViewHeaderFooterView : UITableViewHeaderFooterView
+ (void)registerWithTableView:(UITableView *)tableView;
+ (__kindof SJBaseTableViewHeaderFooterView *)reusableViewWithTableView:(UITableView *)tableView;
@end
NS_ASSUME_NONNULL_END
