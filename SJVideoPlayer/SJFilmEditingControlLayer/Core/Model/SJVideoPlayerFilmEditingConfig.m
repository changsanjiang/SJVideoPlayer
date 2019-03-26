//
//  SJVideoPlayerFilmEditingConfig.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingConfig.h"

NS_ASSUME_NONNULL_BEGIN
@implementation SJVideoPlayerFilmEditingConfig
- (void)config:(SJVideoPlayerFilmEditingConfig *)otherConfig {
    self.shouldStartWhenUserSelectedAnOperation = otherConfig.shouldStartWhenUserSelectedAnOperation;
    self.resultShareItems = otherConfig.resultShareItems;
    self.clickedResultShareItemExeBlock = otherConfig.clickedResultShareItemExeBlock;
    self.resultNeedUpload = otherConfig.resultNeedUpload;
    self.resultUploader = otherConfig.resultUploader;
    self.disableScreenshot = otherConfig.disableScreenshot;
    self.disableRecord = otherConfig.disableRecord;
    self.disableGIF = otherConfig.disableGIF;
    self.saveResultToAlbumWhenExportSuccess = otherConfig.saveResultToAlbumWhenExportSuccess;
}
@end
NS_ASSUME_NONNULL_END
