//
//  SJVideoPlayerLeftControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/3.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerLeftViewTag) {
    SJVideoPlayerLeftViewTag_Lock,
    SJVideoPlayerLeftViewTag_Unlock,
};

@protocol SJVideoPlayerLeftControlViewDelegate;

@interface SJVideoPlayerLeftControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerLeftControlViewDelegate> delegate;

@property (nonatomic) BOOL lockState;

@end


@protocol SJVideoPlayerLeftControlViewDelegate <NSObject>

@optional
- (void)leftControlView:(SJVideoPlayerLeftControlView *)view clickedBtnTag:(SJVideoPlayerLeftViewTag)tag;

@end

NS_ASSUME_NONNULL_END
