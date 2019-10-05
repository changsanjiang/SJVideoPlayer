//
//  SJAVMediaPlaybackController.h
//  Project
//
//  Created by 畅三江 on 2018/8/10.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerPlaybackControllerDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController : NSObject<SJVideoPlayerPlaybackController>

@end

@interface SJAVMediaPlaybackController (SJExtendedScreenshot)<SJMediaPlaybackScreenshotController>

@end

@interface SJAVMediaPlaybackController (SJExtendedExport)<SJMediaPlaybackExportController>

@end
NS_ASSUME_NONNULL_END
