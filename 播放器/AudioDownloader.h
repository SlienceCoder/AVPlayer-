//
//  AudioDownloader.h
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AudioDownloaderDelegate <NSObject>

@optional
- (void)downLoading;

@end

@interface AudioDownloader : NSObject
@property (nonatomic, weak) id<AudioDownloaderDelegate> delegate;
@property (nonatomic, assign) long long loadingSize; // 已经加载的大小
@property (nonatomic, assign) long long offset;
@property (nonatomic, assign) long long totalSize;
@property (nonatomic, copy) NSString *mineType;
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset;

@end
