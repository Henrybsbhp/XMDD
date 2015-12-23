//
//  SecondCarValuationVC.m
//  XiaoMa
//
//  Created by RockyYe on 15/12/14.
//  Copyright © 2015年 huika. All rights reserved.
//

#import "SecondCarValuationVC.h"
#import "SecondCarValuationOp.h"
#import "SecondCarValuationUploadOp.h"
#import "CommitSuccessVC.h"
#import <IQKeyboardManager.h>

@interface SecondCarValuationVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
//底部提交按钮
@property (strong, nonatomic) IBOutlet UIButton *commitBtn;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;

//服务器下发数据
@property (strong, nonatomic) NSArray *dataArr;
//上传数据
@property (strong, nonatomic) NSMutableArray *uploadArr;
@property (strong, nonatomic) IBOutlet UIView *bottomView;

//车主姓名
@property (copy, nonatomic) NSString *name;
//车主手机号码
@property (copy, nonatomic) NSString *phoneNumber;
//提价成功后的文案
@property (copy,nonatomic) NSString *tip;
@end

@implementation SecondCarValuationVC

-(void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable=NO;
//    [IQKeyboardManager sharedManager].enableAutoToolbar=NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable=YES;
//    [IQKeyboardManager sharedManager].enableAutoToolbar=YES;
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self reloadCellTwoData];
    
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark KeyBoard

- (void)openKeyboard:(NSNotification *)notification
{
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];

    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
//    CGFloat height = keyboardFrame.size.height;
    self.bottomLayout.constant = keyboardFrame.size.height - 30;
    
    //让输入框架和键盘做完全一样的动画效果
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         [self.view layoutIfNeeded];
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                     } completion:nil];
}

//让输入框回到下边
- (void)closeKeyboard:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey]doubleValue];
    
    UIViewAnimationOptions options = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey]intValue];
    
    self.bottomLayout.constant = 0;
    
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
        [self.view layoutIfNeeded];
        
    } completion:nil];
}


#pragma mark TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1)
    {
        return self.dataArr.count;
    }
    else
    {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        UITableViewCell *cell = [self tableView:tableView ProcessCellForRowAtIndexPath:indexPath];
        return cell;
    }
    else if(indexPath.section == 1)
    {
        UITableViewCell *cell = [self tableView:tableView PlatformCellForRowAtIndexPath:indexPath];
        return cell;
    }
    else
    {
        UITableViewCell *cell = [self tableView:tableView InfoCellForRowAtIndexPath:indexPath];
        return cell;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView ProcessCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProcessCell"];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView PlatformCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlatformCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    UILabel *channelNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *couponMoneyLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *characterLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *userCNTInfoLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    UIButton *checkBtn = (UIButton *)[cell searchViewWithTag:1005];
    checkBtn.userInteractionEnabled = NO;
    couponMoneyLabel.layer.cornerRadius = 3;
    couponMoneyLabel.layer.masksToBounds = YES;
    NSDictionary *dataModel = [self.dataArr safetyObjectAtIndex:indexPath.row];
    channelNameLabel.text=[NSString stringWithFormat:@"平台名称：%@",dataModel[@"channelname"]];
    couponMoneyLabel.text=[NSString stringWithFormat:@" 返现：%@ ",dataModel[@"couponmoney"]];
    characterLabel.text=[NSString stringWithFormat:@"平台特点：%@",dataModel[@"character"]];
    userCNTInfoLabel.text=[NSString stringWithFormat:@"用户数量：%@",dataModel[@"usercntinfo"]];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView InfoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    UITextView *name = (UITextView *)[cell searchViewWithTag:1001];
    UITextView *phoneNumber = (UITextView *)[cell searchViewWithTag:1002];
    phoneNumber.text = self.phoneNumber;
    [name.rac_textSignal subscribeNext:^(id x) {
        self.name = name.text;
    }];
    [phoneNumber.rac_textSignal subscribeNext:^(id x) {
        self.phoneNumber = phoneNumber.text;
    }];
    
    [[RACObserve(gAppMgr.myUser, userID) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
       
        self.phoneNumber = x;
        phoneNumber.text = (NSString *)x;
    }];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *head=[[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
    if (section == 0)
    {
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor whiteColor];
        [head addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        UILabel *label = [UILabel new];
        label.text = @"估值及二手车交易服务由小马达达战略合作伙伴“车300”提供";
        label.textColor = [UIColor grayColor];
        label.numberOfLines = 0;
        label.font = [UIFont systemFontOfSize:13];
        [backgroundView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.right.mas_equalTo(-15);
            make.centerY.mas_equalTo(backgroundView);
        }];
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:0.6];
        [head addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(1);
            make.top.mas_equalTo(backgroundView.mas_bottom);
        }];
    }
    else
    {
        UIView *backgroundView = [UIView new];
        backgroundView.backgroundColor = [UIColor colorWithHex:@"#F5F5F5" alpha:1];
        [head addSubview:backgroundView];
        [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
        UILabel *label = [UILabel new];
        label.text = (section-1)?@"车主信息":@"选择平台";
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:15];
        [backgroundView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(backgroundView.mas_centerY);
            make.left.mas_equalTo(15);
        }];
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:0.6];
        [backgroundView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(backgroundView.mas_top);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(0.5);
        }];
    }
    return head;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 60;
    }
    return 35;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (IOSVersionGreaterThanOrEqualTo(@"7.0"))
    {
        return UITableViewAutomaticDimension;
    }
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
    return ceil(size.height+1);
    
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        NSDictionary *dataModel = [self.dataArr safetyObjectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *btn = (UIButton *)[cell searchViewWithTag:1005];
        if ([self.uploadArr containsObject:dataModel])
        {
            [self.uploadArr safetyRemoveObject:dataModel];
            btn.selected = NO;
        }
        else
        {
            [self.uploadArr safetyAddObject:dataModel];
            btn.selected = YES;
        }
    }
}

#pragma mark Network

//获取服务器数据
-(void)reloadCellTwoData
{
    SecondCarValuationOp *op = [SecondCarValuationOp new];
    op.req_sellerCityId = @(12);
    //    op.req_sellerCityId = self.sellercityid;
    [[[op rac_postRequest] initially:^{
        self.tableView.hidden=YES;
        self.bottomView.hidden=YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(SecondCarValuationOp *op) {
        
        self.dataArr = op.rsp_dataArr;
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        [self.view stopActivityAnimation];
        [self.view showDefaultEmptyViewWithText:@"网络请求失败。点击屏幕重新请求" tapBlock:^{
            [self reloadCellTwoData];
        }];
    } completed:^{
        [self.view stopActivityAnimation];
        self.bottomView.hidden=NO;
        self.tableView.hidden=NO;
    }];
}

#pragma mark Action


- (IBAction)commitDataArr:(id)sender
{
    if (self.uploadArr.count == 0)
    {
        [gToast showError:@"所选平台不能为空"];
    }
    else if ([self.name isEqualToString:@""])
    {
        [gToast showError:@"车主姓名不能为空"];
    }
    else if ([self.phoneNumber isEqualToString:@""])
    {
        [gToast showError:@"车主号码不能为空"];
    }
    else
    {
        SecondCarValuationUploadOp *uploadOp = [SecondCarValuationUploadOp new];
        
        uploadOp.req_carId = self.carid;
        uploadOp.req_contatName = self.name;
        uploadOp.req_contatPhone = self.phoneNumber;
        uploadOp.req_channelEngs = @"";
        uploadOp.req_sellercityid = @(12);//self.sellercityid;
        NSMutableArray *tempString = [NSMutableArray new];
        for (NSDictionary *dic in self.uploadArr)
        {
            [tempString safetyAddObject:dic[@"channeleng"]];
        }

        uploadOp.req_channelEngs = [tempString componentsJoinedByString:@","];
        
        [[[uploadOp rac_postRequest] initially:^{
            
            
        }] subscribeNext:^(SecondCarValuationUploadOp *uploadOp) {
            
            self.tip = uploadOp.rsp_tip;
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }completed:^{
            CommitSuccessVC *successVC = [[UIStoryboard storyboardWithName:@"Valuation" bundle:nil]instantiateViewControllerWithIdentifier:@"CommitSuccessVC"];
            successVC.tip = self.tip;
            [self.navigationController pushViewController:successVC animated:YES];
        }];
    }
}


#pragma mark LazyLoad

-(NSMutableArray *)uploadArr
{
    if (!_uploadArr)
    {
        _uploadArr=[[NSMutableArray alloc]init];
    }
    return _uploadArr;
}

#pragma mark setupUI
- (void)setupUI
{
    [self.commitBtn makeCornerRadius:5.0f];
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
                                                                     } forState:UIControlStateNormal];
}


@end
