//
//  SJCTImageData.h
//  Test
//
//  Created by BlueDancer on 2017/12/14.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SJCTImageData : NSObject

@property (nonatomic, strong) NSTextAttachment *imageAttachment;
@property (nonatomic, assign) int postion;
@property (nonatomic, assign) CGRect imagePosition; // Core Text Coordinate

@end
