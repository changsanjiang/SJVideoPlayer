//
//  SJDeviceBrightnessView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/24.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJDeviceBrightnessView.h"
#import "SJBorderLineView.h"
#import "SJDeviceVolumeAndBrightnessManagerResourceLoader.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

NS_ASSUME_NONNULL_BEGIN
@interface SJDeviceBrightnessView ()

@property (nonatomic, strong, readonly) UIColor *themeColor;
@property (nonatomic, strong, readonly) UIVisualEffectView *bottomMaskView;
@property (nonatomic, strong, readonly) UIView *tipsContainerView;
@property (nonatomic, strong, readonly) NSArray<UIView *> *tipsViewsArr;
@property (nonatomic, strong, readonly) UIImageView *imageView;

@end


@implementation SJDeviceBrightnessView

@synthesize bottomMaskView = _bottomMaskView;
@synthesize titleLabel = _titleLabel;
@synthesize imageView = _imageView;
@synthesize tipsContainerView = _tipsContainerView;
@synthesize tipsViewsArr = _tipsViewsArr;

- (instancetype)initWithFrame:(CGRect)frame {
    frame.size = CGSizeMake(155, 155);
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupViews];
    return self;
}

- (void)setValue:(CGFloat)value {
    _value = value;
    CGFloat showTipsCount = value * _tipsViewsArr.count;
    for ( NSInteger i = 0 ; i < _tipsViewsArr.count ; i ++ ) { _tipsViewsArr[i].hidden = i >= showTipsCount; }
    _tipsContainerView.hidden = (0 == value);
}

- (void)setImage:(UIImage *_Nullable)image {
    _image = image;
    _imageView.image = image;
}

- (void)_setupViews {
    
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    
    [self addSubview:self.bottomMaskView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.imageView];
    [self addSubview:self.tipsContainerView];
    
    [_bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_bottomMaskView.superview);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self->_titleLabel.superview);
        make.top.offset(12);
    }];
    
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_tipsContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(12);
        make.trailing.offset(-12);
        make.bottom.offset(-16);
        make.height.offset(7);
    }];
    
    [self.tipsViewsArr enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self->_tipsContainerView addSubview:obj];
        if ( 0 == idx ) {
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.top.bottom.offset(0);
                make.width.equalTo(obj.superview).multipliedBy(1.0 / 16);
            }];
        }
        else {
            UIView *beforeView = self->_tipsViewsArr[idx - 1];
            [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.offset(0);
                make.leading.equalTo(beforeView.mas_trailing).offset(0);
                make.width.equalTo(beforeView);
            }];
        }
    }];
}

- (UIVisualEffectView *)bottomMaskView {
    if ( _bottomMaskView ) return _bottomMaskView;
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _bottomMaskView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _bottomMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    return _bottomMaskView;
}

- (UILabel *)titleLabel {
    if ( _titleLabel ) return _titleLabel;
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    _titleLabel.textColor = self.themeColor;
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    return _titleLabel;
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    return _imageView;
}

- (UIView *)tipsContainerView {
    if ( _tipsContainerView ) return _tipsContainerView;
    _tipsContainerView = [UIView new];
    _tipsContainerView.backgroundColor = self.themeColor;
    return _tipsContainerView;
}

- (NSArray<UIView *> *)tipsViewsArr {
    if ( _tipsViewsArr ) return _tipsViewsArr;
    NSMutableArray<UIView *> *tipsArrM = [NSMutableArray new];
    short maxNum = 16;
    for ( short i = 0 ; i < maxNum ; i ++ ) {
        SJBorderLineView *view = nil;
        if ( maxNum - 1 != i ) {
            view = [SJBorderLineView borderlineViewWithSide:SJBorderLineSideTop | SJBorderLineSideLeading | SJBorderLineSideBottom startMargin:0 endMargin:0 lineColor:self.themeColor backgroundColor:[UIColor whiteColor]];
        }
        else {
            view = [SJBorderLineView borderlineViewWithSide:SJBorderLineSideAll startMargin:0 endMargin:0 lineColor:self.themeColor backgroundColor:[UIColor whiteColor]];
        }
        [tipsArrM addObject:view];
        view.hidden = YES;
    }
    _tipsViewsArr = tipsArrM;
    return _tipsViewsArr;
} 

#pragma mark -
- (UIColor *)themeColor {
    return [UIColor colorWithRed:51 / 255.0
                           green:51 / 255.0
                            blue:51 / 255.0
                           alpha:1];
}
@end
NS_ASSUME_NONNULL_END
