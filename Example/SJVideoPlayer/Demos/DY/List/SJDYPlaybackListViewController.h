//
//  SJDYPlaybackListViewController.h
//  SJVideoPlayer_Example
//
//  Created by BlueDancer on 2020/6/12.
//  Copyright © 2020 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJDYPlaybackListViewControllerDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface SJDYPlaybackListViewController : UIViewController

@property (nonatomic, weak, nullable) id<SJDYPlaybackListViewControllerDelegate> delegate;

// 当用户暂停时, 将不会调用播放
- (void)playIfNeeded;

// 暂停播放. 如果该方法调用之前用户已暂停播放了, 当执行此操作时不会影响用户暂停态
- (void)pause;

@end

@protocol SJDYPlaybackListViewControllerDelegate <NSObject>
// 播放器是否可以执行播放
- (BOOL)canPerformPlayForListViewController:(SJDYPlaybackListViewController *)vc;
@end
NS_ASSUME_NONNULL_END
