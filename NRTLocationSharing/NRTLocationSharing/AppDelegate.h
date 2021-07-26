//
//  AppDelegate.h
//  NRTLocationSharing
//
//  Created by kwni on 2021/7/23.
//

#import <UIKit/UIKit.h>
#import "NRTMainViewController.h"

@protocol NRTChangeVCProtocol <NSObject>

-(void)changeToMainViewController:(NSString *)username;//登陆切换到主页

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate,NRTChangeVCProtocol>

@property (strong, nonatomic) UIWindow *window;



@end

