//
//  SJVideo+DownloadAdd.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2018/3/17.
//  Copyright © 2018年 SanJiang. All rights reserved.
//

#import "SJVideo+DownloadAdd.h"
#import <objc/message.h>

@implementation SJVideo (DownloadAdd)

- (void)setDownloadStatus:(SJMediaDownloadStatus)downloadStatus {
    objc_setAssociatedObject(self, @selector(downloadStatus), @(downloadStatus), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SJMediaDownloadStatus)downloadStatus {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setDownloadProgress:(float)downloadProgress {
    objc_setAssociatedObject(self, @selector(downloadProgress), @(downloadProgress), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (float)downloadProgress {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void)setFilePath:(NSString *)filePath {
    objc_setAssociatedObject(self, @selector(filePath), filePath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)filePath {
    return objc_getAssociatedObject(self, _cmd);
}
@end
