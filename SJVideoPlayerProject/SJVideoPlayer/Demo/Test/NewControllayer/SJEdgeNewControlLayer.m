//
//  SJEdgeNewControlLayer.m
//  SJVideoPlayer
//
//  Created by BlueDancer on 2018/10/20.
//  Copyright © 2018 畅三江. All rights reserved.
//

#import "SJEdgeNewControlLayer.h"
#import "SJVideoPlayerControlMaskView.h"
#import "SJEdgeControlLayerItemAdapter.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#import "SJEdgeControlLayerSettings.h"

#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif


NS_ASSUME_NONNULL_BEGIN
@interface SJEdgeNewControlLayer ()

@property (nonatomic, strong, readonly) SJEdgeControlLayerItemAdapter *topAdapter;
@property (nonatomic, strong, readonly) SJVideoPlayerControlMaskView *topControlView;

@end

@implementation SJEdgeNewControlLayer
@synthesize topAdapter = _topAdapter;
@synthesize topControlView = _topControlView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _setupView];
    return self;
}

- (void)_setupView {
    [self.controlView addSubview:self.topControlView];
    [self.topControlView addSubview:self.topAdapter.view];
    
    [_topControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.leading.trailing.offset(0);
        make.height.offset(20 + 44);
    }];
    
    [_topAdapter.view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.left.equalTo(self.controlView.mas_safeAreaLayoutGuideLeft);
            make.right.equalTo(self.controlView.mas_safeAreaLayoutGuideRight);
        }
        else {
            make.left.right.offset(0);
        }
        make.bottom.offset(0);
        make.height.offset(44);
        make.top.offset(20);
    }];
}

- (SJEdgeControlLayerItemAdapter *)topAdapter {
    if ( _topAdapter ) return _topAdapter;
    _topAdapter = [[SJEdgeControlLayerItemAdapter alloc] initWithDirection:UICollectionViewScrollDirectionHorizontal];
    
//    SJEdgeControlButtonItem *playItem = [[SJEdgeControlButtonItem alloc] initWithImage:SJEdgeControlLayerSettings.commonSettings.backBtnImage
//                                                                                target:self
//                                                                                action:@selector(test)
//                                                                                   tag:0];
//    [_topAdapter addItem:playItem];
    
    SJEdgeControlButtonItem *titleItem = [[SJEdgeControlButtonItem alloc] initWithTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"Test Title Test Title Test Title Test Title Test TitleTest TitleTest Title ").font(SJEdgeControlLayerSettings.commonSettings.titleFont).textColor(SJEdgeControlLayerSettings.commonSettings.titleColor);
        make.shadow(CGSizeMake(0.5, 0.5), 1, [UIColor blackColor]);
    }) target:nil action:NULL tag:0];
    titleItem.fill = YES;
    [_topAdapter addItem:titleItem];
    
    
    SJEdgeControlButtonItem *previewItem = [[SJEdgeControlButtonItem alloc] initWithTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
        make.append(@"预览");
    }) target:self action:@selector(test) tag:0];
    [_topAdapter addItem:previewItem];
    
    
    [_topAdapter reload];
    return _topAdapter;
}

- (void)test {
    
}

- (SJVideoPlayerControlMaskView *)topControlView {
    if ( _topControlView ) return _topControlView;
    _topControlView = [[SJVideoPlayerControlMaskView alloc] initWithStyle:SJMaskStyle_top];
    return _topControlView;
}

#pragma mark - SJBaseVideoPlayer
- (BOOL)controlLayerDisappearCondition {
    return YES;
}

- (UIView *)controlView {
    return self;
}

- (BOOL)triggerGesturesCondition:(CGPoint)location {
    return self;
}

- (void)controlLayerNeedAppear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    
}

- (void)controlLayerNeedDisappear:(__kindof SJBaseVideoPlayer *)videoPlayer {
    
}

@end
NS_ASSUME_NONNULL_END
