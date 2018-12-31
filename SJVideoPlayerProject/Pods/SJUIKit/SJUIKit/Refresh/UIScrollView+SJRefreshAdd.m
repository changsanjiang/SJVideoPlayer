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
    [self _sj_setupRefreshingWithEnableHeader:YES enableFooter:NO pageSize:SJRefreshingNonePageSize beginPageNum:0 refreshingBlock:refreshingBlock];
}

- (void)sj_setupRefreshingWithPageSize:(short)pageSize
                          beginPageNum:(NSInteger)beginPageNum
                       refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    [self _sj_setupRefreshingWithEnableHeader:YES enableFooter:YES pageSize:pageSize beginPageNum:beginPageNum refreshingBlock:refreshingBlock];
}
- (void)sj_setupFooterRefreshingWithPageSize:(short)pageSize beginPageNum:(NSInteger)beginPageNum refreshingBlock:(void (^)(__kindof UIScrollView * _Nonnull, NSInteger))refreshingBlock {
    [self _sj_setupRefreshingWithEnableHeader:NO enableFooter:YES pageSize:pageSize beginPageNum:beginPageNum refreshingBlock:refreshingBlock];
}
- (void)_sj_setupRefreshingWithEnableHeader:(BOOL)enableHeader
                               enableFooter:(BOOL)enableFooter
                                   pageSize:(short)pageSize
                               beginPageNum:(NSInteger)beginPageNum
                            refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    __weak typeof(self) _self = self;
    if ( enableHeader ) {
        self.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            refreshingBlock(self, self.sj_pageNum = self.sj_beginPageNum);
        }];
    }
    
    if ( enableFooter ) {
        self.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            refreshingBlock(self, self.sj_pageNum);
        }];
    }
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.sj_pageSize = pageSize;
    if ( 0 != beginPageNum ) self.sj_beginPageNum = beginPageNum;
    self.sj_pageNum = beginPageNum;
    self.mj_footer.hidden = YES;
    
    self.mj_header.ignoredScrollViewContentInsetTop = self.contentInset.top;
    
    [UIScrollView.sj_refreshConfig configHeader:(MJRefreshGifHeader *)self.mj_header];
    [UIScrollView.sj_refreshConfig configFooter:(MJRefreshAutoGifFooter *)self.mj_footer];
}

- (void)sj_endRefreshingWithItemCount:(NSUInteger)itemCount {
    [self sj_endRefreshing];

    /// header
    if ( self.sj_pageNum == self.sj_beginPageNum && self.mj_header ) {
        if ( itemCount == 0 || itemCount == SJRefreshingNonePageSize ) { // 如果没有数据
            self.mj_footer.hidden = YES;
        }
        else {
            self.mj_footer.hidden = NO;
            if ( itemCount < self.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
            else  if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
        }
    }
    /// footer
    else {
        if ( itemCount < self.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
        else if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
        else [self.mj_footer endRefreshing];
    }
    self.sj_pageNum += 1;
    [self _considerHiddenPlaceholder];
}

- (void)sj_endRefreshing {
    if ( self.mj_header.state == MJRefreshStateRefreshing ) [self.mj_header endRefreshing];
    if ( self.mj_footer.state == MJRefreshStateRefreshing ) [self.mj_footer endRefreshing];
    [self _considerHiddenPlaceholder];
}

- (void)sj_exeHeaderRefreshing {
    [self sj_exeHeaderRefreshingAnimated:YES];
}

- (void)sj_exeHeaderRefreshingAnimated:(BOOL)animated {
    if ( self.mj_header.state != MJRefreshStateIdle ) [self.mj_header endRefreshing];
    if ( animated ) {
        [self.mj_header beginRefreshing];
    }
    else {
        if ( self.mj_header.refreshingBlock != nil ) self.mj_header.refreshingBlock();
    }
}

- (void)sj_exeFooterRefreshing {
    self.mj_footer.hidden = NO;
    if ( self.mj_footer.state != MJRefreshStateIdle ) [self.mj_footer endRefreshing];
    [self.mj_footer beginRefreshing];
    [self _considerHiddenPlaceholder];
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

- (void)_considerHiddenPlaceholder {
    UIView *placeholderView = objc_getAssociatedObject(self, @selector(sj_placeholderView));
    if ( !placeholderView ) return;
    
    if ( [self isKindOfClass:[UITableView class]] ) {
        UITableView *_self = (id)self;
        for ( int i = 0 ; i < _self.numberOfSections ; ++ i ) {
            NSInteger rows = [_self numberOfRowsInSection:i];
            if ( 0 == rows ) continue;
            placeholderView.hidden = YES;
            return;
        }
    }
    else if ( [self isKindOfClass:[UICollectionView class]] ) {
        UICollectionView *_self = (id)self;
        for ( int i = 0 ; i < _self.numberOfSections ; ++ i ) {
            NSInteger items = [_self numberOfItemsInSection:i];
            if ( 0 == items ) continue;
            placeholderView.hidden = YES;
            return;
        }
    }

    placeholderView.hidden = NO;
}

@end

@implementation UIScrollView (SJPlaceholder)
- (SJPlaceholderView *)sj_placeholderView {
    SJPlaceholderView *view = objc_getAssociatedObject(self, _cmd);
    if ( !view ) view = [SJPlaceholderView new];
    objc_setAssociatedObject(self, @selector(sj_placeholderView), view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addSubview:view];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    return view;
}
@end


@implementation SJPlaceholderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self addTarget:self action:@selector(clickedBackground:) forControlEvents:UIControlEventTouchUpInside];
    return self;
}

- (void)clickedBackground:(UIButton *)btn {
    if ( _clickedBackgroundExeBlock ) _clickedBackgroundExeBlock(self);
}

- (void)setInsets:(UIEdgeInsets)insets {
    if ( UIEdgeInsetsEqualToEdgeInsets(insets, _insets) ) return;
    _insets = insets;
    [self _needRefreshLabelConstraints:insets];
}

@synthesize label = _label;
- (UILabel *)label {
    if ( _label ) return _label;
    _label = [UILabel new];
    [self addSubview:_label];
    [self _needRefreshLabelConstraints:_insets];
    return _label;
}

- (void)_needRefreshLabelConstraints:(UIEdgeInsets)insets {
    if ( !_label ) return;
    [self.constraints enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(__kindof NSLayoutConstraint * _Nonnull cons, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( cons.secondItem != self->_label && cons.firstItem != self->_label ) return ;
        [self removeConstraint:cons];
    }];
    
    self->_label.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%lf-[_label]-%lf-|", (double)insets.top, (double)insets.bottom] options:NSLayoutFormatAlignAllLeading metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%lf-[_label]-%lf-|", (double)insets.left, (double)insets.right] options:NSLayoutFormatAlignAllLeading metrics:nil views:NSDictionaryOfVariableBindings(_label)]];
}

@end
NS_ASSUME_NONNULL_END
