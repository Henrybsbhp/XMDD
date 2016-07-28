//
//  OETextField.h
//  XiaoMa
//
//  Created by RockyYe on 15/12/29.
//  Copyright © 2015年 huika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLimitTextField.h"
#import "OEButton.h"

#define OEHeight 60
#define OEHeight 100
#define OEAccessTag 4444

/// OEView
@interface OEView : HKView
@end

/// 可以在顶部增加数字的textfeild
@interface OETextField : CKLimitTextField

@property (nonatomic,strong)UIView * customAccessoryView;

/**
 *  初始化普通的InputAccessoryView
 *
 *  @param dataArr InputAccessoryView显示的内容
 */
-(void)setNormalInputAccessoryViewWithDataArr:(NSArray *)dataArr;

@end
