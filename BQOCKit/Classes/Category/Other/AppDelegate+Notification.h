// *******************************************
//  File Name:      AppDelegate+Notification.h       
//  Author:         MrBai
//  Created Date:   2020/7/15 10:54 AM
//    
//  Copyright © 2020 baiqiang
//  All rights reserved
// *******************************************
    



NS_ASSUME_NONNULL_BEGIN

#if __has_include("AppDelegate.h")
#import "AppDelegate.h"
@interface AppDelegate (Notification)

- (void)registerRemoteNotifiCation:(UIApplication *)application;

@end
#endif

NS_ASSUME_NONNULL_END
