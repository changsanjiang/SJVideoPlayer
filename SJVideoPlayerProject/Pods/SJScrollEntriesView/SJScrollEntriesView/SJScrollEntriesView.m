//
//  SJScrollEntriesView.m
//  SJScrollEntriesViewProject
//
//  Created by BlueDancer on 2017/9/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJScrollEntriesView.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollEntriesView ()
@property (nonatomic, strong, nullable) NSArray<UIButton *> *buttonItemsArr;
@property (nonatomic, strong) SJScrollEntriesViewSettings *settings;
@property (nonatomic, strong, readonly) UIView *lineContainerView;
@property (nonatomic, strong, readonly) UIView *lineView;
@end

@implementation SJScrollEntriesView
@synthesize scrollView = _scrollView;
@synthesize lineContainerView = _lineContainerView;
@synthesize lineView = _lineView;

- (instancetype)initWithSettings:(nullable SJScrollEntriesViewSettings *)settings {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    if ( settings == nil ) settings = [SJScrollEntriesViewSettings defaultSettings];
    self.settings = settings;
    [self _setupViews];
    return self;
}

- (NSInteger)currentIndex {
    for ( UIButton *btn in self.buttonItemsArr ) {
        if ( btn.selected ) return btn.tag;
    }
    return 0;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.settings.scrollViewMaxWidth, 44);
}


- (void)clickedBtn:(UIButton *)btn {
    [self changeIndex:btn.tag];
}

- (void)changeIndex:(NSInteger)index {
    if ( _items.count == 0 ) return;
    if ( index > self.buttonItemsArr.count ) return;
    if ( index < 0 ) return;
    NSInteger currentIndex = self.currentIndex;
    if ( index == self.currentIndex ) return;
    
    NSInteger oldValue = currentIndex;
    NSInteger newValue = index;
    UIButton *before = self.buttonItemsArr[oldValue];
    UIButton *target = self.buttonItemsArr[newValue];
    [self _needScrollForButton:target animated:YES];
    [self _needRefreshLinePositionForButton:target animated:YES];
    [self _needResetButton:before selectWithButton:target animated:YES];
    
    if ( [self.delegate respondsToSelector:@selector(scrollEntriesView:currentIndex:beforeIndex:)] ) {
        [self.delegate scrollEntriesView:self currentIndex:target.tag beforeIndex:before.tag];
    }
}

- (void)setItems:(nullable NSArray<id<SJScrollEntriesViewUserProtocol>> *)items {
    _items = items;
    [self _removeAllButtonItems];
    _buttonItemsArr = [self _createButtonItems:items];
    [self _addButtonItemsToScrollView:_buttonItemsArr];
    [self _needResetButton:nil selectWithButton:self.buttonItemsArr.firstObject animated:NO];
    [self _needRefreshLinePositionForButton:self.buttonItemsArr.firstObject animated:NO];
}

- (void)_needScrollForButton:(UIButton *)btn animated:(BOOL)animated {
    CGFloat half = CGRectGetWidth(self.frame) * 0.5;
    CGFloat offsetX = btn.center.x - half;
    if ( offsetX > _scrollView.contentSize.width - CGRectGetWidth(self.frame) ) offsetX = _scrollView.contentSize.width - CGRectGetWidth(self.frame);
    if ( offsetX < 0 ) offsetX = 0;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:animated];
}

- (void)_needResetButton:(nullable UIButton *)oldSelBtn selectWithButton:(nullable UIButton *)selBtn animated:(BOOL)animated {
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        if ( oldSelBtn ) {
            oldSelBtn.selected = NO;
            oldSelBtn.titleLabel.font = [UIFont systemFontOfSize:self.settings.fontSize];
            oldSelBtn.transform = CGAffineTransformIdentity;
        }

        if ( selBtn ) {
            selBtn.selected = YES;
            selBtn.titleLabel.font = [UIFont boldSystemFontOfSize:self.settings.fontSize];
            selBtn.transform = CGAffineTransformMakeScale(self.settings.itemScale, self.settings.itemScale);
        }
    }];
}

- (void)_needRefreshLinePositionForButton:(UIButton *)btn animated:(BOOL)animated {
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(btn);
        make.width.equalTo(btn).multipliedBy(self.settings.lineScale);
        make.bottom.offset(0);
        make.height.offset(self.settings.lineHeight);
    }];
    
    if ( animated ) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.lineContainerView layoutIfNeeded];
        }];
    }
}

- (void)_addButtonItemsToScrollView:(NSArray<UIButton *> *)items {
    if ( 0 == items.count ) return;
    
    // calculate width
    __block CGFloat realMaxWidth = 0;
    NSMutableArray<NSNumber *> *itemsWidthM = [NSMutableArray array];
    [_items enumerateObjectsUsingBlock:^(id<SJScrollEntriesViewUserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = [self sizeForTitle:obj.title size:CGSizeMake(CGFLOAT_MAX, 44)].width + self.settings.itemSpacing;
        realMaxWidth += width;
        [itemsWidthM addObject:@(width)];
    }];
    
    if ( realMaxWidth < _settings.scrollViewMaxWidth ) {
        [itemsWidthM removeAllObjects];
        CGFloat width = _settings.scrollViewMaxWidth / _items.count;
        realMaxWidth = _items.count * width;
        [_items enumerateObjectsUsingBlock:^(id<SJScrollEntriesViewUserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [itemsWidthM addObject:@(width)];
        }];
    }
    
    // constraints
    [items enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.scrollView addSubview:obj];
        CGFloat width = [itemsWidthM[idx] floatValue];
        if ( idx == 0 ) {
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.leading.offset(0);
                make.bottom.equalTo(self);
                make.width.offset(width);
            }];
        }
        else {
            UIButton *beforeObj = items[idx - 1];
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(beforeObj);
                make.width.offset(width);
                make.leading.equalTo(beforeObj.mas_trailing);
            }];
        }
    }];
    
    // set content width
    CGSize contentSize = _scrollView.contentSize;
    contentSize.width = realMaxWidth;
    _scrollView.contentSize = contentSize;
}

- (CGSize)sizeForTitle:(NSString *)title size:(CGSize)size {
    CGSize result;
    if ( [title respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)] ) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = [UIFont systemFontOfSize:self.settings.fontSize];
        CGRect rect = [title boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [title sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
    }
    return result;
}

- (NSArray<UIButton *> *)_createButtonItems:(NSArray<id<SJScrollEntriesViewUserProtocol>> *)items {
    NSMutableArray<UIButton *> *itemsM = [NSMutableArray new];
    [items enumerateObjectsUsingBlock:^(id<SJScrollEntriesViewUserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton new];
        btn.tag = idx;
        [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:obj.title forState:UIControlStateNormal];
        [btn setTitleColor:self.settings.normalColor forState:UIControlStateNormal];
        [btn setTitleColor:self.settings.selectedColor forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:self.settings.fontSize];
        itemsM[idx] = btn;
    }];
    return itemsM;
}

- (void)_removeAllButtonItems {
    for ( UIButton *btn in _buttonItemsArr ) {
        [btn removeFromSuperview];
    }
    _buttonItemsArr = nil;
}

- (void)_setupViews {
    self.clipsToBounds = YES;
    
    self.lineContainerView.frame = self.bounds;
    self.lineContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.lineContainerView];
    [self.lineContainerView addSubview:self.lineView];
    
    self.scrollView.frame = self.bounds;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.scrollView];
}

- (UIScrollView *)scrollView {
    if ( _scrollView ) return _scrollView;
    _scrollView = [UIScrollView new];
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    return _scrollView;
}

- (UIView *)lineContainerView {
    if ( _lineContainerView ) return _lineContainerView;
    return _lineContainerView = [UIView new];
}

- (UIView *)lineView {
    if ( _lineView ) return _lineView;
    _lineView = [UIView new];
    _lineView.backgroundColor = self.settings.lineColor;
    return _lineView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize contentSize = _scrollView.contentSize;
    contentSize.height = self.frame.size.height;
    if ( CGSizeEqualToSize(contentSize, _scrollView.contentSize) ) return;
    _scrollView.contentSize = contentSize;
}

@end


@implementation SJScrollEntriesViewSettings

+ (instancetype)defaultSettings {
    SJScrollEntriesViewSettings *settings = [SJScrollEntriesViewSettings new];
    settings.fontSize = 14;
    settings.itemScale = 1.2;
    settings.selectedColor = [UIColor redColor];
    settings.normalColor = [UIColor blackColor];
    settings.lineColor = [UIColor redColor];
    settings.lineHeight = 2;
    settings.itemSpacing = 32;
    settings.lineScale = 0.382;
    return settings;
}

- (float)scrollViewMaxWidth {
    if ( 0 == _scrollViewMaxWidth ) return [UIScreen mainScreen].bounds.size.width;
    else return _scrollViewMaxWidth;
}
@end
NS_ASSUME_NONNULL_END
