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

@property (nonatomic, assign) float downloadProgress;
@property (nonatomic, assign) SJMediaDownloadStatus downloadStatus;
@property (nonatomic, strong, nullable) NSString *filePath;

@end
NS_ASSUME_NONNULL_END
