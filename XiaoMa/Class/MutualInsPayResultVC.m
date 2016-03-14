//
//  MutualInsPayResultVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPayResultVC.h"
#import "AreaTablePickerVC.h"

@interface MutualInsPayResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MutualInsPayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [self resultCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 1)
    {
        cell = [self infoCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 4)
    {
        cell = [self inputCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 5)
    {
        cell = [self districtCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 6)
    {
        cell = [self detailCellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *)resultCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.tableView dequeueReusableCellWithIdentifier:@"resultCell"];
}

-(UITableViewCell *)infoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"infoCell"];
    UIView *backgoundView = [cell viewWithTag:100];
    backgoundView.layer.borderWidth = 1;
    backgoundView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    return cell;
}

-(UITableViewCell *)inputCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"inputCell"];
    UILabel *title = [cell viewWithTag:100];
    UITextField *textField = [cell viewWithTag:101];
    textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    textField.layer.borderWidth = 1;
    switch (indexPath.section)
    {
        case 2:
            title.text = @"联系人姓名";
            break;
        case 3:
            title.text = @"联系人手机";
            break;
        default:
            title.text = @"协议寄送地址";
            textField.hidden = YES;
            break;
    }
    return cell;
}

-(UITableViewCell *)districtCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"districtCell"];
    UITextField *textField = [cell viewWithTag:101];
    textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    textField.layer.borderWidth = 1;
    return cell;
}

-(UITableViewCell *)detailCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    UITextView *textView = [cell viewWithTag:100];
    textView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    textView.layer.borderWidth = 1;
    UILabel *placeHolder = [cell viewWithTag:101];
    [[textView rac_textSignal]subscribeNext:^(NSString *x) {
        if (x.length != 0)
        {
            placeHolder.text = @"";
        }
        else
        {
            placeHolder.text = @"请填写详细地址";
        }
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 48;
    }
    else if (indexPath.section == 1)
    {
        return 140;
    }
    else if (indexPath.section == 2 || indexPath.section == 3 || indexPath.section == 5)
    {
        return 53;
    }
    else if(indexPath.section == 6)
    {
        return 81;
    }
    return 30;
}

#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 5)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = [cell viewWithTag:101];
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCity fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            
            textField.text = [NSString stringWithFormat:@"%@%@%@",provinceModel.infoName,cityModel.infoName,disctrictModel.infoName];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Action
- (IBAction)commitAction:(id)sender {
    
}


#pragma mark Init
-(void)setupUI
{
    self.tableView.tableFooterView = [UIView new];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
}

@end
