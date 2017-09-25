//
//  SJVideoPlayerSettings.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/9/25.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage, UIColor;

@interface SJVideoPlayerSettings : NSObject
    // MARK: btns
    @property (nonatomic, strong, readwrite) UIImage *backBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *playBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *pauseBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *replayBtnImage;
    @property (nonatomic, strong, readwrite) NSString *replayBtnTitle;
    @property (nonatomic, assign, readwrite) float replayBtnFontSize;
    @property (nonatomic, strong, readwrite) UIImage *fullBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *previewBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *moreBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *lockBtnImage;
    @property (nonatomic, strong, readwrite) UIImage *unlockBtnImage;
    
    // MARK: slider
    @property (nonatomic, strong, readwrite) UIColor *traceColor;
    @property (nonatomic, strong, readwrite) UIColor *trackColor;
    @property (nonatomic, strong, readwrite) UIColor *bufferColor;
    
    // MARK: volume & brightness
    @property (nonatomic, strong, readwrite) UIImage *volumeImage;
    @property (nonatomic, strong, readwrite) UIImage *muteImage;
    @property (nonatomic, strong, readwrite) UIImage *brightnessImage;
    
    // MARK: Loading
    @property (nonatomic, strong, readwrite) UIColor *loadingLineColor;
    @property (nonatomic, assign, readwrite) float loadingLineWidth;
@end
