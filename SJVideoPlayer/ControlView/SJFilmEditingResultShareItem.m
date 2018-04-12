//
//  SJFilmEditingResultShareItem.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingResultShareItem.h"

@implementation SJFilmEditingResultShareItem
- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _image = image;
    return self;
}
@end
