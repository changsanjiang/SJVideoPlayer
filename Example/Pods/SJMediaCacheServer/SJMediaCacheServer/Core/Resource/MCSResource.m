//
//  MCSResource.m
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/9.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import "MCSResource.h"
#import "MCSFileManager.h"
#import "MCSResourceSubclass.h"
#import "MCSResourceManager.h"

@interface MCSResource ()<NSLocking, MCSResourcePartialContentDelegate> {
    NSRecursiveLock *_lock;
    NSMutableArray<MCSResourcePartialContent *> *_m;
}
@property (nonatomic) NSInteger id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) MCSResourceUsageLog *log;
@property (nonatomic) NSInteger readWriteCount;
@property (nonatomic) BOOL isCacheFinished;
@end

@implementation MCSResource

- (instancetype)init {
    self = [super init];
    if ( self ) {
        _lock = NSRecursiveLock.alloc.init;
        _m = NSMutableArray.array;
        _readerOperationQueue = dispatch_queue_create("lib.changsanjiang.SJMediaCacheServer.readerOperationQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (MCSResourceType)type {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

- (id<MCSResourceReader>)readerWithRequest:(NSURLRequest *)request {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}
 
- (void)readWriteCountDidChangeForPartialContent:(MCSResourcePartialContent *)content {
//#ifdef DEBUG
//    NSLog(@"%d - -[%@ %s]", (int)__LINE__, NSStringFromClass([self class]), sel_getName(_cmd));
//#endif
}

- (void)partialContent:(MCSResourcePartialContent *)content didWriteDataWithLength:(NSUInteger)length {
    
}

#pragma mark -

@synthesize isCacheFinished = _isCacheFinished;
- (void)setIsCacheFinished:(BOOL)isCacheFinished {
    [self lock];
    _isCacheFinished = isCacheFinished;
    [self unlock];
}

- (BOOL)isCacheFinished {
    [self lock];
    @try {
        return _isCacheFinished;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (nullable NSURL *)playbackURLForCacheWithURL:(NSURL *)URL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
      reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
    userInfo:nil];
}

@synthesize readWriteCount = _readWriteCount;
- (void)setReadWriteCount:(NSInteger)readWriteCount {
    [self lock];
    @try {
        if ( _readWriteCount != readWriteCount ) {
            _readWriteCount = readWriteCount;
        }
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (NSInteger)readWriteCount {
    [self lock];
    @try {
        return _readWriteCount;;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)readWrite_retain {
    self.readWriteCount += 1;
}

- (void)readWrite_release {
    self.readWriteCount -= 1;
}

#pragma mark -

- (NSArray<MCSResourcePartialContent *> *)contents {
    [self lock];
    @try {
        return _m.count >= 0 ? _m : nil;
    } @catch (__unused NSException *exception) {
        
    } @finally {
        [self unlock];
    }
}

- (void)addContents:(NSArray<MCSResourcePartialContent *> *)contents {
    if ( contents.count != 0 ) {
        [self lock];
        [contents makeObjectsPerformSelector:@selector(setDelegate:) withObject:self];
        [_m addObjectsFromArray:contents];
        [self unlock];
    }
}

- (void)addContent:(MCSResourcePartialContent *)content {
    [self lock];
    content.delegate = self;
    [_m addObject:content];
    [self unlock];
}

- (void)removeContent:(MCSResourcePartialContent *)content {
    [self lock];
    [_m removeObject:content];
    [MCSFileManager removeContentWithName:content.name inResource:_name error:NULL];
    [MCSResourceManager.shared didRemoveDataForResource:self length:content.length];
    [self unlock];
}

- (NSString *)filePathOfContent:(MCSResourcePartialContent *)content {
    return [MCSFileManager getFilePathWithName:content.name inResource:_name];
}

#pragma mark -

- (void)lock {
    [_lock lock];
}

- (void)unlock {
    [_lock unlock];
}
@end
