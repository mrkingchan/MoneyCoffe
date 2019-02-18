//
//  AppDelegate.m
//  MoneyCoffe
//
//  Created by Jason on 2019/1/14.
//  Copyright © 2019年 Chan. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWebVC.h"
#import "WXApi.h"
#define kWeChatId @"wx5e466bc433c262ef"
#import "UIViewController+Alert.h"
#import "AFNetworking.h"
@interface AppDelegate () <WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    /*
     createTime = "2019-01-31 20:13:52.0";
     description = " \U4eba\U4eba\U63a8";
     domain = "zk27.com";
     id = 2;
     oauhAppId = 1;
     title = "\U4eba\U4eba\U63a8";
     type = 0;
     */
    [[AFHTTPSessionManager manager] POST:@"http://gateway.zk27.com/user/getSiteDomain" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *json = (NSDictionary *)responseObject;
            if ([json[@"rel"] count]) {
                [[NSUserDefaults standardUserDefaults ] setObject:json[@"rel"] forKey:@"systemUrls"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
    
    
    [[AFHTTPSessionManager manager] POST:@"http://gateway.zk27.com/user/getExternalDomain" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSDictionary *json = (NSDictionary *)responseObject;
            if ([json[@"rel"] count]) {
                [[NSUserDefaults standardUserDefaults ] setObject:json[@"rel"] forKey:@"outsideUrl"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
    }];
    
    
    _window.backgroundColor = [UIColor whiteColor];
    _window.rootViewController =[[UINavigationController alloc] initWithRootViewController:[MainWebVC new]];
    [WXApi registerApp:kWeChatId];
    [_window makeKeyAndVisible];
    return YES;
}


// MARK: -  处理三方回调
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options {
    //判断是微信还是支付宝操作
    if ([url.absoluteString rangeOfString:kWeChatId].location != NSNotFound){
        return  [WXApi handleOpenURL:url delegate:self];
    }
    return NO;
}

// MARK: - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        //分享
        SendMessageToWXResp *sendMessageRes = (SendMessageToWXResp *)resp;
        if (sendMessageRes.errCode == 0 ) {
            [_window.rootViewController alertWithTitle:@"分享成功!" complete:nil];
        } else if (sendMessageRes.errCode == WXErrCodeUserCancel) {
            [_window.rootViewController alertWithTitle:@"您取消了分享!" complete:nil];
        } else {
            [_window.rootViewController alertWithTitle:@"分享失败!" complete:nil];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
