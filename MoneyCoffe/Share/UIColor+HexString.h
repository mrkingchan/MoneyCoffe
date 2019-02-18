//
//  UIColor+HexString.h
//  KuaiKuaiZhaoPin
//
//  Created by Chan on 2018/12/6.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ColorRGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define Color235 ColorRGB(235, 235, 235, 1)

@interface UIColor (HexString)

#ifndef UIColorHex
#define UIColorHex(_hex_) [UIColor colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#endif

+ (instancetype)colorWithHexString:(NSString *)hexStr ;

@end
