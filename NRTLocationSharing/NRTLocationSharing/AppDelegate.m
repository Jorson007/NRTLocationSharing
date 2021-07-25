//
//  AppDelegate.m
//  NRTLocationSharing
//
//  Created by kwni on 2021/7/23.
//

#import "AppDelegate.h"
#import "NRTMainViewController.h"
#import "NRTLoginViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BMKLocationKit/BMKLocationComponent.h>

static NSString *const kBMKKey = @"wm5LBKk3ezco3rXSGUeWNCrScGfwXAXY";

@interface AppDelegate ()<BMKGeneralDelegate, BMKLocationAuthDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [self initBMKMapManager];
    
    
    NRTLoginViewController *loginVC = [[NRTLoginViewController alloc] init];
    loginVC.delegate = self;
//    NRTMainViewController *locVC = [[NRTMainViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(void)initBMKMapManager{
    // 初始化定位SDK
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:kBMKKey authDelegate:self];
    
    BMKMapManager *mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [mapManager start:kBMKKey  generalDelegate:self];
    if (!ret) {
        NSLog(@"启动引擎失败");
    }

    
}

-(void)changeToMainViewController:(NSString *)username{
    NRTMainViewController *mainVC = [[NRTMainViewController alloc] init];
    mainVC.username = username;
    self.window.rootViewController = mainVC;
    
    
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

#pragma mark - <BMKGeneralDelegate>
/// 联网结果回调
/// @param iError 联网结果错误码信息，0代表联网成功
- (void)onGetNetworkState:(int)iError {
    if (0 == iError) {
        NSLog(@"联网成功");
    } else {
        NSLog(@"联网失败：%d", iError);
    }
}

/// 鉴权结果回调
/// @param iError 鉴权结果错误码信息，0代表鉴权成功
- (void)onGetPermissionState:(int)iError {
    if (0 == iError) {
        NSLog(@"授权成功");
    } else {
        NSLog(@"授权失败：%d", iError);
    }
}

#pragma mark - <BMKLocationAuthDelegate>
/// 返回授权验证错误
/// @param iError 错误号 : 为0时验证通过，具体参加BMKLocationAuthErrorCode
- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError {
    if (iError == 0) {
        NSLog(@"定位鉴权成功");
    } else {
        NSLog(@"定位鉴权失败%zd", iError);
    }
}


@end
