//
//  SJVideoPlayerURLAsset+SJControlAdd.h
//  SJVideoPlayerProject
//
//  Created by 畅三江 on 2018/2/4.
//  Copyright © 2018年 changsanjiang. All rights reserved.
//

#if __has_include(<SJBaseVideoPlayer/SJVideoPlayerURLAsset.h>)
#import <SJBaseVideoPlayer/SJVideoPlayerURLAsset.h>
#else
#import "SJVideoPlayerURLAsset.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SJVideoPlayerURLAsset (SJControlAdd)

- (nullable instancetype)initWithTitle:(NSString *)title
                          URL:(NSURL *)URL
                    playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithTitle:(NSString *)title
                          URL:(NSURL *)URL
             specifyStartTime:(NSTimeInterval)specifyStartTime
                    playModel:(__kindof SJPlayModel *)playModel;

///
/// v3.0.3 新增富文本标题
///
- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                       playModel:(__kindof SJPlayModel *)playModel;

- (nullable instancetype)initWithAttributedTitle:(NSAttributedString *)title
                                             URL:(NSURL *)URL
                                specifyStartTime:(NSTimeInterval)specifyStartTime
                                       playModel:(__kindof SJPlayModel *)playModel;


@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, copy, nullable) NSAttributedString *attributedTitle;
@end
NS_ASSUME_NONNULL_END
