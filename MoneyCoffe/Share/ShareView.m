//
//  ShareView.m
//  YQ
//
//  Created by Chan on 2018/7/9.
//  Copyright © 2018年 annkey. All rights reserved.
//

#import "ShareView.h"
#import "UIView+Rect.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ShareView () {
    UIView *_containerView;
    UIButton *_cancel;
}
@end

@implementation ShareView

+ (instancetype)shareViewWithCompleteHandel:(completeHandel)complete {
    return [[ShareView alloc] initWithCompleteHandel:complete];
}

// MARK: - initialized Method
- (instancetype)initWithCompleteHandel:(completeHandel)complete {
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        _complete = complete;
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.frame = CGRectMake(10, kScreenHeight, kScreenWidth - 20, 190);
        _containerView.clipsToBounds = YES;
        _containerView.layer.cornerRadius = 8.0;
        [self addSubview:_containerView];
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        [self setUI];
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    return self;
}

// MARK: - setUI
- (void)setUI {
    CGFloat gapW = (kScreenWidth -  150 - 20)/4;
    _containerView.userInteractionEnabled = YES;
    NSArray *titles = @[@"微信朋友",@"微信朋友圈",@"微信收藏"];
    UIImageView *imageViews[3];
    UILabel *titleLabels[3];
    UILabel *tip = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth - 20, 30)];
    tip.textColor = [UIColor blackColor];
    tip.font = [UIFont systemFontOfSize:13];
    tip.textAlignment = 1;
    tip.text = @"分享至";
    [_containerView addSubview:tip];
    for (int i = 0 ;i < 3; i ++) {
        imageViews[i] = [[UIImageView alloc] initWithFrame:CGRectMake(i == 0 ? gapW : imageViews[i - 1].right + gapW, tip.bottom +  10, 55, 55)];
        imageViews[i].image = [UIImage imageNamed:[NSString stringWithFormat:@"share_%i",i + 1]];
        imageViews[i].tag = 1000 + i;
        imageViews[i].userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
        [imageViews[i] addGestureRecognizer:tap];
        [_containerView addSubview:imageViews[i]];
        
        titleLabels[i] = [[UILabel alloc] initWithFrame:CGRectMake(imageViews[i].left - 12.5, imageViews[i].bottom + 8, 80, 20)];
        titleLabels[i].textAlignment = 1;
        titleLabels[i].font = [UIFont systemFontOfSize:12];
        titleLabels[i].textColor = [UIColor blackColor];
        titleLabels[i].text = titles[i];
        [_containerView addSubview:titleLabels[i]];
        if ( i ==  2) {
            UILabel *titleLabel = titleLabels[0];
            //分割线
            UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 8, kScreenWidth, 1)];
            separatorView.backgroundColor = [UIColor lightGrayColor];
            [_containerView addSubview:separatorView];
            
            //取消
            _cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, titleLabel.bottom + 15, kScreenWidth - 20, 30)];
            [_cancel setTitle:@"取消" forState:UIControlStateNormal];
            [_cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _cancel.titleLabel.textAlignment = 1;
            _cancel.titleLabel.font = [UIFont systemFontOfSize:15];
            [_containerView addSubview:_cancel];
            [_cancel addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    [UIView animateWithDuration:0.2 animations:^{
        _containerView.top = kScreenHeight - 180 -20;
    }];
}

// MARK: - touch Method
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (!CGRectContainsPoint(_containerView.frame, location)) {
        [self hide];
    }
}

// MARK: - private Method
- (void)buttonAction:(UITapGestureRecognizer *)tap  {
    UIImageView *imageView = (UIImageView *) tap.view;
    NSInteger index = imageView.tag - 1000;
    if (_complete) {
        _complete(index);
    }
    [self hide];
}

// MARK: - hide
- (void)hide {
    [UIView animateWithDuration:0.3 animations:^{
        _containerView.top = kScreenHeight;
    }];
    [self removeFromSuperview];
}

// MARK: - memory management
- (void)dealloc {
    if (_containerView) {
        _containerView = nil;
    }
    if (_complete) {
        _complete = nil;
    }
}
@end

