//
//  SJCustomControlLayerViewController.h
//  SJVideoPlayer_Example
//
//  Created by 畅三江 on 2019/10/11.
//  Copyright © 2019 changsanjiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SJVideoPlayer/SJControlLayerDefines.h>
@protocol SJCustomControlLayerViewControllerDelegate;

///
/// 自定义的控制层需实现协议 <SJControlLayer>
///
NS_ASSUME_NONNULL_BEGIN
@interface SJCustomControlLayerViewController : UIViewController<SJControlLayer>
@property (nonatomic, weak, nullable) id<SJCustomControlLayerViewControllerDelegate> delegate;
@end

@protocol SJCustomControlLayerViewControllerDelegate <NSObject>
///
/// 点击空白区域的回调
///
- (void)tappedBlankAreaOnTheControlLayer:(id<SJControlLayer>)controlLayer;
@end
NS_ASSUME_NONNULL_END
