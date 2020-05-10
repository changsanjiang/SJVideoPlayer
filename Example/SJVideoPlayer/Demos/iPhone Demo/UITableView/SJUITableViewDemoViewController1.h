//
//  SJUITableViewDemoViewController1.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/5/10.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJVideoPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJUITableViewDemoViewController1 : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong, readonly) UITableView *tableView;
@property (nonatomic, strong, nullable) SJVideoPlayer *player;
@end

NS_ASSUME_NONNULL_END
