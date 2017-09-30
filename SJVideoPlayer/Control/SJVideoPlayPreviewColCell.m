//
//  SJVideoPlayPreviewColCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayPreviewColCell.h"
#import <Masonry/Masonry.h>
#import "UIView+SJExtension.h"
#import "SJVideoPlayerControlView.h"
#import "SJVideoPreviewModel.h"

@interface SJVideoPlayPreviewColCell ()

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) UIButton *backgroundBtn;

@end


@implementation SJVideoPlayPreviewColCell

@synthesize imageView = _imageView;
@synthesize backgroundBtn = _backgroundBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _SJVideoPlayPreviewColCellSetupUI];
    return self;
}

- (void)setModel:(SJVideoPreviewModel *)model {
    _model = model;
    _imageView.image = model.image;
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![self.delegate respondsToSelector:@selector(clickedItemOnCell:)] ) return;
    [self.delegate clickedItemOnCell:self];
}

- (void)_SJVideoPlayPreviewColCellSetupUI {
    [self.contentView addSubview:self.backgroundBtn];
    [self.contentView addSubview:self.imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    [_backgroundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
}

- (UIImageView *)imageView {
    if ( _imageView ) return _imageView;
    _imageView = [UIImageView imageViewWithImageStr:@"" viewMode:UIViewContentModeScaleAspectFit];
    return _imageView;
}

- (UIButton *)backgroundBtn {
    if ( _backgroundBtn ) return _backgroundBtn;
    _backgroundBtn = [UIButton buttonWithImageName:@"" tag:0 target:self sel:@selector(clickedBtn:)];
    return _backgroundBtn;
}

@end
