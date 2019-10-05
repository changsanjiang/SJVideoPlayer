//
//  SJPlaybackListControllerObserver.h
//  SJPlaybackListController
//
//  Created by 畅三江 on 2019/1/23.
//

#import <Foundation/Foundation.h>
#import "SJPlaybackListControllerProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface SJPlaybackListControllerObserver : NSObject<SJPlaybackListControllerObserver>
- (instancetype)initWithListController:(id<SJPlaybackListController>)controller;
@end
NS_ASSUME_NONNULL_END
