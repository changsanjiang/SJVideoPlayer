//
//  SJScrollToolbarItemView.m
//  SJScrollToolbar
//
//  Created by 畅三江 on 2019/12/23.
//

#import "SJScrollToolbarItemView.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>

NS_ASSUME_NONNULL_BEGIN
@interface SJScrollToolbarItemImageView : UIImageView
@property (nonatomic) CGFloat layoutHeight;
@end

@implementation SJScrollToolbarItemImageView
- (CGSize)intrinsicContentSize {
    if ( !self.image )  {
        return CGSizeZero;
    }
    CGFloat height = _layoutHeight;
    CGFloat width = self.image.size.width * height / self.image.size.height;
    return CGSizeMake(width, height);
}
@end

@interface SJScrollToolbarItemView ()
@property (nonatomic, strong, nullable) SJScrollToolbarItemImageView *itemImageView;
@property (nonatomic, strong, nullable) UILabel *itemTitleLabel;
@end

@implementation SJScrollToolbarItemView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        _zoomScale = 1.0;
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    return _itemImageView.image != nil ? _itemImageView.frame.size : _itemTitleLabel.frame.size;
}

- (void)setItem:(nullable id<SJScrollToolbarItem>)item {
    _item = item;
    
    if ( item.image != nil ) {
        _itemTitleLabel.hidden = YES;
        _itemImageView.image = item.image;
    }
    else {
        _itemTitleLabel.hidden = NO;
        if ( _itemTitleLabel == nil ) {
            _itemTitleLabel = [UILabel.alloc initWithFrame:CGRectZero];
            _itemTitleLabel.textColor = UIColor.blackColor;
            _itemTitleLabel.textAlignment = NSTextAlignmentCenter;
            _itemTitleLabel.font = self.maximumFont;
            [self _resetTransform];
            [self addSubview:_itemTitleLabel];
            [_itemTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.offset(0);
            }];
        }

        if ( item.imageUrl != nil ) {
            if ( _itemImageView == nil ) {
                _itemImageView = [SJScrollToolbarItemImageView.alloc initWithFrame:CGRectZero];
                _itemImageView.contentMode = UIViewContentModeScaleAspectFit;
                _itemImageView.layoutHeight = self._heightOfItemImageView;
                [self _resetTransform];
                [self addSubview:_itemImageView];
                [_itemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.offset(0);
                }];
            }
            __weak typeof(self) _self = self;
            [_itemImageView sd_setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageForceTransition completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                __strong typeof(_self) self = _self;
                if ( !self ) return;
                if ( image == nil ) return;
                if ( self.item == item ) {
                    self.item.image = image;
                    self.itemImageView.image = image;
                    self.itemTitleLabel.hidden = YES;
                    [self.itemImageView layoutIfNeeded];
                    [self invalidateIntrinsicContentSize];
                    if ( [self.delegate respondsToSelector:@selector(itemViewDidFinishLoadImage:)] ) {
                        [self.delegate itemViewDidFinishLoadImage:self];
                    }
                }
            }];
        }
        
        if ( item.attributedString != nil ) {
            _itemTitleLabel.attributedText = item.attributedString;
        }
        else {
            _itemTitleLabel.font = self.maximumFont;
            _itemTitleLabel.attributedText = nil;
            _itemTitleLabel.text = item.title;
        }
        [_itemTitleLabel sizeToFit];
    }
}

@synthesize textColor = _textColor;
- (void)setTextColor:(nullable UIColor *)textColor {
    _textColor = textColor;
    _itemTitleLabel.textColor = self.textColor;
}
- (UIColor *)textColor {
    return _textColor ?: UIColor.blackColor;
}

@synthesize maximumFont = _maximumFont;
- (void)setMaximumFont:(nullable UIFont *)maximumFont {
    if ( ![maximumFont isEqual:_maximumFont] ) {
        _maximumFont = maximumFont;
        if ( _item.attributedString == nil ) _itemTitleLabel.font = self.maximumFont;
        _itemImageView.layoutHeight = self._heightOfItemImageView;
    }
}
- (UIFont *)maximumFont {
    return _maximumFont ?: [UIFont boldSystemFontOfSize:26];
}

- (void)setZoomScale:(CGFloat)zoomScale {
    _zoomScale = zoomScale;
    
    [self _resetTransform];
}

#pragma mark -

- (void)invalidateIntrinsicContentSize {
    [super invalidateIntrinsicContentSize];
    _itemTitleLabel.isHidden ? [_itemImageView invalidateIntrinsicContentSize] :
                               [_itemTitleLabel invalidateIntrinsicContentSize];
}

#pragma mark -

- (void)_resetTransform {
    CGAffineTransform transform = CGAffineTransformMakeScale(_zoomScale, _zoomScale);
    _itemTitleLabel.transform = transform;
    _itemImageView.transform = transform;
}

- (CGFloat)_heightOfItemImageView {
    return ceil(self.maximumFont.ascender + ABS(self.maximumFont.descender));
}
@end
NS_ASSUME_NONNULL_END
