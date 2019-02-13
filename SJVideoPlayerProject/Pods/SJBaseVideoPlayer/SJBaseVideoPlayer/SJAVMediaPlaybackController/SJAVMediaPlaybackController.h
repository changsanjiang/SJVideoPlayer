//
//  SJAVMediaPlaybackController.h
//  Project
//
//  Created by BlueDancer on 2018/8/10.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJAVMediaModelProtocol.h"
#import "SJAVMediaPresentView.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaPlaybackController : NSObject<SJMediaPlaybackController, SJMediaPlaybackScreenshotController, SJMediaPlaybackExportController>
@property (nonatomic, strong, readonly) SJAVMediaPresentView *playerView;
@end
NS_ASSUME_NONNULL_END
