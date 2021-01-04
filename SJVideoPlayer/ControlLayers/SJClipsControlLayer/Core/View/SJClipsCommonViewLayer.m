//
//  SJClipsCommonViewLayer.m
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/20.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import "SJClipsCommonViewLayer.h"
#import <UIKit/UIKit.h>

@implementation SJClipsCommonViewLayer
- (void)layoutSublayers {
    [super layoutSublayers];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
    self.cornerRadius = self.bounds.size.height * 0.5;
}
@end
