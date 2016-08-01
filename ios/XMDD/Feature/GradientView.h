//
//  GradientView.h
//  XiaoMa
//
//  Created by RockyYe on 16/7/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientView : UIView

@property (strong, nonatomic) NSString *percent;
@property (strong, nonatomic) NSString *totalpoolamt;
@property (strong, nonatomic) NSString *presentpoolamt;

- (void)setPercent:(NSString *)percent animate:(BOOL)animate;

@end
