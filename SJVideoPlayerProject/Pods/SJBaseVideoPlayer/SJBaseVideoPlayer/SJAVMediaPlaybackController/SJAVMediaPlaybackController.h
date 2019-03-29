//
//  SJAVMediaPlaybackController.h
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJAVMediaModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController : NSObject<SJMediaPlaybackController, SJMediaPlaybackScreenshotController, SJMediaPlaybackExportController>
@end
NS_ASSUME_NONNULL_END
