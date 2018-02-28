//
//  TableHeaderCollectionViewCell.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/28.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TableHeaderCollectionViewCell.h"
#import <SJUIFactory/SJUIFactory.h>
#import <Masonry.h>

@interface TableHeaderCollectionViewCell ()

@property (nonatomic, strong, readonly) UIImageView *playImageView;

@end

@implementation TableHeaderCollectionViewCell
@synthesize playImageView = _playImageView;
@synthesize backgroundImageView = _backgroundImageView;

+ (CGSize)itemSize {
    return CGSizeMake(SJScreen_W(), SJScreen_W());
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self setupView];
    return self;
}

- (void)setupView {
    [self.contentView addSubview:self.backgroundImageView];
    [_backgroundImageView addSubview:self.playImageView];
    [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsMake(8, 8, 8, 8));
    }];
    
    [_playImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.size.offset(25);
    }];
    
    _backgroundImageView.backgroundColor =  [UIColor colorWithRed:arc4random() % 256 / 255.0
                                                            green:arc4random() % 256 / 255.0
                                                             blue:arc4random() % 256 / 255.0
                                                            alpha:1];
}

- (void)handleTap {
    if ( [_delegate respondsToSelector:@selector(clickedPlayOnColCell:)] ) {
        [_delegate clickedPlayOnColCell:self];
    }
}

- (UIImageView *)backgroundImageView {
    if ( _backgroundImageView ) return _backgroundImageView;
    _backgroundImageView = [SJUIImageViewFactory imageViewWithViewMode:UIViewContentModeScaleAspectFill];
    _backgroundImageView.userInteractionEnabled = YES;
    [_backgroundImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)]];
    _backgroundImageView.tag = 101; // set it tag.
    return _backgroundImageView;
}
- (UIImageView *)playImageView {
    if ( _playImageView ) return _playImageView;
    _playImageView = [SJUIImageViewFactory imageViewWithImageName:@"play"];
    return _playImageView;
}
@end

