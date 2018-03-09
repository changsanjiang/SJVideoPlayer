//
//  SJFilmEditingResultShareItem.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingResultShareItem.h"

@implementation SJFilmEditingResultShareItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image clickToDisappear:(BOOL)yesOrNo clickedExeBlock:(void (^)(SJFilmEditingResultShareItem *filmEditingResultShareItem, UIImage *image, NSURL * __nullable exportedVideoURL))clickedExeBlock {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _image = image;
    _clickToDisappear = yesOrNo;
    _clickedExeBlock = [clickedExeBlock copy];
    return self;
}
@end
