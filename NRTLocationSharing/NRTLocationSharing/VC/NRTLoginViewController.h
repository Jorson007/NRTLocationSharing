//
//  NRTMainViewController.h
//
//
//  Created by kwni on 2021/7/24.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface NRTLoginViewController : UIViewController

@property (nonatomic,weak) id<NRTChangeVCProtocol> delegate;

@end

NS_ASSUME_NONNULL_END
