//
//  UIView+CustomForXIB.h
//  EasyPay
//
//  Created by jiangjunchen on 14/10/31.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

///根据AccessibilityHint属性，自定义样式
///样式1(layer.borderColor):      #BC_RGBA(100,100,100,1.0)  或 #BC_RGB(100,100,100) 或 #BC_whiteColor
///样式2(layer.borderWidth):      #BW_2.2
///样式3(layer.cornerRadius):     #CR_3.4
///样式4(imageView.image capInsets):                  #CI_20,30,0,40
///样式5(button.backgroundImage capInsets):           #BCI_20,30,0,40
///样式6(imageView.image highlightCapInsets):         #HCI_20,30,41,3
///样式7(button.backgroundImage highlightCapInsets):  #HBCI_20,30,41,3
@interface UIView (CustomXIB)
@property (nonatomic, strong) NSString *keyPath;

+ (void)patchForCustomXIB;

@end
