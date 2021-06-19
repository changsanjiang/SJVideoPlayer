//
//  SJPageMenuBarScrollIndicator.m
//  SJPageViewController_Example
//
//  Created by BlueDancer on 2020/2/11.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "SJPageMenuBarScrollIndicator.h"

@implementation SJPageMenuBarScrollIndicator
- (void)layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = self.bounds.size.height * 0.5;
}
@end
