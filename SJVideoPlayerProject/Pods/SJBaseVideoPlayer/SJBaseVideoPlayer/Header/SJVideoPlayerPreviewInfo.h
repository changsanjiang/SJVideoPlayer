//
//  SJVideoPlayerPreviewInfo.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerPreviewInfo_h
#define SJVideoPlayerPreviewInfo_h

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol SJVideoPlayerPreviewInfo <NSObject>

@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, assign, readonly) CMTime localTime;

@end

#endif /* SJVideoPlayerPreviewInfo_h */
