//
//  SJTableViewHeaderFooterView.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2019/1/8.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJPlayView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJTableViewHeaderFooterView : UITableViewHeaderFooterView
+ (void)registerWithTableView:(UITableView *)tableView;
+ (SJTableViewHeaderFooterView *)headerFooterViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong, readonly) SJPlayView *view;
@end

NS_ASSUME_NONNULL_END
