//
//  RemotePlayer.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/9.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "RemotePlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "RemoteResourceLoaderDelegate.h"
#import "NSURL+SZ.h"

@interface RemotePlayer ()
{
    BOOL _isUserPause;
}
@property (nonatomic, strong) AVPlayer *play;

@property (nonatomic, strong) RemoteResourceLoaderDelegate *remoteResourcedelegate;

@end

@implementation RemotePlayer
static RemotePlayer *_player;
+ (instancetype)shareInstance
{
    if (!_player) {
        _player = [[RemotePlayer alloc] init];
    }
    return _player;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    if (!_player) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _player = [super allocWithZone:zone];
        });
    }
    return _player;
}
- (void)playWithURL:(NSURL *)url isCache:(BOOL)cache
{
    NSURL *currentUrl = [(AVURLAsset *)self.play.currentItem.asset URL];
    if ([url isEqual:currentUrl]||[[url steamingURL] isEqual:currentUrl]) {
        NSLog(@"当前任务已经存在");
        [self resume];
        return;
    }
    
    
    
    _url = url;
    if (cache) {
        url = [url steamingURL];
    }
    
    // 资源的请求
    AVURLAsset *ass = [AVURLAsset assetWithURL:url];
    
    // 关于网络音频的请求，是通过这个对象，调用代理的相关方法，进行加载的
    // 拦截加载的请求，只需要重新修改他的代理方法就可以
    self.remoteResourcedelegate = [RemoteResourceLoaderDelegate new];
    [ass.resourceLoader setDelegate:self.remoteResourcedelegate queue:dispatch_get_main_queue()];
    
    if (self.play.currentItem) {
        [self removeObserve];
    }
    
    
    // 资源的组织
    AVPlayerItem *Item = [AVPlayerItem playerItemWithAsset:ass];
    
    // 当资源的组织者告诉我们资源准备完毕播放
    // AVPlayerItemStatus status
    [Item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [Item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    // 创建一个播放器
    self.play = [AVPlayer playerWithPlayerItem:Item];
    

    
    
}

- (void)pause
{
    [self.play pause];
    _isUserPause = YES;
    
    if (self.play) {
        self.state = RemoteAudioPlayerStatePause;
    }
    
}
- (void)resume
{
    [self.play play];
    _isUserPause = NO;
    // 当前播放器存在并且数据组织者里面的数据准备已经足够播放
    if (self.play&&self.play.currentItem.playbackLikelyToKeepUp) {
         self.state = RemoteAudioPlayerStatePlaying;
    }
   
}
- (void)stop
{
    [self.play pause];
    self.play = nil;
    
    if (self.play) {
        self.state = RemoteAudioPlayerStateStopped;
    }
}


- (void)seekWithTimeDiffer:(NSTimeInterval)timerdiffer
{
    // 总时长
    
    NSTimeInterval total =  [self totalTime];
    // 已经播放的时长
   
    
   NSTimeInterval playTimeSec =  [self currentTime];
    playTimeSec += timerdiffer;
    
    [self seekWithTimeprogress:playTimeSec / total];

}
- (void)seekWithTimeprogress:(float)progress
{
    if (progress<0 || progress>1) {
        return;
    }
    // 可以指定时间节点去播放
    // 时间CMTime : 影片时间
    // 影片时间转成秒
    // 秒-》饮片时间
    
    
    // 总时长
    
    // 已经播放的时长
//    self.play.currentItem.currentTime
    
    
 
    
    NSTimeInterval playTimeSec = self.totalTime * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    
    [self.play seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        } else {
            NSLog(@"取消加载这个时间点的音频资源");
        }
        
    }];
    
}

- (void)setRate:(float)rate
{
    [self.play setRate:rate];
}
- (float)rate
{
    return self.play.rate;
}

- (void)setMute:(BOOL)muted
{
    [self.play setMuted:muted];
}
- (BOOL)muted
{
    return self.play.muted;
}
- (void)setVolume:(float)volume
{
    
    if (volume < 0|| volume>1) {
        return;
    }
    if (volume>0) {
        [self setMute:NO];
    }
    
    [self.play setVolume:volume];
}
- (float)volume
{
    return self.play.volume;
}

- (NSString *)currentTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.currentTime/60,(int)self.currentTime%60];
}
- (NSString *)totalTimeFormat
{
    return [NSString stringWithFormat:@"%02zd:%02zd",(int)self.totalTime/60,(int)self.totalTime%60];
}


#pragma mark --数据事件
- (NSTimeInterval)totalTime
{
    CMTime totalTime = self.play.currentItem.duration;
    NSTimeInterval total =  CMTimeGetSeconds(totalTime);
    if (isnan(total)) {
        return 0;
    }
    return total;
}

- (NSTimeInterval)currentTime
{
    CMTime currentTime = self.play.currentItem.currentTime;
    
    NSTimeInterval playTimeSec = CMTimeGetSeconds(currentTime);
    
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}
- (float)progress
{
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime/self.totalTime;
}
- (float)loadDataProgress
{
    if (self.totalTime == 0) {
        return 0;
    }
    
   CMTimeRange timeRange = [[[self.play.currentItem loadedTimeRanges] lastObject] CMTimeRangeValue];
    
  CMTime loadtime =  CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadtime);
    
    return loadTimeSec/self.totalTime;
}

- (void)setState:(RemoteAudioPalyerState)state
{
    _state = state;
    // 告知外界相关事件通知外界
   
}

- (void)removeObserve
{
    [self.play.currentItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.play.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp" context:nil]; // playbackLikelyToKeepUp
}

- (void)playEnd
{
    NSLog(@"播放完成");
    self.state = RemoteAudioPlayerStateStopped;
}
- (void)playInterupt
{
    // 来电话。资源加载跟不上
    NSLog(@"播放打断");
    self.state = RemoteAudioPlayerStatePause;
}

#pragma mark -- KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) { // 开始播放
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备完毕,准备播放");
            [self resume];
            
        } else {
            NSLog(@"状态未知");
            self.state = RemoteAudioPlayerStateFaild;
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) { // 播放过程中
        
//        self.play.currentItem.playbackLikelyToKeepUp
        BOOL ptk = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (ptk) {
            NSLog(@"当前资源已经准备的足够播放了");
//            [self resume];
            // 用户的手动暂停的优先级最高
            
            if (!_isUserPause) {
                [self resume];
            } else {
            
            }
            
        } else{
            NSLog(@"资源还不够，正在记载过程中");
            self.state = RemoteAudioPlayerStateLoading;
        }
        
    }
}

@end
