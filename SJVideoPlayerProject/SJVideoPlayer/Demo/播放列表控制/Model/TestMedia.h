//
//  TestMedia.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2019/1/23.
//  Copyright © 2019 畅三江. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJPlaybackListControllerProtocol.h"
#import <SJBaseVideoPlayer/SJPlayModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestMedia : NSObject<SJMediaInfo>
@property (nonatomic) NSInteger id;
@property (nonatomic, strong) SJPlayModel *viewHierarchy; // 视图层级
@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic) NSTimeInterval specifyStartTime;
@end

NS_ASSUME_NONNULL_END
