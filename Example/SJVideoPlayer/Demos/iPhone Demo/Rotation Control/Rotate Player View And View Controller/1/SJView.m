//
//  SJView.m
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2019/7/15.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import "SJView.h"

@implementation SJView

- (void)layoutSubviews {
    [super layoutSubviews];
#ifdef DEBUG
    NSLog(@"%d - %s -\n %@", (int)__LINE__, __func__, NSStringFromCGRect(self.bounds));
#endif
    
}

@end
