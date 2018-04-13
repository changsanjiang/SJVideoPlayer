//
//  FilmEditingHelper.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/4/13.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SJVideoPlayerFilmEditingConfig, UIViewController;

NS_ASSUME_NONNULL_BEGIN

@interface FilmEditingHelper : NSObject

- (instancetype)initWithViewController:(__weak UIViewController *)viewController;

@property (nonatomic, strong, readonly) SJVideoPlayerFilmEditingConfig *filmEditingConfig;

//@property (nonatomic, weak, nullable) id<SJVideoPlayerFilmEditingResultUpload> uploader; // 上传. 截屏/导出视频/GIF 时使用.

@end
NS_ASSUME_NONNULL_END
