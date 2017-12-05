//
//  SJVideoPreviewModel.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>

@class UIImage;

@interface SJVideoPreviewModel : NSObject

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

+ (instancetype)previewModelWithImage:(UIImage *)image localTime:(CMTime)time;

@end
