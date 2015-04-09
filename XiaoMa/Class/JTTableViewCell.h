//
//  JTTableViewCell.h
//  LiverApp
//
//  Created by jiangjunchen on 15/2/8.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JTTableViewCell : UITableViewCell
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, weak) UITableView *targetTableView;
@property (nonatomic, assign) UIEdgeInsets customSeparatorInset UI_APPEARANCE_SELECTOR;

- (void)prepareCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath;

@end

