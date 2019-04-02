//
//  SJRemoteCommandHandler.h
//  Pods
//
//  Created by 畅三江 on 2018/5/26.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJRemoteCommandHandler <NSObject>
@property (nonatomic, copy, nullable) void(^pauseCommandHandler)(id<SJRemoteCommandHandler> handler);
@property (nonatomic, copy, nullable) void(^playCommandHandler)(id<SJRemoteCommandHandler> handler);
@property (nonatomic, copy, nullable) void(^previousCommandHandler)(id<SJRemoteCommandHandler> handler);
@property (nonatomic, copy, nullable) void(^nextCommandHandler)(id<SJRemoteCommandHandler> handler);
@property (nonatomic, copy, nullable) void(^seekToTimeCommandHandler)(id<SJRemoteCommandHandler> handler, NSTimeInterval secs);
@end

@interface SJRemoteCommandHandler : NSObject<SJRemoteCommandHandler>
+ (instancetype)shared;

- (void)updateNowPlayingInfo:(NSDictionary *)info;
@end
NS_ASSUME_NONNULL_END
