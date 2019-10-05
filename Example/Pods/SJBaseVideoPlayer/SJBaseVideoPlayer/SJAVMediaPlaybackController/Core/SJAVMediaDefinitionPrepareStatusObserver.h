//
//  SJAVMediaDefinitionPrepareStatusObserver.h
//  Pods
//
//  Created by 畅三江 on 2019/10/5.
//

#import <Foundation/Foundation.h>
@class SJAVMediaPlayer, SJAVMediaPresentView;

NS_ASSUME_NONNULL_BEGIN
@interface SJAVMediaDefinitionPrepareStatusObserver : NSObject
- (instancetype)initWithPlayer:(SJAVMediaPlayer *)player presentView:(SJAVMediaPresentView *)presentView;
@property (nonatomic, strong, readonly) SJAVMediaPresentView *presentView;
@property (nonatomic, strong, readonly) SJAVMediaPlayer *player;

@property (nonatomic, copy, nullable) void(^statusDidChangeExeBlock)(SJAVMediaDefinitionPrepareStatusObserver *switcher);
@end
NS_ASSUME_NONNULL_END
