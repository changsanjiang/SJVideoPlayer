//
//  SJCTImageData.m
//  Test
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJCTImageData.h"

@implementation SJCTImageData

- (instancetype)initWithImageAttachment:(NSTextAttachment *)imageAttachment position:(int)position bounds:(CGRect)bounds {
    self = [super init];
    if ( !self ) return nil;
    _imageAttachment = imageAttachment;
    _position = position;
    _bounds = bounds;
    return self;
}

- (void)setImagePosition:(CGRect)imagePosition {
    _imagePosition = imagePosition;
}

@end
