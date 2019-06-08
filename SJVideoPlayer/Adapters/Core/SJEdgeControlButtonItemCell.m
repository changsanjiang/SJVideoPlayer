//
//  SJEdgeControlButtonItemCell.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeControlButtonItemCell.h"
#import "SJEdgeControlButtonItem.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJUITapGestureRecognizerDelegate : NSObject<UIGestureRecognizerDelegate>
@property (nonatomic, strong, nullable) SJEdgeControlButtonItem *item;
@end

@implementation SJUITapGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [_item.target respondsToSelector:_item.action];
}
@end

@interface _SJEdgeControlButtonItemCell_Blank : SJEdgeControlButtonItemCell<UIGestureRecognizerDelegate>
@property (nonatomic, strong, readonly) UITapGestureRecognizer *tap;
@property (nonatomic, strong) SJUITapGestureRecognizerDelegate *tapGestureRecognizerDelegate;
@end

@implementation _SJEdgeControlButtonItemCell_Blank
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)];
    _tapGestureRecognizerDelegate = [[SJUITapGestureRecognizerDelegate alloc] init];
    _tap.delegate = _tapGestureRecognizerDelegate;
    [self.contentView addGestureRecognizer:_tap];
    return self;
}
- (void)setItem:(nullable SJEdgeControlButtonItem *)item {
    [super setItem:item];
    _tapGestureRecognizerDelegate.item = item;
}
- (void)tapped {
    if ( self.item.hidden )
        return;
    [self.item performAction];
}
@end

@interface _SJEdgeControlButtonItemCell_CustomView : _SJEdgeControlButtonItemCell_Blank
@end

@implementation _SJEdgeControlButtonItemCell_CustomView
- (void)setItem:(SJEdgeControlButtonItem *_Nullable)item {
    SJEdgeControlButtonItem *oldItem = self.item;
    if ( oldItem.customView != item.customView ) {
        [oldItem.customView removeFromSuperview];
    }
    item.customView.userInteractionEnabled = (nil == item.target);
    item.customView.frame = self.contentView.bounds;
    item.customView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:item.customView];
    [super setItem:item];
}
@end

@interface _SJEdgeControlButtonItemCell_Title : _SJEdgeControlButtonItemCell_Blank
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

@interface _SJEdgeControlButtonItemCell_Image : _SJEdgeControlButtonItemCell_Blank
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
static NSString *kBlank = @"E";
+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath willSetItem:(SJEdgeControlButtonItem *)item {
    if ( item.hidden )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kEmpty
                                                         forIndexPath:indexPath];
    else if ( item.image )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kImage
                                                         forIndexPath:indexPath];
    else if ( item.title )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kTitle
                                                         forIndexPath:indexPath];
    else if ( item.customView )
        return [collectionView dequeueReusableCellWithReuseIdentifier:kCustomView
                                                         forIndexPath:indexPath];
    else
        return [collectionView dequeueReusableCellWithReuseIdentifier:kBlank
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
    [collectionView registerClass:[_SJEdgeControlButtonItemCell_Blank class] forCellWithReuseIdentifier:kBlank];
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
