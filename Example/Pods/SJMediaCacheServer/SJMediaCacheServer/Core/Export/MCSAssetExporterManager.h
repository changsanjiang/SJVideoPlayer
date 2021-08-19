//
//  MCSAssetExporterManager.h
//  SJMediaCacheServer
//
//  Created by BD on 2021/3/10.
//

#import <Foundation/Foundation.h>
#import "MCSInterfaces.h"
#import "MCSAssetExporterDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MCSAssetExporterManager : NSObject<MCSAssetExporterManager>
+ (instancetype)shared;

- (void)registerObserver:(id<MCSAssetExportObserver>)observer;
- (void)removeObserver:(id<MCSAssetExportObserver>)observer;

@property (nonatomic) NSInteger maxConcurrentExportCount;

@property (nonatomic, strong, readonly, nullable) NSArray<id<MCSAssetExporter>> *allExporters;

@property (nonatomic, readonly) UInt64 countOfBytesAllExportedAssets;
 
- (nullable id<MCSAssetExporter>)exportAssetWithURL:(NSURL *)URL;
- (void)removeAssetWithURL:(NSURL *)URL;
- (void)removeAllAssets;
 
- (MCSAssetExportStatus)statusWithURL:(NSURL *)URL;
- (float)progressWithURL:(NSURL *)URL; 
 
- (void)synchronizeForExporterWithAssetURL:(NSURL *)URL;
- (void)synchronize;

- (nullable NSArray<id<MCSAssetExporter>> *)exportsForMask:(MCSAssetExportStatusQueryMask)mask;
@end
NS_ASSUME_NONNULL_END
