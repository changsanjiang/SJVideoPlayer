//
//  PresentingViewController.h
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/11/14.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "BaseViewController.h"
#import "SJVideoPlayer.h"

NS_ASSUME_NONNULL_BEGIN
@interface PresentingViewController : BaseViewController
- (instancetype)initWithVideoPlayer:(SJVideoPlayer *)player;
@end
NS_ASSUME_NONNULL_END
