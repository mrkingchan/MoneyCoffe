//
//  UIViewController+Alert.m
//  KuaiKuaiZhaoPin
//
//  Created by Chan on 2018/8/16.
//  Copyright © 2018年 Chan. All rights reserved.
//

#import "UIViewController+Alert.h"

@implementation UIViewController (Alert)

- (void)alertWithTitle:(NSString *)titleStr message:(NSString *)message complete:(void( ^)())complete  API_AVAILABLE(ios(8.0)) {
    NSCParameterAssert(titleStr!=nil);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleStr message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定"
                                                     style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                         if (complete) {
                                                             complete();
                                                         }
                                                     }];
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)alertWithTitle:(NSString *)titleStr complete:(void(^)())complete  {
    [self alertWithTitle:titleStr message:@"" complete:complete];
}


- (void)alertWithTitle:(NSString *)titleStr
               button1:(NSString *)title1
        completeBlock1:(void (^)())complete1
               button2:(NSString *)title2
        completeBlock2:(void (^)())complete2 {
    [self alertWithTitle:titleStr
              messageStr:nil
                 button1:title1
          completeBlock1:complete1
                 button2:title2
          completeBlock2:complete2];
}

- (void)alertWithTitle:(NSString *)titleStr
            messageStr:(NSString *)message
               button1:(NSString *)title1
        completeBlock1:(void (^)())complete1
               button2:(NSString *)title2
        completeBlock2:(void (^)())complete2 {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:titleStr
                                                                             message:message preferredStyle:UIAlertControllerStyleAlert];
    for (int i = 0 ; i < 2; i ++) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:i ==0 ? title1:title2 style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           if ([action.title rangeOfString:title1].location != NSNotFound) {
                                                               if (complete1) {
                                                                   complete1();
                                                               }
                                                           } else if ([action.title rangeOfString:title2].location != NSNotFound)  {
                                                               if (complete2) {
                                                                   complete2();
                                                               }
                                                           }
                                                       }];
        //add Action
        [alertController addAction:action];
    }
    // present the alertController
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
