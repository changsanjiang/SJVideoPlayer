//
//  TestItem.h
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/2/25.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestItem : NSObject

@property (nonatomic, strong) NSString *title;

- (instancetype)initWithTitle:(NSString *)title;

@end
