//
//  SJVideo.h
//  SJMediaDownloader
//
//  Created by BlueDancer on 2018/3/16.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SJVideo : NSObject
@property (nonatomic, assign, readonly) NSInteger mediaId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *playURLStr;
@property (nonatomic, strong, readonly) NSString *coverURLStr;

// test
+ (NSArray<SJVideo *> *)testVideos;
@property (nonatomic, strong, readonly) NSString *testCoverImage;

@end
