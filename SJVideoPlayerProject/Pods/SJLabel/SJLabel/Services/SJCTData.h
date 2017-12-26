//
//  SJCTData.h
//  Test
//
//  Created by BlueDancer on 2017/12/13.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>
#import "SJCTImageData.h"
#import "SJCTFrameParserConfig.h"

@interface SJCTData : NSObject<NSCopying>

@property (nonatomic, assign) CTFrameRef frameRef;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat height_t;
@property (nonatomic, strong) NSArray<SJCTImageData *> *imageDataArray;
@property (nonatomic, strong) NSAttributedString *attrStr;
@property (nonatomic, strong) SJCTFrameParserConfig *config;


- (void)needsDrawing;

- (void)drawingWithContext:(CGContextRef)context;

- (signed long)touchIndexWithPoint:(CGPoint)point;

@end
