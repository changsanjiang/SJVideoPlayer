//
//  SJLightweightLeftControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/21.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, SJLightweightLeftControlViewTag) {
    SJLightweightLeftControlViewTag_Lock,
    SJLightweightLeftControlViewTag_Unlock,
};

@protocol SJLightweightLeftControlViewDelegate;

@interface SJLightweightLeftControlView : UIView

@property (nonatomic, weak, readwrite, nullable) id<SJLightweightLeftControlViewDelegate> delegate;

@property (nonatomic) BOOL lockState;

@end


@protocol SJLightweightLeftControlViewDelegate <NSObject>

@optional
- (void)leftControlView:(SJLightweightLeftControlView *)view clickedBtnTag:(SJLightweightLeftControlViewTag)tag;

@end

NS_ASSUME_NONNULL_END
