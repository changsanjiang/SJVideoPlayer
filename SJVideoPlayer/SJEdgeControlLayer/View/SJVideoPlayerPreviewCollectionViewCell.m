//
//  SJVideoPlayerPreviewCollectionViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerPreviewCollectionViewCell.h"
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif



@interface SJVideoPlayerPreviewCollectionViewCell ()

@property (nonatomic, strong, readonly) UIImageView *imageView;

@end

@implementation SJVideoPlayerPreviewCollectionViewCell

@synthesize imageView = _imageView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _collectionSetupView];
    return self;
}

- (void)setModel:(id<SJVideoPlayerPreviewInfo>)model {
    _model = model;
    _imageView.image = model.image;
}

- (void)_collectionSetupView {
    [self.contentView addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self->_imageView.superview);
    }];
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [SJUIImageViewFactory imageViewWithImageName:@"" viewMode:UIViewContentModeScaleAspectFill];
    return _imageView;
}
@end
