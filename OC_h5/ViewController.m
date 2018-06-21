//
//  ViewController.m
//  OC_h5
//
//  Created by wsq on 2018/6/15.
//  Copyright © 2018年 wsq. All rights reserved.
//

#import "ViewController.h"
#import "UIWebView+TS_JavaScriptContext.h"


#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<TSWebViewDelegate>

@property(nonatomic, weak) UIWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 44)];
    [self.view addSubview:button];
    [button setTitle:@"加载H5" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor cyanColor];
    
}

-(void)buttonClick {
    
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"wifi_login" ofType:@"html" inDirectory:@"www"];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight - 20)];
    self.webView = webView;
    webView.delegate = self;
    
    [self.view addSubview:webView];
    
    [webView loadRequest:request];
    
    [self catchJsLog];
    
    // 111---------
}


-(void)webView:(UIWebView *)webView didCreateJavaScriptContext:(JSContext *)ctx {
    
    // 传用户名到h5
    ctx[@"GetUserName_h5"] = ^ {
        
        NSString *userStr = @"张三和李四";
        
        [self callbackDataWithFunctionName:@"GetUserName" withJSONData:userStr];
        NSLog(@"11111111------>");
    };
    
    // h5回传用户名和密码
    ctx[@"SetUserInfo"] = ^{
        NSDictionary *dict = [self GetJSContextDict];
        NSString *userName = dict[@"userName"];
        NSString *userPass = dict[@"userPass"];
        
        NSLog(@"------>%@  %@",userName,userPass);
        // 登录
        NSLog(@"新的吧");
    };
    
}


#pragma mark 回调JS
- (void)callbackDataWithFunctionName:(NSString *)functionName withJSONData:(NSString *)jsonStr{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"JS callback---->%@  -->%@",functionName,jsonStr);
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"WECallBackData('%@', '%@')", functionName, jsonStr]];
    });
}

#pragma mark - 获取H5传递过来的值
-(NSDictionary *)GetJSContextDict{
    NSArray *array = [JSContext currentArguments];
    NSMutableDictionary *dictM = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < array.count; i++){
        NSString *keyStr = [NSString stringWithFormat:@"%@",array[i]];
        NSArray *arr = [keyStr componentsSeparatedByString:@"="];
        [dictM setObject:arr[1] forKey:arr[0]];
    }
    return dictM;
}

// 打印h5的log
- (void)catchJsLog{
    if(DEBUG){
        JSContext *ctx = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        ctx[@"console"][@"log"] = ^(JSValue * msg) {
            NSLog(@"H5  log : %@", msg);
        };
        ctx[@"console"][@"warn"] = ^(JSValue * msg) {
            NSLog(@"H5  warn : %@", msg);
        };
        ctx[@"console"][@"error"] = ^(JSValue * msg) {
            NSLog(@"H5  error : %@", msg);
        };
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end







