//
//  UIScrollView+SJRefreshAdd.h
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 此size用于标记请求不需要pageSize
/// 当不需要页码大小时, 可以传入此size
extern char const SJRefreshingNonePageSize;

@class SJRefreshConfig;

@interface UIScrollView (SJRefreshAdd)

@property (class, nonatomic, strong, nullable) SJRefreshConfig *sj_refreshConfig;

/// 配置刷新
/// 该方法只配置 header 刷新(当只有下拉刷新的时候使用)
- (void)sj_setupRefreshingWithRefreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock;
/// 配置刷新
/// 该方法配置 header 和 footer 刷新
- (void)sj_setupRefreshingWithPageSize:(short)pageSize
                          beginPageNum:(NSInteger)beginPageNum
                       refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock;

/// 执行 header 刷新
- (void)sj_exeHeaderRefreshing;
/// 执行 footer 刷新
- (void)sj_exeFooterRefreshing;
/// 结束刷新
/// 传入的count将会与`sj_pageSize`比较, 刷新footer的状态(有无更多数据)
- (void)sj_endRefreshingWithItemCount:(NSUInteger)itemCount;
/// 结束刷新
- (void)sj_endRefreshing;


#pragma mark -
/// 开始页
@property (nonatomic, readonly) NSInteger sj_beginPageNum;
/// 页码的size, 该size用于footer的状态控制.
/// 如果 结束刷新(sj_endRefreshingWithItemCount:)传入的size, 小于该size, 则将footer的状态设置为 noMoreData.
@property (nonatomic, readonly) NSInteger sj_pageSize;
/// 当前页
@property (nonatomic, readonly) NSInteger sj_pageNum;

@end



@interface SJRefreshConfig : NSObject

@property (nonatomic, strong, nullable) UIColor *textColor;

#pragma mark header
@property (nonatomic, strong, nullable) UIImage *gifImage_header;



#pragma mark footer
@property (nonatomic, strong, nullable) UIImage *gifImage_footer;
@end

NS_ASSUME_NONNULL_END
