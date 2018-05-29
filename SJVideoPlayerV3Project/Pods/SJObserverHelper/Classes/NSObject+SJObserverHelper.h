//
//  NSObject+SJObserverHelper.h
//  TmpProject
//
//  Created by BlueDancer on 2017/12/8.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SJObserverHelper)

- (void)sj_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
