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
#import "GetShareButtonOpV2.h"
#import "SocialShareViewController.h"
#import "ShareResponeManager.h"

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

@property (nonatomic, strong) CKList *datasource;

@end

@implementation MutualInsPayResultVC

- (void)dealloc
{
    DebugLog(@"MutualInsPayResultVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
    
    self.contactname = self.contract.insurancedname;
    self.contactphone = gAppMgr.myUser.userID;
    self.area = [[gMapHelper.addrComponent.province append:gMapHelper.addrComponent.city] append:gMapHelper.addrComponent.district];
    
    [self setupDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - SetupUI
- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack)];
    self.navigationItem.leftBarButtonItem = back;
    
    if (self.isFromOrderInfoVC)
    {
        self.navigationItem.title = @"寄送地址";
    }
    else
    {
        self.navigationItem.title = @"支付结果";
    }
}

- (void)setupDatasource
{
    CKDict * topDict = [self topData];
    CKDict * infoDict = [self infoData];
    
    CKDict * sectionHeadDict = [self sectionHeaderData];
    CKDict * nameDict = [self textinputDataForName];
    CKDict * phoneDict = [self textinputDataForPhone];
    CKDict * districtDict = [self textinputDataForDistrict];
    CKDict * detailAddressDict = [self textinputDataForDetailAddress];
    CKDict * tagDict = [self tagData];
    
    if (self.isFromOrderInfoVC)
    {
        self.datasource = $($(infoDict),
                        $(sectionHeadDict,nameDict,phoneDict,districtDict,detailAddressDict,tagDict));
    }
    else
    {
        self.datasource = $($(topDict,infoDict),
                            $(sectionHeadDict,nameDict,phoneDict,districtDict,detailAddressDict,tagDict));
    }
    [self.tableView reloadData];
}

#pragma mark UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
    {
        return CGFLOAT_MIN;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.datasource objectAtIndex:section] count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
            block(data, indexPath);
    }
}

#pragma mark - About Cell
- (CKDict *)topData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"top", kCKCellID:@"topCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 44;
    });
    return data;
}


- (CKDict *)infoData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"info", kCKCellID:@"infoCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 112;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:101];
        UILabel * nameLb = (UILabel *)[cell searchViewWithTag:102];
        UILabel * carLb = (UILabel *)[cell searchViewWithTag:104];
        UILabel * priceLb = (UILabel *)[cell searchViewWithTag:106];
        
        [imageView setImageByUrl:self.contract.xmddlogo
                        withType:ImageURLTypeOrigin defImage:@"mutualins_pay_logo" errorImage:@"mutualins_pay_logo"];
        nameLb.text = self.contract.xmddname;
        carLb.text = self.contract.licencenumber;
        
        
        CGFloat price;
        if (self.totalMoney > 0)
        {
            price = self.totalMoney;
        }
        else
        {
            price = self.contract.total - self.contract.couponmoney - self.couponMoney + self.contract.forcefee + self.contract.taxshipfee;
        }
        priceLb.text =  [NSString stringWithFormat:@"￥%@",[NSString formatForPriceWithFloat:price]];
    });
    return data;
}


- (CKDict *)sectionHeaderData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"top", kCKCellID:@"seactionHeaderCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 40;
    });
    return data;
}

- (CKDict *)textinputDataForName
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"name", kCKCellID:@"inputCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 43;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *title = [cell viewWithTag:101];
        UITextField *textField = [cell viewWithTag:102];
        
        title.text = @"姓名";
        textField.placeholder = @"请输入联系人姓名";
        textField.text = self.contactname;
        self.view1 = textField;
        
        [[[textField rac_textSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * x) {
            
            self.contactname = x;
        }];
    });
    return data;
}

- (CKDict *)textinputDataForPhone
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"phone", kCKCellID:@"inputCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 43;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *title = [cell viewWithTag:101];
        UITextField *textField = [cell viewWithTag:102];
        
        title.text = @"手机";
        textField.placeholder = @"请输入联系人手机";
        textField.text = self.contactphone;
        self.view2 = textField;
        
        [[[textField rac_textSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * x) {
            
            self.contactname = x;
        }];
    });
    return data;
}

- (CKDict *)textinputDataForDistrict
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"phone", kCKCellID:@"districtCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 43;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *title = [cell viewWithTag:101];
        UITextField *textField = [cell viewWithTag:102];
        
        title.text = @"寄送地址";
        textField.text = self.area;
        self.view3 = textField;
        
        [[RACObserve(self, area) takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * x) {
            
            textField.text = x;
        }];
    });
    
    data[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        
        AreaTablePickerVC * vc = [AreaTablePickerVC initPickerAreaVCWithType:PickerVCTypeProvinceAndCityAndDicstrict fromVC:self];
        
        [vc setSelectCompleteAction:^(HKAreaInfoModel * provinceModel, HKAreaInfoModel * cityModel, HKAreaInfoModel * disctrictModel) {
            
            NSString * text = [NSString stringWithFormat:@"%@%@%@",provinceModel.infoName ?: @"",cityModel.infoName ?: @"",disctrictModel.infoName ?: @""];
            self.area = text;
        }];
        [self.navigationController pushViewController:vc animated:YES];
    });
    return data;
}



- (CKDict *)textinputDataForDetailAddress
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"detailAddress", kCKCellID:@"inputCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 43;
    });
    //cell准备重绘
    @weakify(self);
    data[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *title = [cell viewWithTag:101];
        UITextField *textField = [cell viewWithTag:102];
        
        title.text = @"详细地址";
        textField.placeholder = @"请输入详细地址";
        textField.text = self.address;
        self.view4 = textField;
        
        [[[textField rac_textSignal] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(NSString * x) {
            
            self.address = x;
        }];
    });
    return data;
}

- (CKDict *)tagData
{
    CKDict *data = [CKDict dictWith:@{kCKItemKey:@"tag", kCKCellID:@"tagCell"}];
    //cell行高
    data[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 42;
    });
    return data;
}


#pragma mark Action
- (IBAction)commitAction:(id)sender {
    
    [MobClick event:@"xiaomahuzhu" attributes:@{@"zhifu":@"zhifu0017"}];
    
    if (![self.contactname trimmeSpacesInFontAndEnd].length)
    {
        [self.view1 shake];
        return;
    }
    if (![self.contactphone trimmeSpacesInFontAndEnd].length)
    {
         [self.view2 shake];
        return;
    }
    if (![self.area trimmeSpacesInFontAndEnd].length)
    {
         [self.view3 shake];
        return;
    }
    if (![self.address trimmeSpacesInFontAndEnd].length)
    {
        
        if (gAppMgr.deviceInfo.screenSize.height <= 480)
        {
            UIView * sview = self.view4;
            for (NSInteger i = 0 ; i < 10 ; i++)
            {
                sview = sview.superview;
                if ([sview isKindOfClass:[UITableViewCell class]])
                {
                    NSIndexPath * indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sview];
                    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    break;
                }
            }
        }
        
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
        
        [gToast dismiss];
        HKImageAlertVC * av = [[HKImageAlertVC alloc] init];
        av.topTitle = @"提交成功";
        av.imageName = @"mins_ok";
        av.message = @"联系人信息已提交，请等待工作人员为您服务";
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:^(id alertVC) {
            [MobClick event:@"xiaomahuzhu" attributes:@{@"zhifu":@"zhifu0018"}];
            [self actionPop];
        }];
        HKAlertActionItem *share = [HKAlertActionItem itemWithTitle:@"晒单炫耀" color:kOrangeColor clickBlock:^(id alertVC) {
                [MobClick event:@"xiaomahuzhu" attributes:@{@"zhifu":@"zhifu0019"}];
            [self actionShare];
        }];
        av.actionItems = @[cancel,share];
        [av show];
        
    } error:^(NSError *error) {

        [gToast showError:error.domain];
    }];
}


- (void)actionBack
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"zhifu":@"zhifu0016"}];
    
    [self.view endEditing:YES];
    
    HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
    alert.topTitle = @"温馨提示";
    alert.imageName = @"mins_bulb";
    alert.message = @"您未提交联系人信息，为保证协议的正常送达，请先完善信息。是否继续完善信息？";
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"执意退出" color:kGrayTextColor clickBlock:^(id alertVC) {
        
        [self actionPop];
    }];
    HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"继续完善" color:HEXCOLOR(@"#f39c12") clickBlock:nil];
    alert.actionItems = @[cancel, improve];
    [alert show];
}

- (void)actionShare
{
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneShowXmddIns;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"分享信息拉取中..."];
    }] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        [gToast dismiss];
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneShowXmddIns;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
        [[ShareResponeManager init] setFinishAction:^(NSInteger code, ShareResponseType type){
            
            [self actionPop];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}

- (void)actionPop
{
    if (self.router.userInfo[kOriginRoute])
    {
        [self.router.navigationController popToRouter:self.router.userInfo[kOriginRoute] animated:YES];
    }
    else
    {
        CKRouter * route = [self.router.navigationController.routerList objectForKey:@"MutualInsVC"];
        if (route)
        {
            [self.router.navigationController popToRouter:route animated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}


@end
