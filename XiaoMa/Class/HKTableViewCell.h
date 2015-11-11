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
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, weak) UITableView *targetTableView;
@property (nonatomic, assign) UIEdgeInsets customSeparatorInset UI_APPEARANCE_SELECTOR;

- (CKLine *)addOrUpdateBorderLineWithAlignment:(CKLineAlignment)alignment insets:(UIEdgeInsets)insets;
- (void)removeBorderLineWithAlignment:(CKLineAlignment)alignment;
- (void)removeAllBorderLines;
- (void)prepareCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end
