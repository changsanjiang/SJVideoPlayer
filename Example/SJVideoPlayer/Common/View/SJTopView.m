//
//  SJTopView.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/5/6.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJTopView.h"
#import <Masonry/Masonry.h>
#import <SJVideoPlayer/SJVideoPlayerSettings.h>

@interface SJTopView ()
@property (nonatomic, strong) UIButton *playButton;
@end

@implementation SJTopView
+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        if ( @available(iOS 13.0, *) )
            self.backgroundColor = UIColor.systemGroupedBackgroundColor;
        else
            self.backgroundColor = UIColor.groupTableViewBackgroundColor;
        
        CAGradientLayer *layer = (id)self.layer;
        layer.colors = @[
            (id)UIColor.blackColor.CGColor,
            (id)[UIColor.blackColor colorWithAlphaComponent:0.65].CGColor
        ];
        
        _contentView = [UIView.alloc initWithFrame:CGRectZero];
        [self addSubview:_contentView];
         
        _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(clickedButton:) forControlEvents:UIControlEventTouchUpInside];
        [_playButton setTitle:@"点击播放" forState:UIControlStateNormal];
        [_contentView addSubview:_playButton];
        
        [_contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.top.equalTo(self.mas_safeAreaLayoutGuideTop);
            } else {
                make.top.offset(20);
            }
            make.left.bottom.right.offset(0);
            make.height.offset(44);
        }];
        
        [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.offset(0);
            make.centerX.offset(0);
        }];
    }
    return self;
}

- (void)clickedButton:(UIButton *)button {
    if ( button == _playButton ) {
        [self.delegate playButtonWasTapped:self];
    }
}
@end

