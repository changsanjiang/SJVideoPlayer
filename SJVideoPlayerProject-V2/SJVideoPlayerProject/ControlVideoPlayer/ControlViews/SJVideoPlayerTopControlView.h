//
//  SJVideoPlayerTopControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/11/29.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerTopViewTag) {
    SJVideoPlayerTopViewTag_Back,
    SJVideoPlayerTopViewTag_Preview,
    SJVideoPlayerTopViewTag_More,
};

@protocol SJVideoPlayerTopControlViewDelegate;

@interface SJVideoPlayerTopControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerTopControlViewDelegate> delegate;

@property (nonatomic) BOOL fullscreen;

@end

@protocol SJVideoPlayerTopControlViewDelegate <NSObject>
			
@optional
- (void)topControlView:(SJVideoPlayerTopControlView *)view clickedBtnTag:(SJVideoPlayerTopViewTag)tag;

@end

NS_ASSUME_NONNULL_END
