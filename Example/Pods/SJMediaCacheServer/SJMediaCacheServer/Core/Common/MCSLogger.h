//
//  MCSLogger.h
//  SJMediaCacheServer_Example
//
//  Created by 畅三江 on 2020/6/8.
//  Copyright © 2020 changsanjiang@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCSDefines.h"

NS_ASSUME_NONNULL_BEGIN
@interface MCSLogger : NSObject
+ (instancetype)shared;

/// If yes, the log will be output on the console. The default value is NO.
@property (nonatomic, getter=isEnabledConsoleLog) BOOL enabledConsoleLog;

/// The default value is MCSLogOptionDefault.
@property (nonatomic) MCSLogOptions options;

/// The default value is MCSLogLevelDebug.
@property (nonatomic) MCSLogLevel level;

- (void)option:(MCSLogOptions)option level:(MCSLogLevel)level addLog:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);
@end

#ifdef DEBUG
#define MCSDebugLog(__option__, format, arg...) \
    [MCSLogger.shared option:__option__ level:MCSLogLevelDebug addLog:format, ##arg]
#define MCSErrorLog(__option__, format, arg...) \
    [MCSLogger.shared option:__option__ level:MCSLogLevelError addLog:format, ##arg]

// prefetcher
#define MCSPrefetcherDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionPrefetcher, format, ##arg)
#define MCSPrefetcherErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionPrefetcher, format, ##arg)

// asset reader
#define MCSAssetReaderDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionAssetReader, format, ##arg)
#define MCSAssetReaderErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionAssetReader, format, ##arg)

// content reader
#define MCSContentReaderDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionContentReader, format, ##arg)
#define MCSContentReaderErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionContentReader, format, ##arg)

// downloader
#define MCSDownloaderDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionDownloader, format, ##arg)
#define MCSDownloaderErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionDownloader, format, ##arg)

// HTTP connection
#define MCSHTTPConnectionDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionHTTPConnection, format, ##arg)
#define MCSHTTPConnectionErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionHTTPConnection, format, ##arg)

// proxy Task
#define MCSProxyTaskDebugLog(format, arg...) \
    MCSDebugLog(MCSLogOptionProxyTask, format, ##arg)
#define MCSProxyTaskErrorLog(format, arg...) \
    MCSErrorLog(MCSLogOptionProxyTask, format, ##arg)

#else
#define MCSDebugLog(option, format, arg...)
#define MCSErrorLog(option, format, arg...)
#define MCSPrefetcherDebugLog(format, arg...)
#define MCSPrefetcherErrorLog(format, arg...)
#define MCSAssetReaderDebugLog(format, arg...)
#define MCSAssetReaderErrorLog(format, arg...)
#define MCSContentReaderDebugLog(format, arg...)
#define MCSContentReaderErrorLog(format, arg...)
#define MCSDownloaderDebugLog(format, arg...)
#define MCSDownloaderErrorLog(format, arg...)
#define MCSHTTPConnectionDebugLog(format, arg...)
#define MCSHTTPConnectionErrorLog(format, arg...)
#define MCSProxyTaskDebugLog(format, arg...)
#define MCSProxyTaskErrorLog(format, arg...)
#endif
NS_ASSUME_NONNULL_END
