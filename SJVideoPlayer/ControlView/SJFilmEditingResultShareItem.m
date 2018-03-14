//
//  SJFilmEditingResultShareItem.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/9.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJFilmEditingResultShareItem.h"

@implementation SJFilmEditingResultShare

- (instancetype)initWithShateItems:(NSArray<SJFilmEditingResultShareItem *> *)filmEditingResultShareItems {
    self = [super init];
    if ( !self ) return nil;
    _filmEditingResultShareItems = filmEditingResultShareItems;
    return self;
}
@end

@implementation SJFilmEditingResultShareItem

- (instancetype)initWithTitle:(NSString *)title image:(UIImage *)image {
    self = [super init];
    if ( !self ) return nil;
    _title = title;
    _image = image;
    return self;
}
@end

@implementation SJFilmEditingResultUploader

@end
