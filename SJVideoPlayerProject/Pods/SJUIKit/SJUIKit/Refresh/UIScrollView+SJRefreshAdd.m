//
//  UIScrollView+SJRefreshAdd.m
//  SJObjective-CTool_Example
//
//  Created by 畅三江 on 2016/5/28.
//  Copyright © 2018年 changsanjiang@gmail.com. All rights reserved.
//

#import "UIScrollView+SJRefreshAdd.h"
#import <objc/message.h>
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN
char const SJRefreshingNonePageSize = -1;

@interface SJRefreshConfig ()
- (void)configHeader:(MJRefreshGifHeader *)header;
- (void)configFooter:(MJRefreshAutoGifFooter *)footer;
@end

@implementation SJRefreshConfig
- (void)configHeader:(MJRefreshGifHeader *)header {
    header.gifView.image = self.gifImage_header;
    if ( self.textColor ) {
        header.stateLabel.textColor = self.textColor;
        header.lastUpdatedTimeLabel.textColor = self.textColor;
    }
}
- (void)configFooter:(MJRefreshAutoGifFooter *)footer {
    footer.gifView.image = self.gifImage_footer;
    if ( self.textColor ) footer.stateLabel.textColor = self.textColor;
}
@end

@implementation UIScrollView (SJRefreshAdd)

+ (void)setSj_refreshConfig:(nullable SJRefreshConfig *)sj_refreshConfig {
    objc_setAssociatedObject(self, @selector(sj_refreshConfig), sj_refreshConfig, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (nullable SJRefreshConfig *)sj_refreshConfig {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)sj_setupRefreshingWithRefreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    [self sj_setupRefreshingWithPageSize:SJRefreshingNonePageSize beginPageNum:0 refreshingBlock:refreshingBlock];
}

- (void)sj_setupRefreshingWithPageSize:(short)pageSize
                          beginPageNum:(NSInteger)beginPageNum
                       refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    __weak typeof(self) _self = self;
    self.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return ;
        refreshingBlock(self, self.sj_pageNum = self.sj_beginPageNum);
    }];
    
    // footer
    self.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
        __strong typeof(_self) self = _self;
        if ( !self ) return;
        refreshingBlock(self, self.sj_pageNum);
    }];
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.sj_pageSize = pageSize;
    self.sj_beginPageNum = beginPageNum;
    self.sj_pageNum = beginPageNum;
    self.mj_footer.hidden = YES;
    
    self.mj_header.ignoredScrollViewContentInsetTop = self.contentInset.top;
    
    [UIScrollView.sj_refreshConfig configHeader:(MJRefreshGifHeader *)self.mj_header];
    [UIScrollView.sj_refreshConfig configFooter:(MJRefreshAutoGifFooter *)self.mj_footer];
}

- (void)sj_endRefreshingWithItemCount:(NSUInteger)itemCount {
    if ( self.sj_pageNum == self.sj_beginPageNum ) {
        [self sj_endHeaderRefreshingWithItemCount:itemCount];
    }
    else {
        [self sj_endFooterRefreshingWithItemCount:itemCount];
    }
    self.sj_pageNum += 1;
}

- (void)sj_endRefreshing {
    if ( self.mj_header.state == MJRefreshStateRefreshing ) [self.mj_header endRefreshing];
    if ( self.mj_footer.state == MJRefreshStateRefreshing ) [self.mj_footer endRefreshing];
}

- (void)sj_endHeaderRefreshingWithItemCount:(NSUInteger)itemCount {
    [self.mj_header endRefreshing];
    if ( itemCount == 0 || itemCount == SJRefreshingNonePageSize ) { // 如果没有数据
        self.mj_footer.hidden = YES;
    }
    else {
        self.mj_footer.hidden = NO;
        if ( itemCount < self.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
        else  if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
    }
}

- (void)sj_endFooterRefreshingWithItemCount:(NSUInteger)itemCount {
    if ( itemCount < self.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
    else if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
    else [self.mj_footer endRefreshing];
}

- (void)sj_exeHeaderRefreshing {
    if ( self.mj_header.state != MJRefreshStateIdle ) [self.mj_header endRefreshing];
    [self.mj_header beginRefreshing];
}

- (void)sj_exeFooterRefreshing {
    if ( self.mj_footer.state != MJRefreshStateIdle ) [self.mj_footer endRefreshing];
    [self.mj_footer beginRefreshing];
}

#pragma mark -

- (void)setSj_beginPageNum:(NSInteger)sj_beginPageNum {
    objc_setAssociatedObject(self, @selector(sj_beginPageNum), @(sj_beginPageNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)sj_beginPageNum {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setSj_pageNum:(NSInteger)sj_pageNum {
    objc_setAssociatedObject(self, @selector(sj_pageNum), @(sj_pageNum), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)sj_pageNum {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setSj_pageSize:(NSInteger)sj_pageSize {
    objc_setAssociatedObject(self, @selector(sj_pageSize), @(sj_pageSize), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)sj_pageSize {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end

NS_ASSUME_NONNULL_END
