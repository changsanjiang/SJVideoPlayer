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
#import "SJStringParserConfig.h"

@interface SJCTData : NSObject

- (instancetype)initWithString:(NSString *)string config:(SJStringParserConfig *)config;
- (instancetype)initWithAttributedString:(NSAttributedString *)attrStr config:(SJCTFrameParserConfig *)config;

@property (nonatomic, assign, readonly) CTFrameRef frameRef;
@property (nonatomic, strong, readonly) NSArray<SJCTImageData *> *imageDataArray;
@property (nonatomic, strong, readonly) NSAttributedString *attrStr;
@property (nonatomic, strong, readonly) SJCTFrameParserConfig *config;
@property (nonatomic, assign, readonly) CGFloat width;
@property (nonatomic, assign, readonly) CGFloat height;
@property (nonatomic, strong, readonly) id contents;

- (void)needsDrawing;

- (void)drawingWithContext:(CGContextRef)context;

- (signed long)touchIndexWithPoint:(CGPoint)point;

@end
