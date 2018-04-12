//
//  SJVideoPlayerFilmEditingConfig.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingConfig.h"

@implementation SJVideoPlayerFilmEditingConfig
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _resultNeedUpload = YES;
    return self;
}
@end
