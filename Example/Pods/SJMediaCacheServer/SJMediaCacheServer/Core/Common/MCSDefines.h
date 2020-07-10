//
//  MCSDefines.h
//  Pods
//
//  Created by BlueDancer on 2020/7/6.
//

#ifndef MCSDefines_h
#define MCSDefines_h

typedef NS_ENUM(NSUInteger, MCSResourceType) {
    MCSResourceTypeVOD,
    MCSResourceTypeHLS
};

typedef enum : NSUInteger {
    MCSDataTypeHLSMask      = 0xFF,
    MCSDataTypeHLSPlaylist  = 1,
    MCSDataTypeHLSAESKey    = 2,
    MCSDataTypeHLSTs        = 3,
    MCSDataTypeHLS          = 1 << MCSDataTypeHLSPlaylist | 1 << MCSDataTypeHLSAESKey | 1 << MCSDataTypeHLSTs,

    MCSDataTypeVODMask      = 0xFF00,
    MCSDataTypeVOD          = 1 << 8,
} MCSDataType;

#endif /* MCSDefines_h */
