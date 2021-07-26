//
//  ViewController.m
//  NRTLocationSharing
//
//  Created by kwni on 2021/7/23.
//

#import "NRTMainViewController.h"
#import <AFNetworking/AFNetworking.h>


#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

@interface NRTMainViewController ()

@property (nonatomic,strong)  BMKLocationManager *locationManager;
@property (nonatomic, strong) BMKMapView *mapView;

@property (nonatomic,strong) MQTTSessionManager *manager;
@property (nonatomic,strong) NSString *rootTopic;

@property (nonatomic,copy) NSString *sharingusername;
@property (nonatomic,strong) NSTimer *timer;


@property (nonatomic, strong) UIButton *coldLocBtn;      //开始定位
@property (nonatomic, strong) UIButton *startShareBtn;   //开始共享位置
@property (nonatomic, strong) UIButton *stopShareBtn;    //停止共享

@property (nonatomic, strong) UILabel *userNoLabel;       //用户名
@property (nonatomic, strong) UITextField *userNoTextFiled;     //用户名


/// 连续定位Annotation
@property (nonatomic, strong) BMKPointAnnotation *hotAnnotation;



@end

@implementation NRTMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"位置共享Demo";
    
    [self setupUI];

    [self initLocationManager];
    
    [self __loadConfiguation];
    
}

-(void)setupUI{
    if(!_mapView){
        _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 600,SCREEN_WIDTH )];
        _mapView.showsUserLocation = YES;
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        // 将当前地图显示缩放等级设置为17级
        [_mapView setZoomLevel:17];
        _mapView.delegate = self;
        [self.view addSubview:_mapView];
    }
    [self.view addSubview:self.coldLocBtn];
    [self.view addSubview:self.startShareBtn];
    [self.view addSubview:self.stopShareBtn];
    [self.view addSubview:self.userNoTextFiled];
    [self.view addSubview:self.userNoLabel];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard:)];
    [self.view addGestureRecognizer:gesture];
}

-(void)dismissKeyBoard:(UITapGestureRecognizer *)tap{
    [_userNoTextFiled resignFirstResponder];
    
}

-(void)__loadConfiguation{
    NSString *deviceID = [UIDevice currentDevice].identifierForVendor.UUIDString;
    NSString *appId = @"pjpqg0";
    NSString *clientId = [NSString stringWithFormat:@"%@@%@",deviceID,appId];
    self.rootTopic = @"root";
    NSString *password = @"123456";
    BOOL  isSSL = FALSE;
    if(!self.manager){
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        self.manager.subscriptions = @{[NSString stringWithFormat:@"%@/IOS", self.rootTopic]:@(0)};
        [self getTokenWithUsername:self.username password:password completion:^(NSString *token) {
            NSLog(@"=======token:%@==========",token);
            [self bindWithUserName:self.username password:token cliendId:clientId isSSL:isSSL];
        }];
    }else{
        [self.manager connectToLast:nil];
    }
}

- (void)connect {
    [self.manager connectToLast:nil];
}

- (void)disConnect {
    [self.manager disconnectWithDisconnectHandler:nil];
    self.manager.subscriptions = @{};
    
}

- (void)getTokenWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *token))response {
    NSString *urlString = @"https://a1.easemob.com/1139210715094625/nrtlocationsharing/token";
    //初始化一个AFHTTPSessionManager
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置请求体数据为json类型
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    //设置响应体数据为json类型
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSDictionary *parameters = @{@"grant_type":@"password",
                                 @"username":username,
                                 @"password":password
                                 };
   
    __block NSString *token  = @"";
    [manager POST:urlString
             parameters:parameters
             headers:nil
             progress:nil
             success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        NSError *error = nil;
                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:&error];
                        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
                        NSLog(@"%s jsonDic:%@",__func__,jsonDic);
                        token = jsonDic[@"access_token"];
                        response(token);}
             failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        NSLog(@"%s error:%@",__func__,error.debugDescription);
                        response(token);
    }];
}

- (void)bindWithUserName:(NSString *)username password:(NSString *)password cliendId:(NSString *)cliendId isSSL:(BOOL)isSSL{
    [self.manager connectTo:@"pjpqg0.cn1.mqtt.chat"
                                port:1883
                                 tls:isSSL
                           keepalive:60
                               clean:YES
                                auth:YES
                                user:username
                                pass:password
                                will:NO
                           willTopic:nil
                             willMsg:nil
                             willQos:0
                      willRetainFlag:NO
                        withClientId:cliendId
                      securityPolicy:[self customSecurityPolicy]
                        certificates:nil
                       protocolLevel:4
                      connectHandler:nil];
    
}

- (MQTTSSLSecurityPolicy *)customSecurityPolicy
{
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    return securityPolicy;
}

// 获取服务器返回数据
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    NSLog(@"------------->>%@",topic);
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *sharingusername = dict[@"sharingusername"];
    NSString *username = @"user2";
    if([sharingusername isEqualToString:self.username]){
        //获取别人分享给自己的位置并描在地图上
        BMKPointAnnotation *anno = [[BMKPointAnnotation alloc] init];
        CLLocationCoordinate2D location;
        location.latitude = [dict[@"latitude"] doubleValue];
        location.longitude = [dict[@"longitude"] doubleValue];
        anno.coordinate = location;
        anno.title = username;
        [self addAnnotation:anno toMapView:self.mapView];
    }
}

-(void)addAnnotation:(BMKPointAnnotation *)annotation toMapView:(BMKMapView *)mapView{
    NSArray<id <BMKAnnotation>> *annotations = mapView.annotations;
    if(annotations.count < 1){
        [self.mapView addAnnotation:annotation];
        return;
    }
    for(int i = 0 ; i < annotations.count ; i++){
        if([annotations[i].title isEqualToString:annotation.title]){
            [self.mapView removeAnnotation:annotations[i]];
            [self.mapView addAnnotation:annotation];
            return;
        }
    }
    [self.mapView addAnnotation:annotation];
}


-(UILabel *)userNoLabel{
    if(!_userNoLabel){
        _userNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 450, 80, 50)];
        _userNoLabel.text = @"用户名：";
    }
    return  _userNoLabel;
}

-(UITextField *)userNoTextFiled{
    if(!_userNoTextFiled){
        _userNoTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(110, 450, 260, 50)];
        _userNoTextFiled.borderStyle = UITextBorderStyleRoundedRect;
        _userNoTextFiled.delegate = self;
    }
    return  _userNoTextFiled;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_userNoTextFiled resignFirstResponder];
    return YES;
}


-(UIButton *)coldLocBtn{
    if(!_coldLocBtn){
        _coldLocBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 650, 120, 50)];
        _coldLocBtn.backgroundColor = [UIColor colorWithRed:34.f / 255.f green:37.f / 255.f blue:61.f / 255.f alpha:1.f];
        [_coldLocBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _coldLocBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_coldLocBtn setTitle:@"开始定位" forState:UIControlStateNormal];
        _coldLocBtn.layer.cornerRadius = 8;
        _coldLocBtn.layer.masksToBounds = YES;
        
        [_coldLocBtn addTarget:self action:@selector(singleLocBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _coldLocBtn;
}
-(UIButton *)startShareBtn{
    if(!_startShareBtn){
        _startShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(150, 650, 120, 50)];
        _startShareBtn.backgroundColor = [UIColor colorWithRed:34.f / 255.f green:37.f / 255.f blue:61.f / 255.f alpha:1.f];
        [_startShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _startShareBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_startShareBtn setTitle:@"共享位置" forState:UIControlStateNormal];
        _startShareBtn.layer.cornerRadius = 8;
        _startShareBtn.layer.masksToBounds = YES;
        
        [_startShareBtn addTarget:self action:@selector(startShareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _startShareBtn;
}

-(void)startShareBtnAction{
    __block int i = 0;
    if(!self.timer){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            i++;
            NSNumber *latitude =[NSNumber numberWithDouble:self.hotAnnotation.coordinate.latitude+0.2*i];
            NSNumber *longitude =[NSNumber numberWithDouble:self.hotAnnotation.coordinate.longitude+0.2*i];
            NSString *sharingusername = self.userNoTextFiled.text ? self.userNoTextFiled.text:@"";
            NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[latitude,longitude,self.username,sharingusername] forKeys:@[@"latitude",@"longitude",@"username",@"sharingusername"]];
            NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
            [self.manager sendData:data
                             topic:[NSString stringWithFormat:@"%@/%@",
                                    self.rootTopic,
                                    @"IOS"]//此处设置多级子topic
                               qos:0
                            retain:FALSE];
        }];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    
}


-(UIButton *)stopShareBtn{
    if(!_stopShareBtn){
        _stopShareBtn = [[UIButton alloc] initWithFrame:CGRectMake(280, 650, 120, 50)];
        _stopShareBtn.backgroundColor = [UIColor colorWithRed:34.f / 255.f green:37.f / 255.f blue:61.f / 255.f alpha:1.f];
        [_stopShareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _stopShareBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_stopShareBtn setTitle:@"停止共享" forState:UIControlStateNormal];
        _stopShareBtn.layer.cornerRadius = 8;
        _stopShareBtn.layer.masksToBounds = YES;
        
        [_stopShareBtn addTarget:self action:@selector(stopShareBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stopShareBtn;
}

-(void)stopShareBtnAction{
//    [self disConnect];
    [self.locationManager stopUpdatingLocation];
    if([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)singleLocBtnAction{
    [self.locationManager startUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
}

-(void)initLocationManager{
    if(!_locationManager){
        _locationManager = [[BMKLocationManager alloc] init];
        // 设置返回位置的坐标系类型
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        // 设置距离过滤参数
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        // 设置预期精度参数
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        // 设置应用位置类型
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        // 设置是否自动停止位置更新
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        // 设置位置获取超时时间
        _locationManager.locationTimeout = 10;
        // 设置获取地址信息超时时间
        _locationManager.reGeocodeTimeout = 10;
        // 设置delegate
        _locationManager.delegate = self;
    }

}


// 定位SDK中，方向变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
}

// 定位SDK中，位置变更的回调
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if(location){
        // 更新我的位置数据
        [self updateHotUserLocation:location];
    }
}

/// 连续定位
- (void)updateHotUserLocation:(BMKLocation *)location {
    // 设置Annotation位置
    self.hotAnnotation.coordinate = location.location.coordinate;
    self.hotAnnotation.title = self.username;
    // 添加Annotation
    if (![self.mapView.annotations containsObject:self.hotAnnotation]) {
        [self.mapView addAnnotation:self.hotAnnotation];
    }
    [self refreshBMKMapView];
}

-(void)refreshBMKMapView{
    // 获取地图状态
    BMKMapStatus *mapStatus = [self.mapView getMapStatus];
    // 设置地图中心点
    mapStatus.targetGeoPt = self.hotAnnotation.coordinate;
    // 设置地图缩放级别
//    mapStatus.fLevel = 17;
    // 设置地图状态
    [self.mapView setMapStatus:mapStatus withAnimation:YES withAnimationTime:500];
}

- (BMKPointAnnotation *)hotAnnotation {
    if (!_hotAnnotation) {
        _hotAnnotation = [[BMKPointAnnotation alloc] init];
    }
    return _hotAnnotation;
}

- (void)dealloc
{
    [self disConnect];
    [self.locationManager stopUpdatingLocation];
    if([self.timer isValid]){
        [self.timer invalidate];
        self.timer = nil;
    }
}



@end
