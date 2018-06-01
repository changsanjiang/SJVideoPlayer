//
//  TestUploader.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerFilmEditingCommonHeader.h"

@interface TestUploader : NSObject<SJVideoPlayerFilmEditingResultUpload>
+ (instancetype)sharedManager;

- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result;

@end
