//
//  MainWebVC.m
//  爱阅读
//
//  Created by Macx on 2018/6/7.
//  Copyright © 2018年 Chan. All rights reserved.
//

#import "MainWebVC.h"
#import <WebKit/WebKit.h>
#import "JHUD.h"
#import "ShareView.h"
#import <MJRefresh/MJRefresh.h>
#import <MJExtension/MJExtension.h>
#import <SVProgressHUD.h>
#import "WXApi.h"
#import "UIViewController+Alert.h"
#import "UIColor+HexString.h"
#define kURL(xxx) [NSURL URLWithString:xxx]
#define iPhoneX_BOTTOM_HEIGHT  ([UIScreen mainScreen].bounds.size.height==812?34:0)

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define JHUDRGBA(r,g,b,a)     [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

@interface MainWebVC () <WKNavigationDelegate,WKScriptMessageHandler> {
    WKWebView *_webView;
    WKWebViewConfiguration *_configure;
    UILabel*_showErrorMessage;
    NSString *_urlStr;
    BOOL _flag;
    int _index;
    
    BOOL _outFlag;
    int _outIndex;
}

@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic) JHUD *hudView;

@end

@implementation MainWebVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19]}];
#define kBackColor     [UIColor colorWithRed:244/255.0 green:243/255.0 blue:244/255.0 alpha:1.0]
    UIImage *bgimage = [self imageFromColor:[UIColor whiteColor] withSize:CGSizeMake(self.view.frame.size.width, kStatusBarHeight + 44.f)];
    [self.navigationController.navigationBar setBackgroundImage:bgimage forBarMetrics:UIBarMetricsDefault];
    UIImage *lineImage = [self imageFromColor:kBackColor withSize:CGSizeMake(self.view.frame.size.width, 0.5f)];
    [self.navigationController.navigationBar setShadowImage:lineImage];
    
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"#3a3a3a"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"refresh"]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:0 target:self action:@selector(buttonAction:)];
    self.hudView = [[JHUD alloc]initWithFrame:self.view.bounds];
    _index = 0;
    _outIndex = 0;
    _configure = [WKWebViewConfiguration new];
    _configure.userContentController = [WKUserContentController new];
    [_configure.userContentController addScriptMessageHandler:self name:@"shareToWeChat"];
    NSString *urlStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"webUrl"];
    if (!urlStr) {
     _urlStr = @"http://m.zk27.com";
    } else {
        _urlStr = urlStr;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //webView
    //CGRectMake(0, kStatusBarHeight, [UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height - kStatusBarHeight)
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 5.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - kStatusBarHeight - 44 ) configuration:_configure];
    _webView.navigationDelegate = self;
    _webView.allowsBackForwardNavigationGestures = YES;
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
    [self.view addSubview:_webView];
    
    
     self.progressView = [[UIProgressView alloc] init];
     self.progressView.progressViewStyle = UIProgressViewStyleBar;
     self.progressView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 5.0);
     self.progressView.trackTintColor = [UIColor lightGrayColor];
     self.progressView.progressTintColor = [UIColor colorWithHexString:@"#f75946"];
     self.progressView.progress = 0.0;
     [self.view addSubview:self.progressView];
    [_webView addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    if (@available(iOS 11.0, *)) {
        self.additionalSafeAreaInsets = UIEdgeInsetsMake(0, 0, iPhoneX_BOTTOM_HEIGHT, 0);
        _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    /*
    ///下拉刷新
    __weak typeof(self)weakSelf = self;
    [_webView.scrollView  addLegendHeaderWithRefreshingBlock:^{
        MainWebVC *strongSelf = weakSelf;
        [strongSelf->_webView loadRequest:[NSURLRequest requestWithURL:kURL(strongSelf-> _urlStr)]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongSelf->_webView.scrollView.header  endRefreshing];
        });
    }];
     */
    
    ///注册JS method
    _showErrorMessage = [[UILabel alloc] init];
    [_showErrorMessage setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [_showErrorMessage setFrame:self.view.bounds];
    _showErrorMessage.numberOfLines = 2;
    _showErrorMessage.textAlignment = NSTextAlignmentCenter;
    [_showErrorMessage setTextColor:[UIColor lightGrayColor]];
    _showErrorMessage.center = self.view.center;
    _showErrorMessage.hidden = YES;
    [self.view addSubview:_showErrorMessage];
}


// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object ==  _webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.progressView.alpha = 1.0f;
        [self.progressView setProgress:newprogress animated:YES];
        if (newprogress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.progressView.alpha = 0.0f;
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0 animated:NO];
                             }];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (UIImage*) imageFromColor: (UIColor*) color withSize:(CGSize)size{
        CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
    
        CGContextRef context = UIGraphicsGetCurrentContext();
    
        CGContextSetFillColorWithColor(context, [color CGColor]);
    
        CGContextFillRect(context, rect);
    
        UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    
        UIGraphicsEndImageContext();
    
        return theImage;
    
}

// MARK: - private Method
- (void)buttonAction:(id)sender {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_urlStr]]];
}

// MARK: - 动画loading
- (void)circleJoinAnimation {
    self.hudView.messageLabel.text = @"加载中...";
    self.hudView.indicatorForegroundColor = JHUDRGBA(60, 139, 246, .5);
    self.hudView.indicatorBackGroundColor = JHUDRGBA(185, 186, 200, 0.3);
    [self.hudView showAtView:self.view hudType:JHUDLoadingTypeDot];
    [self.hudView hideAfterDelay:4.0];
}

// MARK: - private Method
- (void)loadWithUrlStr:(NSString *)urlStr {
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
}

- (void) showNoNetworkError {
    [self.view bringSubviewToFront:_showErrorMessage];
    _showErrorMessage.hidden = false;
    _showErrorMessage.text = @"当前网络连接不稳定,请检查网络配置";
}

- (void)hideNetWorkError {
    [self.view sendSubviewToBack:_showErrorMessage];
    _showErrorMessage.hidden = true;
}

// MARK: - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    _flag = _outFlag = NO;
    _urlStr = navigationAction.request.URL.absoluteString;
    NSLog(@"url = %@",navigationAction.request.URL.absoluteString);
    if ([_urlStr isEqualToString:@"http://m.zk27.com/html/user/index.html"]) {
            [[NSUserDefaults standardUserDefaults] setObject:_urlStr forKey:@"webUrl"];
            [[NSUserDefaults standardUserDefaults] synchronize];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)back {
    if ([_webView canGoBack]) {
        [_webView goBack];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.hudView hide];
//    [SVProgressHUD dismiss];
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_webView.scrollView.header endRefreshing];
    });
     */
    
    _showErrorMessage.hidden = true;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showNoNetworkError];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //最多5秒之后自动隐藏
//    [self circleJoinAnimation];
//    [SVProgressHUD show];
    _showErrorMessage.hidden = YES;
    
    NSArray * domains = [[NSUserDefaults standardUserDefaults] objectForKey:@"systemUrls"];
    if (domains != nil &&domains.count  ) {
        for (int i = 0 ; i <domains.count; i ++) {
            NSDictionary *json = domains[i];
            if ([_urlStr rangeOfString:json[@"domain"]].location != NSNotFound && ![_urlStr hasSuffix:json[@"domain"]]) {
                _flag = YES;
                _index = i;
                break;
            }
        }
    }
    
    if (_flag) {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.title =domains[_index][@"title"];
    } else {
        
        UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:0 target:self action:@selector(back)];
        UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:0 target:self action:@selector(close)];

        self.navigationItem.leftBarButtonItems = @[item2,item1];
        //在扩展域名判断
        NSArray *outsideDomains = [[NSUserDefaults standardUserDefaults] objectForKey:@"outsideUrl"];
        if (outsideDomains!=nil && outsideDomains.count) {
            for (int i = 0 ; i <outsideDomains.count; i ++) {
                NSDictionary *json = outsideDomains[i];
                if ([_urlStr rangeOfString:json[@"domain"]].location != NSNotFound) {
                    _outFlag = YES;
                    _outIndex = i;
                    break;
                }
            }
        }
        if (_outFlag) {
            //在扩展域名之内的
            self.navigationItem.title =outsideDomains[_outIndex][@"title"];
        } else {
            //例如 m.xxx.com/ret
           /*NSArray *items =  [[_urlStr componentsSeparatedByString:@"com"][0] componentsSeparatedByString:@"."];
            
            NSString *title = @"";*/
            NSRange range = [_urlStr rangeOfString:@"(?<=://)[a-zA-Z\.0-9]+(?=\/|:)" options:NSRegularExpressionSearch];
            NSString *title = [_urlStr substringWithRange:range];
            if ([title rangeOfString:@"www."].location != NSNotFound) {
                title =  [title stringByReplacingOccurrencesOfString:@"www." withString:@""];
            }
            self.navigationItem.title = [NSString stringWithFormat:@"来自 %@",title];
        }
    }
    
}

- (void)close {
    NSString *urlStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"webUrl"];
    if (!urlStr) {
        _urlStr = @"http://m.zk27.com";
    } else {
        _urlStr = urlStr;
    }
    [_webView loadRequest:[NSURLRequest requestWithURL:kURL(_urlStr)]];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    _showErrorMessage.hidden = true;
}

#define krandom(from,to) (int)(from+rand()%(to-from+1))
// MARK: - WKScriptDelegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary * value = message.body;
    if ([message.name isEqualToString:@"shareToWeChat"]) {
        //分享
        NSString *inviteCode = value[@"inviteCode"];
        [ShareView shareViewWithCompleteHandel:^(NSInteger index) {
            if (index < 3) {
                //微信聊天、微信朋友圈、微信收藏
                if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                    WXMediaMessage * message = [WXMediaMessage message];
                    message.title = [NSString stringWithFormat:@"我已经赚了%i元,爽呆!",krandom(5, 10)];
                    message.description = @"最新超火,3千万人都在玩,好东西就要与你分享!";
                    [message setThumbImage:[UIImage imageNamed:@"AppIcon"]];
                    WXWebpageObject * webpageObject = [WXWebpageObject object];
                    webpageObject.webpageUrl = [NSString stringWithFormat:@"http://m.zk27.com/downloadApp.html?code=%@",inviteCode];
                    message.mediaObject = webpageObject;
                    SendMessageToWXReq * req = [[SendMessageToWXReq alloc] init];
                    req.bText = NO;
                    req.message  = message;
                    req.scene =  index == 0 ? WXSceneSession :index == 1 ? WXSceneTimeline:WXSceneFavorite;
                    [WXApi sendReq:req];
                } else {
                    [self alertWithTitle:@"未安装微信!" complete:nil];
                }
            }
        }];
    }
}

// MARK: -memory management
- (void)dealloc {
    [_configure.userContentController removeAllUserScripts];
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
@end
