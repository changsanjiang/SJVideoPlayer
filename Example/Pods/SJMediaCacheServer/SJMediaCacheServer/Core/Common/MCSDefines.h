//
//  MCSDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/7/6.
//

#ifndef MCSDefines_h
#define MCSDefines_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MCSAssetType) {
    MCSAssetTypeFILE,
    MCSAssetTypeHLS
};

typedef NS_OPTIONS(NSUInteger, MCSDataType) {
    MCSDataTypeHLSMask      = 0xFF,
    MCSDataTypeHLSPlaylist  = 1,
    MCSDataTypeHLSAESKey    = 2,
    MCSDataTypeHLSTs        = 3,
    MCSDataTypeHLS          = 1 << MCSDataTypeHLSPlaylist | 1 << MCSDataTypeHLSAESKey | 1 << MCSDataTypeHLSTs,

    MCSDataTypeFILEMask      = 0xFF00,
    MCSDataTypeFILE          = 1 << 8,
};


typedef NS_OPTIONS(NSUInteger, MCSLogOptions) {
    MCSLogOptionPrefetcher          = 1 << 0,
    MCSLogOptionAssetReader         = 1 << 1,
    MCSLogOptionContentReader       = 1 << 2,
    MCSLogOptionDownloader          = 1 << 3,
    MCSLogOptionHTTPConnection      = 1 << 4,
    MCSLogOptionSQLite              = 1 << 5,
    MCSLogOptionProxyTask           = 1 << 6,
    
    MCSLogOptionDefault = MCSLogOptionProxyTask | MCSLogOptionPrefetcher,
    MCSLogOptionAll = MCSLogOptionPrefetcher | MCSLogOptionAssetReader | MCSLogOptionContentReader | MCSLogOptionDownloader | MCSLogOptionHTTPConnection | MCSLogOptionSQLite | MCSLogOptionProxyTask,
};

typedef NS_ENUM(NSUInteger, MCSLogLevel) {
    MCSLogLevelDebug,
    MCSLogLevelError,
};


typedef NS_ENUM(NSUInteger, MCSReaderStatus) {
    MCSReaderStatusUnknown,
    MCSReaderStatusPreparing,
    MCSReaderStatusReadyToRead,
    MCSReaderStatusFinished, 
    MCSReaderStatusAborted,
};
#endif /* MCSDefines_h */
