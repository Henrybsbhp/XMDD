//
//  MutualInsAcceptCompensationVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 6/2/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsAcceptCompensationVC.h"

@interface MutualInsAcceptCompensationVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsAcceptCompensationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [self loadUsernameCellAtIndexPath:indexPath];
    } else {
        cell = [self loadBankCardCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)loadUsernameCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
    
    UITextField *usernameTextField = (UITextField *)[cell.contentView viewWithTag:100];
    
    return cell;
}

- (UITableViewCell *)loadBankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"BankCardCell"];
    
    UITextField *bankCardTextField = (UITextField *)[cell.contentView viewWithTag:100];
    
    return cell;
}

@end
