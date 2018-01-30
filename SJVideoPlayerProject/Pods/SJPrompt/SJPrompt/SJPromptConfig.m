//
//  SJPromptConfig.m
//  SJPromptProject
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJPromptConfig.h"

@implementation SJPromptConfig

- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    [self reset];
    return self;
}

- (void)reset {
    _insets = UIEdgeInsetsMake(8, 8, 8, 8);
    _cornerRadius = 8.0;
    _backgroundColor = [UIColor blackColor];
    _font = [UIFont systemFontOfSize:14];
    _fontColor = [UIColor whiteColor];
}

@end
