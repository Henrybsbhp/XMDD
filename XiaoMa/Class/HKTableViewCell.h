//
//  HKTableViewCell.h
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/15.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKLine.h"

@interface HKTableViewCell : UITableViewCell

- (CKLine *)addOrUpdateBorderLineWithAlignment:(CKLineAlignment)alignment insets:(UIEdgeInsets)insets;
- (void)removeBorderLineWithAlignment:(CKLineAlignment)alignment;
- (void)removeAllBorderLines;

@end
