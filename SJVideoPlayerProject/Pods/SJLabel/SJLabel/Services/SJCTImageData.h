//
//  SJCTImageData.h
//  Test
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJCTImageData : NSObject

@property (nonatomic, strong, readonly) NSTextAttachment *imageAttachment;
@property (nonatomic, assign, readonly) int position;
@property (nonatomic, assign, readonly) CGRect imagePosition; // Core Text Coordinate
@property (nonatomic, assign, readonly) CGRect bounds;

- (instancetype)initWithImageAttachment:(NSTextAttachment *)imageAttachment position:(int)position bounds:(CGRect)bounds;

- (void)setImagePosition:(CGRect)imagePosition;

@end

NS_ASSUME_NONNULL_END
