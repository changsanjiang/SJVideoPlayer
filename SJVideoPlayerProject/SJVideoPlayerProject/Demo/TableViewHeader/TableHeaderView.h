//
//  TableHeaderView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/27.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TableHeaderView : UIView

@property (nonatomic, copy, readwrite, nullable) void(^clickedPlayBtn)(TableHeaderView *view);

@end

NS_ASSUME_NONNULL_END
