//
//  AudioDownloader.h
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioDownloader : NSObject
@property (nonatomic, assign) long long loadingSize; // 已经加载的大小
- (void)downloadWithURL:(NSURL *)url offset:(long long)offset;

@end
