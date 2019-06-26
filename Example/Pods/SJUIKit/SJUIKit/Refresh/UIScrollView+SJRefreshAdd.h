//
//  UIScrollView+SJRefreshAdd.h
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 此size用于标记请求不需要pageSize
/// 当不需要页码大小时, 可以传入此size
extern char const SJRefreshingNonePageSize;
@class SJRefreshConfig, SJPlaceholderView;

NS_ASSUME_NONNULL_BEGIN
@interface UIScrollView (SJSetupRefresh)
@property (nonatomic, readonly) NSInteger sj_beginPageNum;
@property (nonatomic, readonly) NSInteger sj_pageSize;
@property (nonatomic, readonly) NSInteger sj_pageNum;   // current PageNum

- (void)sj_setupRefreshingWithRefreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger requestPageNum))refreshingBlock;

- (void)sj_setupRefreshingWithPageSize:(short)pageSize
                          beginPageNum:(NSInteger)beginPageNum
                       refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger requestPageNum))refreshingBlock;

- (void)sj_setupFooterRefreshingWithPageSize:(short)pageSize
                                beginPageNum:(NSInteger)beginPageNum
                             refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger requestPageNum))refreshingBlock;

- (void)sj_endRefreshing;
- (void)sj_endRefreshingWithItemCount:(NSUInteger)itemCount;

///

- (void)sj_exeHeaderRefreshing;
- (void)sj_exeHeaderRefreshingAnimated:(BOOL)animated;
- (void)sj_exeFooterRefreshing;

- (void)sj_resetState;
@end

@interface UIScrollView (SJRefreshUIConfig)
@property (class, nonatomic, strong, readonly) SJRefreshConfig *sj_commonConfig;
@property (nonatomic, strong, readonly) SJRefreshConfig *sj_refreshConfig;
@end

@interface SJRefreshConfig : NSObject
- (instancetype)initWithScrollView:(__weak UIScrollView *)scrollView;
@property (nonatomic, strong, nullable) UIColor *textColor;
@property (nonatomic, strong, nullable) UIImage *gifImage_header;
@property (nonatomic, strong, nullable) UIImage *gifImage_footer;
@property (nonatomic) CGFloat ignoredTopEdgeInset;
@end

@interface UIScrollView (SJPlaceholder)
@property (nonatomic, strong, readonly) SJPlaceholderView  *sj_placeholderView;
@end

@interface SJPlaceholderView : UIControl
@property (nonatomic, strong, readonly) UILabel *label;
@property (nonatomic) UIEdgeInsets insets;
@property (nonatomic, copy, nullable) void(^clickedBackgroundExeBlock)(SJPlaceholderView *view);
@end
NS_ASSUME_NONNULL_END
