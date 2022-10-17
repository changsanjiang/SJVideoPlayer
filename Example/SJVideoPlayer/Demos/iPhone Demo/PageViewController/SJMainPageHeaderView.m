//
//  SJMainPageHeaderView.m
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2022/8/19.
//  Copyright © 2022 changsanjiang. All rights reserved.
//

#import "SJMainPageHeaderView.h"
#import <Masonry/Masonry.h>

@implementation SJMainPageHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( self ) {
        
        self.backgroundColor = UIColor.blueColor;
        
        _pageMenuBar = [SJPageMenuBar.alloc initWithFrame:CGRectZero];
        [self addSubview:_pageMenuBar];
        [_pageMenuBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.offset(44);
            make.left.bottom.right.offset(0);
        }];
        
        
        UILabel *label = [UILabel.alloc initWithFrame:CGRectZero];
        label.text = @"Main Page Header View";
        label.textColor = UIColor.whiteColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:22];
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.offset(0);
            make.bottom.equalTo(self.pageMenuBar.mas_top);
        }];
    }
    return self;
}

- (CGSize)intrinsicContentSize {
    CGSize size = UILayoutFittingExpandedSize;
    size.height = 180 + 44;
    return size;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
}

@end
