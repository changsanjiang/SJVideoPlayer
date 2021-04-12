//
//  MCSDatabase.m
//  SJMediaCacheServer
//
//  Created by BD on 2021/3/20.
//

#import "MCSDatabase.h"
#import "MCSRootDirectory.h"
 
SJSQLite3 *
MCSDatabase(void) {
    static SJSQLite3 *sqlite3;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sqlite3 = [SJSQLite3.alloc initWithDatabasePath:[MCSRootDirectory databasePath]];
    });
    return sqlite3;
}
