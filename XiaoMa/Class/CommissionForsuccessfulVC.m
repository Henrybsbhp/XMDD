//
//  CommissionForsuccessfulVC.m
//  XiaoMa
//
//  Created by baiyulin on 15/12/17.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "CommissionForsuccessfulVC.h"

@interface CommissionForsuccessfulVC ()

@end

@implementation CommissionForsuccessfulVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC1" forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 1){
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC2" forIndexPath:indexPath];
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommissionForsuccessfulVC3" forIndexPath:indexPath];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 135;
    }else if (indexPath.row == 1){
        return 170;
    }else {
        return 58;
    }
}

@end
