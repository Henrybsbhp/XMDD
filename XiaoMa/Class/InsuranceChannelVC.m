//
//  InsuranceDirectSellingVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/10.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "InsuranceChannelVC.h"
#import "PolicyInfomationVC.h"
#import "XiaoMa.h"
#import "UIView+Shake.h"
#import "GetInsuranceByChannelOp.h"

@interface InsuranceChannelVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
///渠道号
@property (nonatomic, strong) NSString *channelCode;
///身份证号
@property (nonatomic, strong) NSString *IDNumber;
///车架号（后六位）
@property (nonatomic, strong) NSString *frameNumber;
@end

@implementation InsuranceChannelVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSString * deallocInfo = [NSString stringWithFormat:@"%@ dealloc~~",NSStringFromClass([self class])];
    DebugLog(deallocInfo);
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

    GetInsuranceByChannelOp *op = [GetInsuranceByChannelOp new];
    op.req_channel = [self textInCellAtRow:0];//@"60001";
    op.req_idnumber = [self textInCellAtRow:1];//@"2147483647";
    op.req_licencenumber = [self textInCellAtRow:2];//@"浙AJMDN2"; 
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在查询..."];
    }] subscribeNext:^(GetInsuranceByChannelOp *rstOp) {
        @strongify(self);
        [gToast dismiss];
        PolicyInfomationVC *vc = [UIStoryboard vcWithId:@"PolicyInfomationVC" inStoryboard:@"Insurance"];
        vc.insuranceOp = rstOp;
        [self.navigationController pushViewController:vc animated:YES];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
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
        label.text = @"车牌号码";
        field.placeholder = @"新车请填写车架号后6位";
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

- (NSString *)textInCellAtRow:(NSInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UITextField *field = (UITextField *)[cell.contentView viewWithTag:1002];
    return field.text;
}


@end
