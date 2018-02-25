//
//  TestItem.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "TestItem.h"

@implementation TestItem
- (instancetype)initWithTitle:(NSString *)title {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    return self;
}
@end
