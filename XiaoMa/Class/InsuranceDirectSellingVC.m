//
//  InsuranceDirectSellingVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceDirectSellingVC.h"
#import "PolicyInfomationVC.h"
#import "XiaoMa.h"
#import "UIView+Shake.h"

@interface InsuranceDirectSellingVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
///渠道号
@property (nonatomic, strong) NSString *channelCode;
///身份证号
@property (nonatomic, strong) NSString *IDNumber;
///车架号（后六位）
@property (nonatomic, strong) NSString *frameNumber;
@end

@implementation InsuranceDirectSellingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    if ([self shakeIfNeededAtRow:0]) {
        return;
    }
    if ([self shakeIfNeededAtRow:1]) {
        return;
    }
    if ([self shakeIfNeededAtRow:2]) {
        return;
    }
    PolicyInfomationVC *vc = [UIStoryboard vcWithId:@"PolicyInfomationVC" inStoryboard:@"Insurance"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InputCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    @weakify(self);
    if (indexPath.row == 0) {
        label.text = @"渠道优惠码";
        field.placeholder = @"请填写渠道优惠码";
        field.text = self.channelCode;
        [[field rac_newTextChannel] subscribeNext:^(id x) {
            @strongify(self);
            self.channelCode = x;
        }];
    }
    else if (indexPath.row == 1) {
        label.text = @"身份证号码";
        field.placeholder = @"请填写身份证号码";
        field.text = self.IDNumber;
        [[field rac_newTextChannel] subscribeNext:^(id x) {
            @strongify(self);
            self.IDNumber = x;
        }];
    }
    else if (indexPath.row == 2) {
        label.text = @"车架号";
        field.placeholder = @"请填写车架号后六位";
        field.text = self.frameNumber;
        [[field rac_newTextChannel] subscribeNext:^(id x) {
            @strongify(self);
            self.frameNumber = x;
        }];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTTableViewCell *jtcell = (JTTableViewCell *)cell;
    jtcell.customSeparatorInset = UIEdgeInsetsMake(-1, 0, 0, 0);
    [jtcell prepareCellForTableView:tableView atIndexPath:indexPath];
}

#pragma mark - Private
- (BOOL)shakeIfNeededAtRow:(NSInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    if (field.text.length == 0) {
        [field shake];
        return YES;
    }
    return NO;
}


@end
