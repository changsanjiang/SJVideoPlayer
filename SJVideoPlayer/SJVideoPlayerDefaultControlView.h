//
//  SJVideoPlayerDefaultControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/6.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJVideoPlayerControlDataSource.h"

@class SJVideoPlayer, SJVideoPlayerMoreSetting;

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerDefaultControlViewDelegate;

@interface SJVideoPlayerDefaultControlView : UIView<SJVideoPlayerControlDelegate, SJVideoPlayerControlDataSource>

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerDefaultControlViewDelegate> delegate;

@property (nonatomic, assign, readwrite) BOOL generatePreviewImages;

@property (nonatomic, strong, readwrite, nullable) NSArray<SJVideoPlayerMoreSetting *> *moreSettings;

@end

@protocol SJVideoPlayerDefaultControlViewDelegate <NSObject>

@required
- (void)clickedBackBtnOnControlView:(SJVideoPlayerDefaultControlView *)controlView;

@end

NS_ASSUME_NONNULL_END
