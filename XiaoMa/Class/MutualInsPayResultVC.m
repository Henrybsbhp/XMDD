//
//  MutualInsPayResultVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsPayResultVC.h"
#import "AreaTablePickerVC.h"
#import "UIView+Shake.h"
#import "UpdateCooperationContractDeliveryinfoOp.h"
#import "MutualInsOrderInfoVC.h"

@interface MutualInsPayResultVC ()<UITableViewDelegate,UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,copy)NSString * contactname;
@property (nonatomic,copy)NSString * contactphone;
@property (nonatomic,copy)NSString * area;
@property (nonatomic,copy)NSString * address;

@property (nonatomic,strong)UIView * view1;
@property (nonatomic,strong)UIView * view2;
@property (nonatomic,strong)UIView * view3;
@property (nonatomic,strong)UIView * view4;

@end

@implementation MutualInsPayResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - SetupUI
- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)setupUI
{
    self.tableView.tableFooterView = [UIView new];
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
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
    
    UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:101];
    UILabel * lb1 = (UILabel *)[cell searchViewWithTag:102];
    UILabel * lb2 = (UILabel *)[cell searchViewWithTag:103];
    
    [imageView setImageByUrl:self.contract.xmddlogo
                    withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    lb1.text = self.contract.licencenumber;
    lb2.text = [NSString formatForPrice:self.contract.total];

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
            textField.placeholder = @"请输入联系人姓名";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.text = self.contactname;
            self.view1 = textField;
            break;
        case 3:
            title.text = @"联系人手机";
            textField.placeholder = @"请输入联系人手机";
            textField.keyboardType = UIKeyboardTypePhonePad;
            textField.text = self.contactphone;
            self.view2 = textField;
            break;
        default:
            title.text = @"协议寄送地址";
            textField.keyboardType = UIKeyboardTypeDefault;
            textField.hidden = YES;
            break;
    }
    
    [[[textField rac_textSignal] takeUntilForCell:cell] subscribeNext:^(NSString * x) {
        
        switch (indexPath.section)
        {
            case 2:
                self.contactname = x;
                break;
            case 3:
                self.contactphone = x;
                break;
        }
    }];
    return cell;
}

-(UITableViewCell *)districtCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"districtCell"];
    UITextField *textField = [cell viewWithTag:101];
    textField.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    textField.layer.borderWidth = 1;
    
    textField.text = self.area;
    self.view3 = textField;
    return cell;
}

-(UITableViewCell *)detailCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"detailCell"];
    UITextView *textView = [cell viewWithTag:100];
    textView.layer.borderColor = [[UIColor colorWithHex:@"#dedfe0" alpha:1]CGColor];
    textView.layer.borderWidth = 1;
    UILabel *placeHolder = [cell viewWithTag:101];
    
    textView.text = self.address;
    self.view4 = textView;
    [[[textView rac_textSignal] takeUntilForCell:cell] subscribeNext:^(NSString *x) {
        if (x.length != 0)
        {
            placeHolder.text = @"";
        }
        else
        {
            placeHolder.text = @"请填写详细地址";
        }
        
        self.address = x;
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
            
            textField.text = [NSString stringWithFormat:@"%@%@%@",provinceModel.infoName ?: @"",cityModel.infoName ?: @"",disctrictModel.infoName ?: @""];
            self.area = textField.text;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark Action
- (IBAction)commitAction:(id)sender {
    
    if (!self.contactname.length)
    {
        [self.view1 shake];
        return;
    }
    if (!self.contactphone.length)
    {
         [self.view2 shake];
        return;
    }
    if (!self.area.length)
    {
         [self.view3 shake];
        return;
    }
    if (!self.address.length)
    {
         [self.view4 shake];
        return;
    }
    
    [self requestUpdateDeliveryInfo];
}

- (void)requestUpdateDeliveryInfo
{
    NSString * areaAddress = [NSString stringWithFormat:@"%@ %@",self.area,self.address];
    UpdateCooperationContractDeliveryinfoOp * op = [UpdateCooperationContractDeliveryinfoOp operation];
    op.req_contractid = self.contract.contractid;
    op.req_contactname = self.contactname;
    op.req_contactphone = self.contactphone;
    op.req_address = areaAddress;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"信息上传中..."];
    }] subscribeNext:^(id x) {
        
        [gToast showSuccess:@"联系人信息已提交，请等待车险专员为您服务"];
        for (UIViewController * vc in self.navigationController.viewControllers)
        {
            if ([vc isKindOfClass:[MutualInsOrderInfoVC class]])
            {
                [((MutualInsOrderInfoVC *)vc) requestContractDetail];
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}


- (void)actionBack
{
    UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您未提交联系人信息，为保证协议的正常送达，请先完善信息。是否继续完善信息？" delegate:nil cancelButtonTitle:@"执意退出" otherButtonTitles:@"继续完善", nil];
    [[av rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
        
        if (![number integerValue])
        {
            for (UIViewController * vc in self.navigationController.viewControllers)
            {
                if ([vc isKindOfClass:[MutualInsOrderInfoVC class]])
                {
                    [((MutualInsOrderInfoVC *)vc) requestContractDetail];
                    [self.navigationController popToViewController:vc animated:YES];
                    return;
                }
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
    
    [av show];
}

@end
