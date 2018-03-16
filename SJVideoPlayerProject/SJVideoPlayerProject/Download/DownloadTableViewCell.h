//
//  DownloadTableViewCell.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class  SJVideo;

@interface DownloadTableViewCell : UITableViewCell

+ (CGFloat)height;

@property (nonatomic, strong) SJVideo *model;

@end
NS_ASSUME_NONNULL_END
