//
//  SJDYTableViewCell.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import "SJBaseTableViewCell.h"
@protocol SJDYDemoPlayer, SJDYDemoPlayerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface SJDYTableViewCell : SJBaseTableViewCell
@property (nonatomic, strong, readonly) id<SJDYDemoPlayer> player;
@end

@protocol SJDYDemoPlayer <NSObject>
- (void)configureWithURL:(NSURL *)URL;

@property (nonatomic, copy, nullable) BOOL(^allowsPlayback)(id<SJDYDemoPlayer> player);

@property (nonatomic, readonly) BOOL isUserPaused;
@property (nonatomic, readonly) BOOL isPaused;

- (void)play;
- (void)pause;
- (void)stop;
- (void)pauseForUser;
@end
NS_ASSUME_NONNULL_END
