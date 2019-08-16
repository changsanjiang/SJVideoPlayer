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
@property (nonatomic) NSInteger sj_beginPageNum;
@property (nonatomic) NSInteger sj_pageSize;
@property (nonatomic) NSInteger sj_pageNum;

- (void)configHeader:(MJRefreshGifHeader *)header;
- (void)configFooter:(MJRefreshAutoGifFooter *)footer;
@end

@implementation SJRefreshConfig {
    BOOL _is_set;
    __weak UIScrollView *_scrollView;
}
- (instancetype)initWithScrollView:(__weak UIScrollView *)scrollView {
    self = [super init];
    if ( !self ) return nil;
    _scrollView = scrollView;
    return self;
}
- (void)configHeader:(MJRefreshGifHeader *)header {
    header.gifView.image = self.gifImage_header;
    if ( self.textColor ) {
        header.stateLabel.textColor = self.textColor;
        header.lastUpdatedTimeLabel.textColor = self.textColor;
    }
    header.ignoredScrollViewContentInsetTop = self.ignoredTopEdgeInset;
}
- (void)configFooter:(MJRefreshAutoGifFooter *)footer {
    footer.gifView.image = self.gifImage_footer;
    if ( self.textColor ) footer.stateLabel.textColor = self.textColor;
}

- (void)setIgnoredTopEdgeInset:(CGFloat)ignoredTopEdgeInset {
    _is_set = YES;
    _ignoredTopEdgeInset = ignoredTopEdgeInset;
}

@synthesize ignoredTopEdgeInset = _ignoredTopEdgeInset;
- (CGFloat)ignoredTopEdgeInset {
    if ( !_is_set ) return _scrollView.contentInset.top;
    return _ignoredTopEdgeInset;
}
@end

@implementation UIScrollView (SJPlaceholder)
- (SJPlaceholderView *)sj_placeholderView {
    SJPlaceholderView *_Nullable view = objc_getAssociatedObject(self, _cmd);
    if ( view == nil ) {
        view = [SJPlaceholderView new];
        [self addSubview:view];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1 constant:-self.mj_insetL]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1 constant:-64]];
        
        objc_setAssociatedObject(self, _cmd, view, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}
- (void)_showOrHiddenPlaceholderViewIfNeeded {
    UIView *_Nullable placeholderView = objc_getAssociatedObject(self, @selector(sj_placeholderView));
    if ( placeholderView != nil ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MJRefreshState headerState = self.mj_header.state;
            MJRefreshState footerState = self.mj_footer.state;
            if ( headerState == MJRefreshStateRefreshing || headerState == MJRefreshStateWillRefresh ||
                footerState == MJRefreshStateRefreshing || footerState == MJRefreshStateWillRefresh ) {
                placeholderView.hidden = YES;
            }
            else if ( [self isKindOfClass:[UITableView class]] ) {
                UITableView *_self = (id)self;
                placeholderView.hidden = (_self.visibleCells.count != 0);
            }
            else if ( [self isKindOfClass:[UICollectionView class]] ) {
                UICollectionView *_self = (id)self;
                placeholderView.hidden = (_self.visibleCells.count != 0);
            }
            else {
                placeholderView.hidden = NO;
            }
        });
    }
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


@implementation UIScrollView (SJSetupRefresh)
- (void)sj_setupRefreshingWithRefreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    [self _sj_setupRefreshingWithEnableHeader:YES
                                 enableFooter:NO
                                     pageSize:SJRefreshingNonePageSize
                                 beginPageNum:0
                              refreshingBlock:refreshingBlock];
}

- (void)sj_setupRefreshingWithPageSize:(short)pageSize
                          beginPageNum:(NSInteger)beginPageNum
                       refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    [self _sj_setupRefreshingWithEnableHeader:YES
                                 enableFooter:YES
                                     pageSize:pageSize
                                 beginPageNum:beginPageNum
                              refreshingBlock:refreshingBlock];
}
- (void)sj_setupFooterRefreshingWithPageSize:(short)pageSize beginPageNum:(NSInteger)beginPageNum refreshingBlock:(void (^)(__kindof UIScrollView * _Nonnull, NSInteger))refreshingBlock {
    [self _sj_setupRefreshingWithEnableHeader:NO
                                 enableFooter:YES
                                     pageSize:pageSize
                                 beginPageNum:beginPageNum
                              refreshingBlock:refreshingBlock];
}
- (void)_sj_setupRefreshingWithEnableHeader:(BOOL)enableHeader
                               enableFooter:(BOOL)enableFooter
                                   pageSize:(short)pageSize
                               beginPageNum:(NSInteger)beginPageNum
                            refreshingBlock:(void(^)(__kindof UIScrollView *scrollView, NSInteger pageNum))refreshingBlock {
    
    SJRefreshConfig *config = self.sj_refreshConfig;
    
    __weak typeof(self) _self = self;
    if ( enableHeader ) {
        self.mj_header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return ;
            refreshingBlock(self, config.sj_pageNum = config.sj_beginPageNum);
        }];
    }
    
    if ( enableFooter ) {
        self.mj_footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
            __strong typeof(_self) self = _self;
            if ( !self ) return;
            refreshingBlock(self, config.sj_pageNum);
        }];
    }
    
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    config.sj_pageSize = pageSize;
    if ( 0 != beginPageNum ) config.sj_beginPageNum = beginPageNum;
    config.sj_pageNum = beginPageNum;
    self.mj_footer.hidden = YES;
    
    [UIScrollView.sj_commonConfig configHeader:(MJRefreshGifHeader *)self.mj_header];
    [UIScrollView.sj_commonConfig configFooter:(MJRefreshAutoGifFooter *)self.mj_footer];
    [config configHeader:(MJRefreshGifHeader *)self.mj_header];
    [config configFooter:(MJRefreshAutoGifFooter *)self.mj_footer];
}

- (void)sj_endRefreshingWithItemCount:(NSUInteger)itemCount {
    [self sj_endRefreshing];
    SJRefreshConfig *config = self.sj_refreshConfig;
    
    /// header
    if ( config.sj_pageNum == config.sj_beginPageNum && self.mj_header ) {
        if ( itemCount == 0 || itemCount == SJRefreshingNonePageSize ) { // 如果没有数据
            self.mj_footer.hidden = YES;
        }
        else {
            self.mj_footer.hidden = NO;
            if ( itemCount < config.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
            else  if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
        }
    }
    /// footer
    else {
        if ( itemCount < config.sj_pageSize ) [self.mj_footer endRefreshingWithNoMoreData];   // 如果数据小于pageSize
        else if ( self.mj_footer.state == MJRefreshStateNoMoreData ) [self.mj_footer resetNoMoreData];
        else [self.mj_footer endRefreshing];
    }
    config.sj_pageNum += 1;
}

- (void)sj_endRefreshing {
    if ( self.mj_header.state == MJRefreshStateRefreshing ) [self.mj_header endRefreshing];
    if ( self.mj_footer.state == MJRefreshStateRefreshing ) [self.mj_footer endRefreshing];
    [self _showOrHiddenPlaceholderViewIfNeeded];
}

- (void)sj_exeHeaderRefreshing {
    [self sj_exeHeaderRefreshingAnimated:YES];
}

- (void)sj_exeHeaderRefreshingAnimated:(BOOL)animated {
    if ( self.mj_header.state == MJRefreshStateRefreshing ) {
        return;
    }
    if ( self.mj_header.state != MJRefreshStateIdle ) [self.mj_header endRefreshing];
    if ( animated ) {
        [self.mj_header beginRefreshing];
    }
    else {
        if ( self.mj_header.refreshingBlock != nil ) self.mj_header.refreshingBlock();
    }
    
    [self _showOrHiddenPlaceholderViewIfNeeded];
}

- (void)sj_exeFooterRefreshing {
    if ( self.mj_footer.state == MJRefreshStateRefreshing ) {
        return;
    }
    self.mj_footer.hidden = NO;
    if ( self.mj_footer.state != MJRefreshStateIdle ) [self.mj_footer endRefreshing];
    [self.mj_footer beginRefreshing];
    [self _showOrHiddenPlaceholderViewIfNeeded];
}

- (void)sj_resetState {
    self.mj_footer.hidden = YES;
    [self _showOrHiddenPlaceholderViewIfNeeded];
}

- (void)setSj_beginPageNum:(NSInteger)sj_beginPageNum {
    self.sj_refreshConfig.sj_beginPageNum = sj_beginPageNum;
}

- (NSInteger)sj_beginPageNum {
    return self.sj_refreshConfig.sj_beginPageNum;
}

- (void)setSj_pageNum:(NSInteger)sj_pageNum {
    self.sj_refreshConfig.sj_pageNum = sj_pageNum;
}

- (NSInteger)sj_pageNum {
    return self.sj_refreshConfig.sj_pageNum;
}

- (void)setSj_pageSize:(NSInteger)sj_pageSize {
    self.sj_refreshConfig.sj_pageSize = sj_pageSize;
}

- (NSInteger)sj_pageSize {
    return self.sj_refreshConfig.sj_pageSize;
}

@end

@implementation UIScrollView (SJRefreshUIConfig)
+ (SJRefreshConfig *)sj_commonConfig {
    static SJRefreshConfig *config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [SJRefreshConfig new];
    });
    return config;
}

- (SJRefreshConfig *)sj_refreshConfig {
    SJRefreshConfig *config = objc_getAssociatedObject(self, _cmd);
    if ( config ) return config;
    config = [SJRefreshConfig new];
    unsigned int count = 0;
    objc_property_t *list = class_copyPropertyList([SJRefreshConfig class], &count);
    SJRefreshConfig *common = UIScrollView.sj_commonConfig;
    if (list != NULL && count > 0) {
        for ( int i = 0; i < count; ++i ) {
            objc_property_t property_t = list[i];
            const char *name  = property_getName(property_t);
            NSString *property = [NSString stringWithUTF8String:name];
            [config setValue:[common valueForKey:property] forKey:property];
        }
        free(list);
    }
    objc_setAssociatedObject(self, _cmd, config, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return config;
}
@end
NS_ASSUME_NONNULL_END
