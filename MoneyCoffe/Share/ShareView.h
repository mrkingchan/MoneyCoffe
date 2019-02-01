//
//  ShareView.h
//  YQ
//
//  Created by Macx on 2018/7/9.
//  Copyright © 2018年 annkey. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^completeHandel)(NSInteger index);

@interface ShareView : UIView

@property(nonatomic,copy) completeHandel complete;


/**
 默认微信三个+ 微博

 @param complete 点击回调
 @return
 */
+ (instancetype)shareViewWithCompleteHandel:(completeHandel)complete;

@end
