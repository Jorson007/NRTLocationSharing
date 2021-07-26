//
//  ViewController.h
//  NRTLocationSharing
//
//  Created by kwni on 2021/7/23.
//

#import <UIKit/UIKit.h>
#import <BMKLocationKit/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//引入base相关所有的头文件
#import <BaiduMapAPI_Map/BMKMapComponent.h>//引入地图功能所有的头文件
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>

@interface NRTMainViewController : UIViewController<BMKLocationManagerDelegate,BMKMapViewDelegate,MQTTSessionManagerDelegate,UITextFieldDelegate>

@property (nonatomic,copy) NSString *username;


@end

