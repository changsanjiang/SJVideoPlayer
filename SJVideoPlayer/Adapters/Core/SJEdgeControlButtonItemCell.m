//
//  SJEdgeControlButtonItemCell.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItemCell.h"
#import "SJEdgeControlButtonItem.h"
#import <Masonry/Masonry.h>

NS_ASSUME_NONNULL_BEGIN
@interface _SJEdgeControlButtonItemCell_CustomView : SJEdgeControlButtonItemCell
@property (nonatomic, strong, nullable) UIView *customView;
@end

@implementation _SJEdgeControlButtonItemCell_CustomView
- (void)setItem:(SJEdgeControlButtonItem *_Nullable)item {
    if ( item.customView != _customView ) {
        if ( _customView.superview == self.contentView ) {
            [_customView removeFromSuperview];
        }
        _customView = item.customView;
        [self.contentView addSubview:_customView];
        [_customView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.offset(0);
        }];
    }
    [super setItem:item];
}
@end


@interface _SJEdgeControlButtonItemCell_Title : SJEdgeControlButtonItemCell
@property (nonatomic, strong, readonly) UILabel *titleLabel;
@end
@implementation _SJEdgeControlButtonItemCell_Title
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)setItem:(SJEdgeControlButtonItem *_Nullable)item {
    [super setItem:item];
    _titleLabel.numberOfLines = item.numberOfLines;
    _titleLabel.attributedText = item.title;
}

- (void)_setupView {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.frame = self.contentView.bounds;
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_titleLabel];
}
@end

@interface _SJEdgeControlButtonItemCell_Image : SJEdgeControlButtonItemCell
@property (nonatomic, strong, readonly) UIImageView *imageView;
@end
@implementation _SJEdgeControlButtonItemCell_Image
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)setItem:(SJEdgeControlButtonItem *_Nullable)item {
    [super setItem:item];
    _imageView.image = item.image;
}

- (void)_setupView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeCenter;
    _imageView.frame = self.contentView.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:_imageView];
}
@end

@interface SJEdgeControlButtonItemCell ()
@end
@implementation SJEdgeControlButtonItemCell
static NSString *kEmpty = @"A";
static NSString *kImage = @"B";
static NSString *kTitle = @"C";
static NSString *kCustomView = @"D";
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath willSetItem:(SJEdgeControlButtonItem *)item {
    if ( item.image )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kImage
                                                         forIndexPath:indexPath];
    else if ( item.title )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kTitle
                                                         forIndexPath:indexPath];
    else if ( item.customView )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kCustomView
                                                         forIndexPath:indexPath];
    else
        return [collectionView dequeueReusableCellWithReuseIdentifier:kEmpty
                                                         forIndexPath:indexPath];
}

+ (NSString *)reuseIdentifier {
    return [self description];
}

+ (void)registerWithCollectionView:(UICollectionView *)collectionView {
    [collectionView registerClass:[self class] forCellWithReuseIdentifier:kEmpty];
    [collectionView registerClass:[_SJEdgeControlButtonItemCell_Image class] forCellWithReuseIdentifier:kImage];
    [collectionView registerClass:[_SJEdgeControlButtonItemCell_Title class] forCellWithReuseIdentifier:kTitle];
    [collectionView registerClass:[_SJEdgeControlButtonItemCell_CustomView class] forCellWithReuseIdentifier:kCustomView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    return self;
}

- (void)setItem:(SJEdgeControlButtonItem * _Nullable)item {
    _item = item;
    self.contentView.hidden = item.hidden;
}
@end
NS_ASSUME_NONNULL_END
