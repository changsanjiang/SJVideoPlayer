//
//  SJVideo+DownloadAdd.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideo.h"
#import "SJMediaDownloader.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJVideo (DownloadAdd)
- (void)addDownloadObserver;
@property (nonatomic, strong, nullable) id <SJMediaEntity> entity;
@end
NS_ASSUME_NONNULL_END
