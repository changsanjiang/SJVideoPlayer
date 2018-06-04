//
//  SJVideoPlayerFilmEditingCommonHeader.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/12.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#ifndef SJVideoPlayerFilmEditingCommonHeader_h
#define SJVideoPlayerFilmEditingCommonHeader_h

#import <UIKit/UIKit.h>
#import "SJFilmEditingStatus.h"
@class SJFilmEditingControlLayer, SJFilmEditingResultShareItem, SJVideoPlayerURLAsset;
@protocol SJVideoPlayerFilmEditingResult;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SJVideoPlayerFilmEditingOperation) {
    SJVideoPlayerFilmEditingOperation_Unknown,
    SJVideoPlayerFilmEditingOperation_Screenshot,
    SJVideoPlayerFilmEditingOperation_Export,
    SJVideoPlayerFilmEditingOperation_GIF,
};

@protocol SJFilmEditingControlLayerDelegate <NSObject>

/// 用户点击空白区域
- (void)userTappedBlankAreaOnControlLayer:(SJFilmEditingControlLayer *)controlLayer;

/// 用户点击了取消按钮
- (void)userClickedCancelBtnOnControlLayer:(SJFilmEditingControlLayer *)controlLayer;

/// 状态改变的回调
- (void)filmEditingControlLayer:(SJFilmEditingControlLayer *)controlLayer
                  statusChanged:(SJFilmEditingStatus)status;
@end


@protocol SJVideoPlayerFilmEditingResultUpload <NSObject>
- (void)upload:(id<SJVideoPlayerFilmEditingResult>)result
      progress:(void(^ __nullable)(float progress))progressBlock
       success:(void(^ __nullable)(void))success
       failure:(void (^ __nullable)(NSError *error))failure;

- (void)cancelUpload:(id<SJVideoPlayerFilmEditingResult>)result;
@end



@protocol SJVideoPlayerFilmEditingResult <NSObject>
@property (nonatomic) SJVideoPlayerFilmEditingOperation operation;
@property (nonatomic, strong, nullable) UIImage *thumbnailImage;
@property (nonatomic, strong, nullable) UIImage *image; // screenshot or GIF
@property (nonatomic, strong, nullable) NSURL *fileURL;
@property (nonatomic, strong, nullable) SJVideoPlayerURLAsset *currentPlayAsset;
- (NSData * __nullable)data;
@end


NS_ASSUME_NONNULL_END

#endif /* SJVideoPlayerFilmEditingCommonHeader_h */
