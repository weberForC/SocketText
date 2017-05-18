//
//  ViewController.m
//  SocketText
//
//  Created by juanMac on 2017/4/13.
//  Copyright © 2017年 juanMac. All rights reserved.
//

#import "ViewController.h"
#import "SRWebSocket.h"
#import "AFNetworking.h"
#define WEBSCOKET @"ws://park.99iyun.com:80/yunxin/wss"
@interface ViewController ()<SRWebSocketDelegate>
{
    UILabel *textLabel;
    UITextField *textField;
    
    SRWebSocket *_websocket;
    
    BOOL isOpen;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *rquestUrlStr = @"http://newm.99iwork.com/iwork-worker/user/tokenCode.json;jsessionid=65c3ff80-add2-48ce-baa3-c766c8d5ca28";
//    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[rquestUrlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        
//        if (data) {
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            [self withDicAction:dic[@"data"]];
//        }
//        
//    }];
    
    
    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
    
    //LoadingAnimation * loading = [[LoadingAnimation alloc]init];
    
    //[loading circleLoading];
    
    [manager POST:rquestUrlStr parameters:nil success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        //返回的数据
        //[loading closedCircleLoading];
        [self withDicAction:responseObject[@"data"]];
        
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        //[loading closedCircleLoading];
    }];
    
    
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, SCREEN_WIDTH - 40, 40)];
    textLabel.layer.cornerRadius = 5;
    textLabel.font = [UIFont systemFontOfSize:15];
    textLabel.backgroundColor = [UIColor greenColor];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textLabel];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(textLabel.frame) + 20, SCREEN_WIDTH - 40, 40)];
    textField.layer.cornerRadius = 5;
    textField.font = [UIFont systemFontOfSize:15];
    textField.backgroundColor = [UIColor yellowColor];
    textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textField];
    
    UIButton *sendBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    sendBtn.frame = CGRectMake(20, CGRectGetMaxY(textField.frame) + 20, SCREEN_WIDTH - 40, 40);
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn addTarget:self action:@selector(sendMessageAction) forControlEvents:UIControlEventTouchUpInside];
    [sendBtn setBackgroundColor:[UIColor cyanColor]];
    sendBtn.layer.cornerRadius = 5;
    sendBtn.titleLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:sendBtn];
    
    
    
}

- (void)withDicAction:(NSDictionary *)dic
{
    //连接webcosket网址 ws://park.99iyun.com:80/yunxin/wss?appKey=yunbangong&accId=15127132782&random=#c#!#W3n&time=1492048431734&access_token=b36646b12af8ed2a16ea734fe014a07ea3e94a86
    NSString *url= [NSString stringWithFormat:@"%@?appKey=%@&accId=%@&random=%@&time=%@&access_token=%@",WEBSCOKET,dic[@"appKey"],@"15127132782",dic[@"random"],dic[@"time"],dic[@"access_tocken"]];
    _websocket.delegate = nil;
    [_websocket close];
    _websocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[url stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    _websocket.delegate = self;
    [_websocket open];
}

- (void)sendMessageAction
{
    if (isOpen) {
        //发送按钮
        NSString * time = [self getsTheCurrentTimestamp];
        //消息类型个人对话201群组对话130
        NSDictionary * dic = @{@"fromUser":@"15127132782",@"toTag":@"18749457595",@"type":@"201",@"toUser":@"18749457595",@"sendTime":time,@"text":textField.text,@"ex":@{@"type":@"1",@"companyId":@"879956B5E96E"}};
        NSString * messageStr = [self dictionaryToJson:dic];
        [_websocket send:messageStr];
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    isOpen = YES;
    NSLog(@"连接成功");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString *requestTemp=[NSString stringWithString:message];
    NSData *resData = [[NSData alloc] initWithData:[requestTemp dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"resultDic = %@",resultDic);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    
}

- (NSString *)getsTheCurrentTimestamp
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a];//转为字符型
    return timeString;
}

//字典换成字符串
- (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
