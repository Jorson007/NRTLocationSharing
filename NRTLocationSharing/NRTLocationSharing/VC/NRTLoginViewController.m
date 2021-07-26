//
//  NRTMainViewController.m
//
//  登陆页面
//  Created by kwni on 2021/7/24.
//

#import "NRTLoginViewController.h"
#import "NRTMainViewController.h"

#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


@interface NRTLoginViewController ()

@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;


@end

@implementation NRTLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showLoginView];
    // Do any additional setup after loading the view.
    
}

//显示登陆页面的元素
-(void)showLoginView{
    self.title = @"登录";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, 120, 100, 100)];
    imageView.image = [UIImage imageNamed:@"denglu.png"];
    [self.view addSubview:imageView];
    //把imageView加到视图中
    
    UILabel *userLabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 270, 70, 50)];
    userLabel.text=@"用户名";
    [self.view addSubview:userLabel];
    
    _username=[[UITextField alloc]init];
    _username.frame=CGRectMake(100, 275, SCREEN_WIDTH-150, 40);
    _username.borderStyle = UITextBorderStyleRoundedRect;
    _username.layer.borderColor=[UIColor brownColor].CGColor;
    _username.layer.borderWidth=1;
    _username.layer.cornerRadius=5;
    [self.view addSubview:_username];
    
    UILabel *passLabel=[[UILabel alloc]initWithFrame:CGRectMake(30, 340, 70, 50)];
    passLabel.text=@"密   码";
    [self.view addSubview:passLabel];
    
    _password=[[UITextField alloc]init];
    _password.frame=CGRectMake(100, 345, SCREEN_WIDTH-150, 40);
    _password.borderStyle = UITextBorderStyleRoundedRect;
    _password.secureTextEntry=YES;  //输入的字符变成*号
    _password.clearButtonMode=UITextFieldViewModeAlways;  //有“X”键可以清空文本
    _password.layer.borderColor=[UIColor brownColor].CGColor;
    _password.layer.borderWidth=1;
    _password.layer.cornerRadius=5;
    [self.view addSubview:_password];
    
    UIButton *but=[UIButton buttonWithType:UIButtonTypeRoundedRect];
    but.frame=CGRectMake(SCREEN_WIDTH/2-30, SCREEN_HEIGHT-150, 60, 60);
    [but setImage:[UIImage imageNamed:@"next.png"] forState:UIControlStateNormal];
    [but addTarget:self action:@selector(jumpToNext) forControlEvents:UIControlEventTouchUpInside];
    //按键跳转事件，self指代自身。selector（）里面写的是跳转方法,即跳转到jumpToNext()方法。监听“点击事件”，所以是UIControlEventTouchUpInside
    [but setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:but];
}

//目前只开通了两个用户用来测试
//user1:123456
//user2:123456
-(void)jumpToNext{
    if(([self.username.text isEqualToString:@"user1"]|| [self.username.text isEqualToString:@"user2"]|| [self.username.text isEqualToString:@"user3"]) && ([self.password.text isEqualToString:@"123456"]))
    [self.delegate changeToMainViewController:self.username.text];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}



@end
