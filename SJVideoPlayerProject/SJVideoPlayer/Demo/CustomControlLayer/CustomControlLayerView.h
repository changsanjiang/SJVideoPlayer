//
//  CustomControlLayerView.h
//  SJVideoPlayer
//
//  Created by 畅三江 on 2018/10/1.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJBaseVideoPlayer/SJVideoPlayerControlLayerProtocol.h>

NS_ASSUME_NONNULL_BEGIN
@interface CustomControlLayerView : UIView<SJVideoPlayerControlLayerDelegate, SJVideoPlayerControlLayerDataSource>

@end
NS_ASSUME_NONNULL_END
