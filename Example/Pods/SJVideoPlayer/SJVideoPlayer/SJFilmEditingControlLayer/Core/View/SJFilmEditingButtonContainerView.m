//
//  SJFilmEditingButtonContainerView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJFilmEditingButtonContainerView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif

@implementation SJFilmEditingButtonContainerView
- (instancetype)initWithFrame:(CGRect)frame buttonSize:(CGSize)size {
    self = [super initWithFrame:frame];
    if (self) {
        _button = [SJFilmEditingBackButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_button];
        [_button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_offset(size);
            make.center.offset(0);
        }];
        [_button addTarget:self action:@selector(clickedBackBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)clickedBackBtn:(UIButton *)btn {
    if ( _clickedBackButtonExeBlock ) _clickedBackButtonExeBlock(self);
}
@end
