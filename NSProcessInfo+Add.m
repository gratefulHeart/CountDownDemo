//
//  NSProcessInfo+Add.m
//  CountDownDemo
//
//  Created by gfy on 2020/3/1.
//  Copyright © 2020 gfy. All rights reserved.
//

#import "NSProcessInfo+Add.h"
#include <sys/sysctl.h>

@implementation NSProcessInfo (Add)
- (NSTimeInterval)correctSystemUptime {
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    struct timeval now;
    struct timezone tz;
    gettimeofday(&now, &tz);
    
    double uptime = -1;
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
        uptime = now.tv_sec - boottime.tv_sec;
        uptime += (double)(now.tv_usec - boottime.tv_usec) / 1000000.0;
        
        uptime = uptime > 0 ? uptime : self.systemUptime;
    }
    else {
        uptime = self.systemUptime;
    }
    
    return uptime;
}
@end
