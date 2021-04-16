//
//  DYHCollectionViewCell.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <SJUIKit/SJBaseCollectionViewCell.h>
@protocol DYHDemoPlayer, DYHDemoPlayerDelegate;

NS_ASSUME_NONNULL_BEGIN
@interface DYHCollectionViewCell : SJBaseCollectionViewCell
@property (nonatomic, strong, readonly) id<DYHDemoPlayer> player;
@end

@protocol DYHDemoPlayer <NSObject>
- (void)configureWithURL:(NSURL *)URL;

@property (nonatomic, copy, nullable) BOOL(^allowsPlayback)(id<DYHDemoPlayer> player);

@property (nonatomic, readonly) BOOL isUserPaused;
@property (nonatomic, readonly) BOOL isPaused;

- (void)play;
- (void)pause;
- (void)stop;
- (void)pauseForUser;
@end
NS_ASSUME_NONNULL_END
