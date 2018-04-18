//
//  SJVideoPlayerFilmEditingConfig.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerFilmEditingConfig.h"

@implementation SJVideoPlayerFilmEditingConfig
- (instancetype)init {
    self = [super init];
    if ( !self ) return nil;
    _resultNeedUpload = YES;
    return self;
}

- (void)config:(SJVideoPlayerFilmEditingConfig *)otherConfig {
    self.shouldStartWhenUserSelectedAnOperation = otherConfig.shouldStartWhenUserSelectedAnOperation;
    self.resultShareItems = otherConfig.resultShareItems;
    self.clickedResultShareItemExeBlock = otherConfig.clickedResultShareItemExeBlock;
    self.resultNeedUpload = otherConfig.resultNeedUpload;
    self.resultUploader = otherConfig.resultUploader;
    self.disableScreenshot = otherConfig.disableScreenshot;
    self.disableRecord = otherConfig.disableRecord;
    self.disableGIF = otherConfig.disableGIF;
}
@end
