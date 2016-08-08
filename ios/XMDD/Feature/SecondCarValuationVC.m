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
#import "IQKeyboardManager.h"
#import "OETextField.h"
@interface SecondCarValuationVC ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

//服务器下发数据
@property (strong, nonatomic) NSArray *dataArr;
//上传数据
@property (strong, nonatomic) NSMutableArray *uploadArr;

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
    DebugLog(@"SecondCarValuationVC dealloc~~~");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable=NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(closeKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable=YES;
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self reloadData];
    
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
    self.bottomLayout.constant = keyboardFrame.size.height;
//    self.topLayout.constant =  - (keyboardFrame.size.height);
    
    //让输入框架和键盘做完全一样的动画效果
    [UIView animateWithDuration:duration
                          delay:0
                        options:options
                     animations:^{
                         [self.view layoutIfNeeded];
                         [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
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
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 2)
    {
        return (1 + self.dataArr.count);
    }
    else
    {
        return 1;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0)
    {
        cell = [self noticeCellForRowAtIndexPath:indexPath];
    }
    else if(indexPath.section == 1)
    {
        cell = [self processCellForRowAtIndexPath:indexPath];
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"HeadCell"];
            UILabel *headerLabel = [cell viewWithTag:100];
            headerLabel.numberOfLines = 0;
            headerLabel.text = @"选择平台";
        }
        else
        {
            cell = [self tableView:tableView PlatformCellForRowAtIndexPath:indexPath];
        }
    }
    else
    {
            cell = [self tableView:tableView InfoCellForRowAtIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(UITableViewCell *)noticeCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoticeCell"];
    UILabel *tip = [cell viewWithTag:100];
    tip.text = self.tip;
    [cell layoutIfNeeded];
    return cell;
}

-(UITableViewCell *)processCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ProcessCell"];
    [self addCorner:[cell viewWithTag:100]];
    [self addCorner:[cell viewWithTag:101]];
    [self addCorner:[cell viewWithTag:102]];
    [self addCorner:[cell viewWithTag:103]];
    
    [self setPreferredMaxLayoutWidth:[cell viewWithTag:104]];
    [self setPreferredMaxLayoutWidth:[cell viewWithTag:105]];
    [self setPreferredMaxLayoutWidth:[cell viewWithTag:106]];
    [self setPreferredMaxLayoutWidth:[cell viewWithTag:107]];
    
    [cell layoutIfNeeded];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView PlatformCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlatformCell"];
    UILabel *channelNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UILabel *couponMoneyLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *characterLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    characterLabel.numberOfLines = 0;
    UILabel *userCNTInfoLabel = (UILabel *)[cell.contentView viewWithTag:1004];
    
    UIButton *checkBtn = (UIButton *)[cell searchViewWithTag:1005];
    checkBtn.userInteractionEnabled = NO;
    couponMoneyLabel.layer.cornerRadius = 3;
    couponMoneyLabel.layer.masksToBounds = YES;
    NSDictionary *dataModel = [self.dataArr safetyObjectAtIndex:(indexPath.row - 1)];
    channelNameLabel.text=[NSString stringWithFormat:@"%@",dataModel[@"channelname"]];
    couponMoneyLabel.text=[NSString stringWithFormat:@" %@ ",dataModel[@"couponmoney"]];
    characterLabel.text=[NSString stringWithFormat:@"平台特点：%@",dataModel[@"character"]];
    userCNTInfoLabel.text=[NSString stringWithFormat:@"用户数量：%@",dataModel[@"usercntinfo"]];
    characterLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 100;
    userCNTInfoLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 100;
    
    [cell layoutIfNeeded];
    return cell;
}

-(UITableViewCell *)tableView:(UITableView *)tableView InfoCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
    UITextView *name = (UITextView *)[cell searchViewWithTag:1001];
    UITextView *phoneNumber = (UITextView *)[cell searchViewWithTag:1002];
    phoneNumber.text = self.phoneNumber;
    @weakify(self);
    [[name.rac_textSignal takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        @strongify(self);
        self.name = name.text;
    }];
    [[phoneNumber.rac_textSignal takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        if (phoneNumber.text.length > 11) {
            phoneNumber.text = [phoneNumber.text substringToIndex:11];
        }
        self.phoneNumber = phoneNumber.text;
    }];
    
    [[RACObserve(gAppMgr.myUser, userID) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        
        @strongify(self);
        self.phoneNumber = x;
        phoneNumber.text = (NSString *)x;
    }];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0)
    {
        return 42;
    }
    else if(indexPath.section == 3)
    {
        return 140;
    }
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        NSDictionary *dataModel = [self.dataArr safetyObjectAtIndex:(indexPath.row - 1)];
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
-(void)reloadData
{
    @weakify(self)
    SecondCarValuationOp *op = [SecondCarValuationOp new];
    op.req_sellerCityId = self.sellercityid;
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.tableView.hidden=YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(SecondCarValuationOp *op) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        self.tableView.hidden=NO;
        self.dataArr = op.rsp_dataArr;
        self.tip = op.rsp_tip;
        [self.tableView reloadData];
        
    } error:^(NSError *error) {
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"网络请求失败。点击屏幕重新请求" tapBlock:^{
            @strongify(self);
            [self reloadData];
        }];
    }];
}

#pragma mark Action

- (IBAction)helpBtnClick:(id)sender
{
    /**
     *  使用帮助事件
     */
    [MobClick event:@"rp604-1"];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.url=@"http://www.xiaomadada.com/apphtml/second-hand-car-help.html";
    [self.navigationController pushViewController:vc animated:YES];
    
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
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                                     NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:14.0]
                                                                     } forState:UIControlStateNormal];
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 44;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
}

-(void)addCorner:(UILabel *)label
{
    label.layer.cornerRadius = 10;
    label.layer.masksToBounds = YES;
}

-(void)setPreferredMaxLayoutWidth:(UILabel *)label
{
    label.preferredMaxLayoutWidth = self.view.bounds.size.width - 80;
    label.numberOfLines = 0;
}
- (IBAction)commitAction:(id)sender
{
    /**
     *  提交卖车意向事件
     */
    [MobClick event:@"rp604_2"];
    if (self.uploadArr.count == 0)
    {
        [gToast showError:@"所选平台不能为空"];
    }
    else if ([self.name isEqualToString:@""])
    {
        [gToast showError:@"车主称呼不能为空"];
    }
    else if (self.phoneNumber.length != 11)
    {
        [gToast showError:@"请输入正确的联系方式"];
    }
    else
    {
        SecondCarValuationUploadOp *uploadOp = [SecondCarValuationUploadOp new];
        
        uploadOp.req_carId = self.carid;
        uploadOp.req_contatName = self.name;
        uploadOp.req_contatPhone = self.phoneNumber;
        uploadOp.req_channelEngs = @"";
        uploadOp.req_sellercityid = self.sellercityid;//self.sellercityid;
        NSMutableArray *tempString = [NSMutableArray new];
        for (NSDictionary *dic in self.uploadArr)
        {
            [tempString safetyAddObject:dic[@"channeleng"]];
        }
        
        uploadOp.req_channelEngs = [tempString componentsJoinedByString:@","];
        
        @weakify(self);
        [[[uploadOp rac_postRequest] initially:^{
            
            
        }] subscribeNext:^(SecondCarValuationUploadOp *uploadOp) {
            
            @strongify(self);
            CommitSuccessVC * successVC = [valuationStoryboard instantiateViewControllerWithIdentifier:@"CommitSuccessVC"];
            [self.navigationController pushViewController:successVC animated:YES];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }
}

@end
