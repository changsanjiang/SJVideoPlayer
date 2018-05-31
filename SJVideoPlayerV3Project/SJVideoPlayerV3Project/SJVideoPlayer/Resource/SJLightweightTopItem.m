//
//  SJLightweightTopItem.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/22.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJLightweightTopItem.h"

NSString *const kLightweightTopItemImageNameKeyPath = @"imageName";

@implementation SJLightweightTopItem

- (instancetype)initWithFlag:(NSInteger)flag imageName:(NSString *)imageName {
    self = [super init];
    if ( !self ) return nil;
    _flag = flag;
    _imageName = imageName;
    return self;
}
@end
