//
//  SJClipsBackButton.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJClipsBackButton.h"
#import "SJClipsCommonViewLayer.h"

NS_ASSUME_NONNULL_BEGIN 
@implementation SJClipsBackButton
+ (Class)layerClass {
    return [SJClipsCommonViewLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return self;
}
@end
NS_ASSUME_NONNULL_END
