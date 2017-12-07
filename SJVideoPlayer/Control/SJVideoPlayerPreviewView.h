//
//  SJVideoPlayerPreviewView.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerBaseView.h"
#import "SJVideoPreviewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SJVideoPlayerPreviewViewDelegate;

@interface SJVideoPlayerPreviewView : SJVideoPlayerBaseView

@property (nonatomic, weak, readwrite, nullable) id<SJVideoPlayerPreviewViewDelegate> delegate;

@property (nonatomic, strong, readwrite) NSArray<SJVideoPreviewModel *> *previewImages;

@end

@protocol SJVideoPlayerPreviewViewDelegate <NSObject>
			
@optional
- (void)previewView:(SJVideoPlayerPreviewView *)view didSelectItem:(SJVideoPreviewModel *)item;

@end

NS_ASSUME_NONNULL_END
