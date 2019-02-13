//
//  SJTableHeaderView.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/9/30.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJTableHeaderView.h"
#import <Masonry/Masonry.h>

@implementation SJTableHeaderView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    self.backgroundColor = [UIColor blackColor];
    _view = [SJPlayView new];
    _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _view.frame = self.bounds;
    [self addSubview:_view];
    return self;
}
@end
