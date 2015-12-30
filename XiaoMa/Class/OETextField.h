//
//  OETextField.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OETextField : UITextField


/**
 *  初始化普通的InputAccessoryView
 *
 *  @param dataArr InputAccessoryView显示的内容
 */
-(void)setNormalInputAccessoryViewWithDataArr:(NSArray *)dataArr;


/**
 *  初始化带滚动的InputAccessoryView
 *
 *  @param size 滚动范围
 */
-(void)setScrollInputAccessoryViewWithContentSize:(CGSize)size DataArr:(NSArray *)dataArr;

@end
