//
//  SJVideoPlayerControlView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/8/18.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SJVideoPlayerControlViewDelegate;


@interface SJVideoPlayerControlView : UIView

@property (nonatomic, weak) id <SJVideoPlayerControlViewDelegate> delegate;

@end


@protocol SJVideoPlayerControlViewDelegate <NSObject>

@optional
- (void)clickedBackBtnAtControlView:(SJVideoPlayerControlView *)controlView;

@end
