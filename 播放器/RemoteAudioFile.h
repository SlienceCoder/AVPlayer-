//
//  RemoteAudioFile.h
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RemoteAudioFile : NSObject


+ (NSString *)cacheFilePath:(NSURL *)url;
+ (BOOL)cacheFileExist:(NSURL *)rul;
+ (long long)cacheFileSize:(NSURL *)url;

+ (NSString *)contentType:(NSURL *)url;


+ (NSString *)tempFilePath:(NSURL *)url;
+ (long long)tempFileSize:(NSURL *)url;
+ (BOOL)tempFileExist:(NSURL *)rul;
+ (void)moveTemPathToCachePath:(NSURL *)url;

+ (void)clearTempFile:(NSURL *)url;

@end
