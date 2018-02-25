//
//  SJScrollEntriesView.m
//  SJScrollEntriesViewProject
//
//  Created by BlueDancer on 2017/9/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJScrollEntriesView.h"

#import <Masonry/Masonry.h>


@interface SJScrollEntriesView ()

@property (nonatomic, strong, readwrite) NSArray<UIButton *> *itemArr;

@property (nonatomic, strong, readwrite) SJScrollEntriesViewSettings *settings;

@property (nonatomic, strong, readonly) UIView *lineView;

@property (nonatomic, assign, readwrite) NSInteger beforeIndex;

@property (nonatomic, assign, readwrite) BOOL outChanged;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation SJScrollEntriesView

@synthesize scrollView = _scrollView;
@synthesize lineView = _lineView;

- (instancetype)initWithSettings:(SJScrollEntriesViewSettings *)settings {
    self = [super initWithFrame:CGRectZero];
    if ( !self ) return nil;
    if ( settings == nil ) settings = [SJScrollEntriesViewSettings defaultSettings];
    self.settings = settings;
    [self _setupView];
    return self;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.settings.scrollViewMaxWidth, 44);
}

- (void)changeIndex:(NSInteger)index {
    if ( _items.count == 0 ) return;
    if ( index > self.itemArr.count ) return;
    if ( index < 0 ) return;
    _outChanged = YES;
    [self clickedBtn:self.itemArr[index]];
    _outChanged = NO;
}

- (void)setItems:(NSArray<id<SJScrollEntriesViewUserProtocol>> *)items {
    _items = items;
    
    [self _reset];
    
    _itemArr = [self _createItems];
    
    [self _addSubviewToScrollView:_itemArr];
}

// MARK: Actions

- (void)clickedBtn:(UIButton *)btn {
    
    [self _updateLineLocationWithBtn:btn];
    
    CGFloat half = CGRectGetWidth(self.frame) * 0.5;
    CGFloat offsetX = btn.center.x - half;
    if ( offsetX > _scrollView.contentSize.width - CGRectGetWidth(self.frame) ) offsetX = _scrollView.contentSize.width - CGRectGetWidth(self.frame);
    if ( offsetX < 0 ) offsetX = 0;
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
    if ( !_outChanged && [self.delegate respondsToSelector:@selector(scrollEntriesView:currentIndex:beforeIndex:)] ) {
        [self.delegate scrollEntriesView:self currentIndex:btn.tag beforeIndex:self.beforeIndex];
    }
    
    self.itemArr[self.beforeIndex].selected = NO;
    btn.selected = YES;
    
    [self beforeBtnAnima:self.itemArr[self.beforeIndex]];
    [self currentBtnAnima:btn];
    
    self.beforeIndex = btn.tag;
}

- (void)_updateLineLocationWithBtn:(UIButton *)btn {
    [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(btn);
        make.width.equalTo(btn).multipliedBy(_settings.lineScale);
        make.bottom.offset(0);
        make.height.offset(self.settings.lineHeight);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self layoutIfNeeded];
    }];
    
    _currentIndex = btn.tag;
}

- (void)beforeBtnAnima:(UIButton *)btn {
    btn.titleLabel.font = [UIFont systemFontOfSize:self.settings.fontSize];
    [UIView animateWithDuration:0.25 animations:^{
        btn.transform = CGAffineTransformIdentity;
    }];
}

- (void)currentBtnAnima:(UIButton *)btn {
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:self.settings.fontSize];
    [UIView animateWithDuration:0.25 animations:^{
        btn.transform = CGAffineTransformMakeScale(self.settings.itemScale, self.settings.itemScale);
    }];
}

// MARK: Private


- (void)_addSubviewToScrollView:(NSArray<UIButton *> *)items {
    
    if ( 0 == items.count ) return;
    
    // calculate width
    __block CGFloat realMaxWidth = 0;
    NSMutableArray<NSNumber *> *itemsWidthM = [NSMutableArray array];
    [_items enumerateObjectsUsingBlock:^(id<SJScrollEntriesViewUserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat width = [self sizeForTitle:obj.title size:CGSizeMake(CGFLOAT_MAX, 44)].width + _settings.itemSpacing;
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
        [_scrollView addSubview:obj];
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
    [self clickedBtn:items.firstObject];
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

- (NSArray<UIButton *> *)_createItems {
    NSMutableArray<UIButton *> *itemsM = [NSMutableArray new];
    [self.items enumerateObjectsUsingBlock:^(id<SJScrollEntriesViewUserProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        itemsM[idx] = [self _createButtonWithTitle:obj.title index:idx];
    }];
    return itemsM;
}

- (void)_reset {
    [_itemArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    _itemArr = nil;
}

- (UIButton *)_createButtonWithTitle:(NSString *)title index:(NSInteger)index {
    UIButton *btn = [UIButton new];
    btn.tag = index;
    [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:self.settings.normalColor forState:UIControlStateNormal];
    [btn setTitleColor:self.settings.selectedColor forState:UIControlStateSelected];
    btn.titleLabel.font = [UIFont systemFontOfSize:self.settings.fontSize];
    return btn;
}

// MARK: UI

- (void)_setupView {
    [self addSubview:self.scrollView];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:NSLayoutFormatAlignAllLeading metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:NSLayoutFormatAlignAllTop metrics:nil views:NSDictionaryOfVariableBindings(_scrollView)]];
    [self addSubview:self.lineView];
}

- (UIScrollView *)scrollView {
    if ( _scrollView ) return _scrollView;
    _scrollView = [UIScrollView new];
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    return _scrollView;
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

