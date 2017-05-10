//
//  NSURL+SZ.m
//  播放器
//
//  Created by xpchina2003 on 2017/5/10.
//  Copyright © 2017年 xpchina2003. All rights reserved.
//

#import "NSURL+SZ.h"

@implementation NSURL (SZ)
- (NSURL *)steamingURL
{
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"sreaming";
    return compents.URL;
}
- (NSURL *)httpURL
{
    NSURLComponents *compents = [NSURLComponents componentsWithString:self.absoluteString];
    compents.scheme = @"http";
    return compents.URL;
}
@end
