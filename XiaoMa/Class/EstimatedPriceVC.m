//
//  EstimatedPriceVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "EstimatedPriceVC.h"
#import "CKDatasource.h"
#import "HKMutualInsList.h"
#import "PopAnimation.h"
#import "NSString+RectSize.h"
#import "UIView+RoundedCorner.h"
#import "GetMutualInsListOp.h"
#import "UpdateCooperationInsInfoOp.h"
#import "MutualInsStore.h"
#import "MutualInsGrouponVC.h"
#import "MutualInsHomeVC.h"
#import "PopAnimation.h"

@interface EstimatedPriceVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *datasource;

@property (nonatomic, assign) CGFloat lastOriginPrice;

@property (strong, nonatomic) HKImageAlertVC *alert;

//是否代理购买交强险
@property (nonatomic, assign) BOOL isAgent;

- (IBAction)submitAction:(id)sender;

@end


@implementation EstimatedPriceVC

- (void)dealloc
{
    DebugLog(@"EstimatedPriceVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestData];
}

- (void)requestData
{
    GetMutualInsListOp *op = [GetMutualInsListOp operation];
    op.req_version = gAppMgr.deviceInfo.appVersion;
    op.req_memberId = self.memberId;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        //加载动画
        self.view.indicatorPoistionY = floor((self.view.frame.size.height - 75)/2.0);
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
    }] subscribeNext:^(GetMutualInsListOp *rop) {
        
        @strongify(self);
        self.tableView.hidden = NO;
        [self.view stopActivityAnimation];
        [self setDataSource:rop.rsp_insModel];
        
    } error:^(NSError *error) {
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [self.view hideDefaultEmptyView];
            [self requestData];
        }];
    }];
}

- (void)setDataSource:(HKMutualInsList *)dataModel
{
    self.datasource = [CKList list];
    
    //小提示
    if (dataModel.remindTip.length != 0) {
        CKDict *topTip = [self setTopCell:dataModel.remindTip];
        [self.datasource addObject:$(topTip) forKey:@"topSection"];
    }
    
    //预估费用
    CKDict *estPrice = [self setPirceCell:dataModel];
    //预估备注
    CKDict *note = [self setNoteCell:dataModel.noteList];
    //服务标题
    CKDict *serviceTitle = [self setServiceTitleCell];
    //所享服务
    CKDict *service = [self setServiceCell:dataModel.couponList];
    //是否代买
    CKDict *agentIns = [self setAgentCell];
    [self.datasource addObject:$(estPrice, note, serviceTitle, service, agentIns) forKey:@"contentSection"];
    
    [self.tableView reloadData];
}

- (CKDict *)setTopCell:(NSString *)tip {
    //初始化身份标识
    CKDict * topTip = [CKDict dictWith:@{kCKItemKey:@"topTip", kCKCellID:@"HeaderTipCell"}];
    //cell行高
    CGFloat height = [tip labelSizeWithWidth:(self.tableView.frame.size.width - 50) font:[UIFont systemFontOfSize:13]].height;
    topTip[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return height + 25;
    });
    //cell准备重绘
    topTip[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel * tipL = [cell.contentView viewWithTag:1001];
        tipL.text = tip;
    });
    return topTip;
}

- (CKDict *)setPirceCell:(HKMutualInsList *)dataModel
{
    //初始化身份标识
    CKDict * estPrice = [CKDict dictWith:@{kCKCellID:@"EstimateContentCell"}];
    //cell行高
    estPrice[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 160;
    });
    //cell准备重绘
    estPrice[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        UILabel *totalPriceL = [cell.contentView viewWithTag:1001];
        UIView *membershipView = [cell.contentView viewWithTag:1002];
        UIView *mutualInsView = [cell.contentView viewWithTag:1003];
        UILabel *membershipPriceL = [cell.contentView viewWithTag:1004];
        UILabel *mutualInsPriceL = [cell.contentView viewWithTag:1005];
        UILabel *saveMoneyL = [cell.contentView viewWithTag:1006];
        
        [membershipView setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#F5F5F6")];
        [mutualInsView setCornerRadius:3 withBackgroundColor:HEXCOLOR(@"#F5F5F6")];
        
        
        //价格器动画
        [PopAnimation animatedForLabel:totalPriceL fromValue:0 toValue:dataModel.premiumprice andDuration:2];
        membershipPriceL.text = [NSString stringWithFormat:@"%@元", [NSString formatForPrice:dataModel.memberFee]];
        mutualInsPriceL.text = [NSString stringWithFormat:@"%@元", [NSString formatForPrice:(dataModel.premiumprice - dataModel.memberFee)]];
        [mutualInsPriceL setAdjustsFontSizeToFitWidth:YES];
        
        NSString * tipStr = [NSString stringWithFormat:@"比传统车险省%@元", [NSString formatForPrice:dataModel.couponMoney]];
        NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
        [attributeStr addAttributeForegroundColor:kOrangeColor range:NSMakeRange(6, tipStr.length - 6)];
        saveMoneyL.attributedText = attributeStr;
        
    });
    return estPrice;
}

- (id)setNoteCell:(NSArray *)noteList
{
    if (noteList.count == 0) {
        return CKNULL;
    }
    //初始化身份标识
    CKDict * note = [CKDict dictWith:@{kCKCellID:@"NoteCell"}];
    //cell行高
    note[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 10 + 22 * noteList.count;
    });
    //cell准备重绘
    note[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIView *refundView = [cell.contentView viewWithTag:1001];
        [refundView setCornerRadius:3 withBorderColor:kDefTintColor borderWidth:0.5];
        
        for (int i = 0; i < noteList.count; i ++ ) {
            UILabel *refundNoteL = [[UILabel alloc] init];
            refundNoteL.textColor = kDefTintColor;
            refundNoteL.font = [UIFont systemFontOfSize:12];
            refundNoteL.textAlignment = NSTextAlignmentCenter;
            refundNoteL.text = [noteList safetyObjectAtIndex:i];
            [cell.contentView addSubview:refundNoteL];
            
            [refundNoteL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(refundView).offset(5 + 22 * i);
                make.left.equalTo(refundView).offset(5);
                make.right.equalTo(refundView).offset(-5);
                make.height.mas_equalTo(22);
            }];
        }
    });
    return note;
}

- (CKDict *)setServiceTitleCell
{
    //初始化身份标识
    CKDict * title = [CKDict dictWith:@{kCKCellID:@"ServiceTitleCell"}];
    //cell行高
    title[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 36;
    });
    return title;
}

- (CKDict *)setServiceCell:(NSArray *)couponList
{
    //初始化身份标识
    CKDict * service = [CKDict dictWith:@{kCKCellID:@"ServiceCell"}];
    //cell行高
    service[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        if (couponList.count % 2 == 0) {
            return 37 * couponList.count / 2 + 3;
        }
        return 37 * (couponList.count / 2 + 1) + 3;
        
    });
    //cell准备重绘
    service[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        for (int i = 0; i < couponList.count; i ++ ) {
            UILabel *couponL = [[UILabel alloc] init];
            couponL.textColor = kDarkTextColor;
            couponL.font = [UIFont systemFontOfSize:13];
            couponL.textAlignment = NSTextAlignmentCenter;
            couponL.text = [couponList safetyObjectAtIndex:i];
            [couponL setCornerRadius:13 withBorderColor:kLightTextColor borderWidth:0.5];
            [cell.contentView addSubview:couponL];
            
            [couponL mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.contentView).offset(3 + 37 * (i / 2));
                if (i % 2 == 0) {
                    make.left.equalTo(cell.contentView).offset(15);
                    make.centerX.equalTo(cell.contentView).multipliedBy(0.5).offset(3);
                }
                else {
                    make.right.equalTo(cell.contentView).offset(-15);
                    make.centerX.equalTo(cell.contentView).multipliedBy(1.5).offset(-3);
                }
                
                make.height.mas_equalTo(27);
            }];
        }

    });
    return service;
}

- (CKDict *)setAgentCell
{
    //初始化身份标识
    CKDict * agentIns = [CKDict dictWith:@{kCKCellID:@"InsAgentCell"}];
    //cell行高
    agentIns[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 56;
    });
    //cell准备重绘
    @weakify(self);
    agentIns[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * nameL = [cell.contentView viewWithTag:1002];
        
        nameL.text = @"代买车船税/交强险";
        nameL.textColor = self.isAgent ? kDarkTextColor : kLightTextColor;
        
        [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            self.isAgent = !self.isAgent;
            selectBtn.selected = !selectBtn.selected;
            nameL.textColor = selectBtn.selected ? kDarkTextColor : kLightTextColor;
        }];
    });
    agentIns[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe" : @"shenhe0009"}];
        @strongify(self);
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * nameL = [cell.contentView viewWithTag:1002];
        
        self.isAgent = !self.isAgent;
        selectBtn.selected = !selectBtn.selected;
        nameL.textColor = selectBtn.selected ? kDarkTextColor : kLightTextColor;
        
    });
    return agentIns;
}

#pragma mark - UITableViewDelegate and datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.datasource objectAtIndex:section] count];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return 66;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellSelectedBlock block = data[kCKCellSelected];
    if (block) {
        block(data, indexPath);
    }
}

- (void)actionBack:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe" : @"shenhe0008"}];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submitAction:(id)sender
{
    [MobClick event:@"xiaomahuzhu" attributes:@{@"shenhe" : @"shenhe00010"}];
    UpdateCooperationInsInfoOp * op = [UpdateCooperationInsInfoOp operation];
    op.req_memberid = self.memberId;
    op.req_proxybuy = [NSNumber numberWithInteger:self.isAgent];
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在提交..."];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        [self backToMutualInsGrouponVC];
    } error:^(NSError *error) {
        [gToast showText:error.domain];
    }];
}

- (void)backToMutualInsGrouponVC
{
    //刷新团列表信息
    [[[MutualInsStore fetchExistsStore] reloadSimpleGroups] send];
    [[[MutualInsStore fetchExistsStore] reloadDetailGroupByMemberID:self.memberId andGroupID:self.groupId] send];
    
    MutualInsGrouponVC *grouponvc;
    MutualInsHomeVC *homevc;
    NSInteger homevcIndex = NSNotFound;
    for (NSInteger i=0; i<self.navigationController.viewControllers.count; i++) {
        UIViewController *vc = self.navigationController.viewControllers[i];
        if ([vc isKindOfClass:[MutualInsGrouponVC class]]) {
            grouponvc = (MutualInsGrouponVC *)vc;
            grouponvc.group.memberId = self.memberId;
            break;
        }
        if ([vc isKindOfClass:[MutualInsHomeVC class]]) {
            homevc = (MutualInsHomeVC *)vc;
            homevcIndex = i;
        }
    }
    if (grouponvc) {
        [self.navigationController popToViewController:grouponvc animated:YES];
        return;
    }
    //创建团详情视图
    grouponvc  = [mutInsGrouponStoryboard instantiateViewControllerWithIdentifier:@"MutualInsGrouponVC"];
    HKMutualGroup * group = [[HKMutualGroup alloc] init];
    group.groupId = self.groupId;
    group.groupName = self.groupName;
    group.memberId = self.memberId;
    grouponvc.group = group;
    
    NSMutableArray *vcs = [NSMutableArray array];
    
    // 堆栈中有小马互助首页
    if (homevcIndex != NSNotFound) {
        NSArray *subvcs = [self.navigationController.viewControllers subarrayToIndex:homevcIndex+1];
        [vcs addObjectsFromArray:subvcs];
    }
    else {
        //创建团root视图
        homevc = [UIStoryboard vcWithId:@"MutualInsHomeVC" inStoryboard:@"MutualInsJoin"];
        [vcs addObject:self.navigationController.viewControllers[0]];
        [vcs addObject:homevc];
    }
    [vcs addObject:grouponvc];
    [vcs addObject:self];
    self.navigationController.viewControllers = vcs;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
