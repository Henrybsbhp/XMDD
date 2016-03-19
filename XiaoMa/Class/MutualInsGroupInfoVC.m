//
//  MutualInsGroupInfoVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsGroupInfoVC.h"

@interface MutualInsGroupInfoVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MutualInsGroupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 2;
        
    } else if (section == 1) {
        
        return 1;
        
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    } else if (section == 1) {
        return CGFLOAT_MIN;
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            return 81;
            
        } else if (indexPath.row == 1) {
            
            return 99;
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            return 192;
        }
        
    }
    
    return 81;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadBannerCellAtIndexPath:indexPath];
            
        } else if (indexPath.row == 1) {
            
            cell = [self loadInfoCellAtIndexPath:indexPath];
            
        }
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell" forIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)loadInfoCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"InfoCell" forIndexPath:indexPath];
    
    return cell;
}

@end
