//
//  MutualInsChooseVC.m
//  XiaoMa
//
//  Created by jt on 16/3/14.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsChooseVC.h"
#import "GetMutualInsListOp.h"
#import "CKDatasource.h"
#import "NSString+RectSize.h"
#import "UIView+RoundedCorner.h"
#import "NSString+Price.h"
#import "UpdateCooperationInsInfoOp.h"
#import "MutualInsGrouponVC.h"
#import "MutualInsHomeVC.h"

#define ThirdInsArr        @[@50, @100, @150]
#define ThirdPiceArr       @[@1631, @2124, @2686]
#define SeatInsArr         @[@1, @2, @3, @4, @5]
#define NumOfSeatArr       @[@2, @5, @7]
#define DriverDiscount     0.0041
#define PassengerDiscount  0.0026

@interface MutualInsChooseVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) NSArray *insListArray;

@property (nonatomic, assign) CGFloat totalPrice;
@property (nonatomic, assign) CGFloat carPrice;
@property (nonatomic, assign) CGFloat thirdPrice;
@property (nonatomic, assign) CGFloat seatPrice;

@property (nonatomic, assign) BOOL isThirdDiscount;
@property (nonatomic, assign) BOOL isSeatDiscount;

@property (nonatomic, assign) NSInteger thirdInsSelectIndex;
@property (nonatomic, assign) NSInteger seatInsSelect;
@property (nonatomic, assign) NSInteger numberOfSeat;

@property (nonatomic, assign) BOOL isAgent;

- (IBAction)submitAction:(id)sender;

@end

@implementation MutualInsChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self requestData];
}

- (void)requestData
{
    GetMutualInsListOp *op = [GetMutualInsListOp operation];
    op.req_version = gAppMgr.deviceInfo.appVersion;
    op.req_memberId = self.memberId;
    [[op rac_postRequest] subscribeNext:^(GetMutualInsListOp *rop) {
        
        //初始默认选择
        self.thirdInsSelectIndex = 0;
        self.seatInsSelect = 1;
        self.numberOfSeat = [NumOfSeatArr[1] integerValue];
        self.insListArray = rop.rsp_insModel.insList;
        [self setDataSource:rop.rsp_insModel];
        
    } error:^(NSError *error) {
        
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
    
    //选择保险
    CKDict *carIns = [self setInsCellWithIndex:0 andModel:dataModel];
    CKDict *thirdIns = [self setInsCellWithIndex:1 andModel:dataModel];
    CKDict *seatIns = [self setInsCellWithIndex:2 andModel:dataModel];
    CKDict *agentIns = [self setAgentCell];
    [self.datasource addObject:$(carIns, thirdIns, seatIns, agentIns) forKey:@"insSection"];
    
    //预估费用
    CKDict *estTitle = [self setEstTitleCellWithModel:dataModel];
    CKDict *estPrice = [self setPirceCell];
    [self.datasource addObject:$(estTitle, estPrice) forKey:@"priceSection"];
    
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

- (CKDict *)setInsCellWithIndex:(NSInteger)insIndex andModel:(HKMutualInsList *)dataModel {
    //初始化身份标识
    CKDict * ins = [CKDict dictWith:@{@"isSelected":@0, kCKCellID:@"InsContentCell"}];
    //cell行高
    ins[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 48;
    });
    //cell准备重绘
    ins[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * insNameL = [cell.contentView viewWithTag:1002];
        UILabel * discountL = [cell.contentView viewWithTag:1003];
        UILabel * tipL = [cell.contentView viewWithTag:1004];
        UILabel * itemL = [cell.contentView viewWithTag:1005];
        UIImageView * connerImgV = [cell.contentView viewWithTag:1006];
        UIButton * itemBtn = [cell.contentView viewWithTag:1007];
        UIButton * helpBtn = [cell.contentView viewWithTag:1008];
        
        //保险名称
        insNameL.text = [dataModel.insList[insIndex] objectForKey:@"name"];
        //保险折扣
        CGFloat discountFloat = [[dataModel.insList[insIndex] objectForKey:@"discount"] floatValue] / 10;
        if (discountFloat == 10) {
            discountL.hidden = YES;
        }
        else {
            discountL.text = [NSString stringWithFormat:@"  %@折  ", [NSString formatForDiscount:discountFloat]];
            [discountL setCornerRadius:2 withBorderColor:HEXCOLOR(@"#ff7428") borderWidth:0.5];
        }
        
        //帮助按钮
        [[[helpBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            if (insIndex == 0) {
                //车损宝帮助
            }
        }];
        
        //车损
        if (insIndex == 0) {
            selectBtn.selected = YES;
            insNameL.textColor = HEXCOLOR(@"#454545");
            tipL.text = @"含不计免赔。若未出险，到期后可全额退款";
            itemL.hidden = YES;
            connerImgV.hidden = YES;
            itemBtn.hidden = YES;
            //车损宝价格（不变）
            self.carPrice = dataModel.purchasePrice * (discountFloat / 10) * (dataModel.xmddDiscount / 100) ;
            DebugLog(@"车损险：%.2f", self.carPrice);
        }
        else {
            selectBtn.selected = [ins[@"isSelected"] boolValue];
            [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                //改状态
                if (insIndex == 1) {
                    ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                    selectBtn.selected = !selectBtn.selected;
                    insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                    //更改座位险状态
                    CKDict *seatInsDic = self.datasource[@"insSection"][2];
                    seatInsDic[@"isSelected"] = ins[@"isSelected"];
                    [self.tableView reloadData];
                }
                else {
                    CKDict *thirdInsDic = self.datasource[@"insSection"][1];
                    if (![thirdInsDic[@"isSelected"] boolValue]) {
                        ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                        selectBtn.selected = !selectBtn.selected;
                        insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                    }
                }
                //算价格
                [self calculatePrice:dataModel forIndex:insIndex];
            }];
            insNameL.textColor = [ins[@"isSelected"] boolValue] ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
            tipL.text = insIndex == 1 ? dataModel.thirdsumTip : dataModel.seatsumTip;
            itemL.text = insIndex == 1 ? [NSString stringWithFormat:@"%ld万", [[ThirdInsArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue]] : [NSString stringWithFormat:@"%ld万/座", (long)self.seatInsSelect];
            NSArray * sheetArr = insIndex == 1 ? ThirdInsArr : SeatInsArr;
            [[[itemBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                UIActionSheet * actionSheet;
                if (insIndex == 1) {
                    actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"50万", @"100万", @"150万", nil];
                }
                else {
                    actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"1万/座", @"2万/座", @"3万/座", @"4万/座", @"5万/座", nil];
                }
                
                [actionSheet showInView:self.view];
                [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
                    
                    NSInteger btnIndex = [number integerValue];
                    if (insIndex == 1 && btnIndex == 3) {
                        return;
                    }
                    else if (insIndex == 2 && btnIndex == 5) {
                        return;
                    }
                    
                    if (insIndex == 1) {
                        self.thirdInsSelectIndex = btnIndex;
                    }
                    else {
                        self.seatInsSelect = [sheetArr[btnIndex] integerValue];
                        DebugLog(@"%ld", (long)self.seatInsSelect);
                    }
                    //根据选择刷新当前行
                    ins[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
                        if (insIndex == 1 && [sheetArr[btnIndex] integerValue] >= [dataModel.minthirdSum integerValue]) {
                            return 66;
                        }
                        if (insIndex == 2 && [[ThirdInsArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue] >= [dataModel.minthirdSum integerValue] && [sheetArr[btnIndex] integerValue] >= [dataModel.minseatSum integerValue]) {
                            return 66;
                        }
                        return 44;
                    });
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insIndex inSection:[self.datasource indexOfObjectForKey:@"insSection"]];
                    if (insIndex == 1) {
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath, [NSIndexPath indexPathForRow:insIndex + 1 inSection:[self.datasource indexOfObjectForKey:@"insSection"]]] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    else {
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    //算价格
                    [self calculatePrice:dataModel forIndex:insIndex];
                }];
            }];
            ins[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
                
                UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
                UIButton * selectBtn = [cell.contentView viewWithTag:1001];
                UILabel * insNameL = [cell.contentView viewWithTag:1002];
                
                //改状态
                if (insIndex == 1) {
                    ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                    selectBtn.selected = !selectBtn.selected;
                    insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                    //更改座位险状态
                    CKDict *seatInsDic = self.datasource[@"insSection"][2];
                    seatInsDic[@"isSelected"] = ins[@"isSelected"];
                    [self.tableView reloadData];
                }
                else {
                    CKDict *thirdInsDic = self.datasource[@"insSection"][1];
                    if (![thirdInsDic[@"isSelected"] boolValue]) {
                        ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                        selectBtn.selected = !selectBtn.selected;
                        insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                    }
                }
                //算价格
                [self calculatePrice:dataModel forIndex:insIndex];
            });
        }
    });
    return ins;
}

- (CKDict *)setAgentCell
{
    //初始化身份标识
    CKDict * agentIns = [CKDict dictWith:@{kCKCellID:@"InsAgentCell"}];
    //cell行高
    agentIns[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 75;
    });
    //cell准备重绘
    agentIns[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * nameL = [cell.contentView viewWithTag:1002];
        
        self.isAgent = NO;
        nameL.text = @"交强险/车船税";
        nameL.textColor = HEXCOLOR(@"#dbdbdb");
        [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            self.isAgent = !self.isAgent;
            selectBtn.selected = !selectBtn.selected;
            nameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
        }];
    });
    agentIns[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * nameL = [cell.contentView viewWithTag:1002];
        
        self.isAgent = !self.isAgent;
        selectBtn.selected = !selectBtn.selected;
        nameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");

    });
    return agentIns;
}

- (CKDict *)setEstTitleCellWithModel:(HKMutualInsList *)dataModel
{
    //初始化身份标识
    CKDict * estTitle = [CKDict dictWith:@{kCKCellID:@"EstimateTitleCell"}];
    //cell行高
    estTitle[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 45;
    });
    //cell准备重绘
    estTitle[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *timeL = [cell.contentView viewWithTag:1001];
        UILabel *seatL = [cell.contentView viewWithTag:1002];
        UIButton *itemBtn = [cell.contentView viewWithTag:1003];
        
        timeL.text = @"  12个月  ";
        [timeL setCornerRadius:2 withBorderColor:HEXCOLOR(@"#ff7428") borderWidth:0.5];
        seatL.text = [NSString stringWithFormat:@"%ld座", (long)self.numberOfSeat];
        [[[itemBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
            UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"2座", @"5座", @"7座", nil];
            [actionSheet showInView:self.view];
            [[actionSheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * number) {
                
                NSInteger btnIndex = [number integerValue];
                if (btnIndex == 3) {
                    return;
                }
                else {
                    self.numberOfSeat = [NumOfSeatArr[btnIndex] integerValue];
                }
                
                //刷新座位选择
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:[self.datasource indexOfObjectForKey:@"priceSection"]];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                //是否选择了座位险
                CKDict *thirdInsDic = self.datasource[@"insSection"][2];
                BOOL isThirdSelected = [[thirdInsDic objectForKeyedSubscript:@"isSelected"] boolValue];
                if (isThirdSelected) {
                    [self calculatePrice:dataModel forIndex:2];
                    //刷新价格
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:[self.datasource indexOfObjectForKey:@"priceSection"]];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                
            }];
        }];
    });
    return estTitle;
}

- (CKDict *)setPirceCell
{
    //初始化身份标识
    CKDict * estPrice = [CKDict dictWith:@{kCKCellID:@"EstimateContentCell"}];
    //cell行高
    estPrice[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 103;
    });
    //cell准备重绘
    estPrice[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *priceL = [cell.contentView viewWithTag:1001];
        UILabel *tipL = [cell.contentView viewWithTag:1002];
        
        priceL.text = [NSString formatForPrice:self.totalPrice];
        NSString * tipStr = [NSString stringWithFormat:@"若未出险，还可返还%@", [NSString formatForPrice:self.carPrice]];
        NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
        [attributeStr addAttributeForegroundColor:HEXCOLOR(@"#FF7428") range:NSMakeRange(9, tipStr.length - 9)];
        tipL.attributedText = attributeStr;
    });
    return estPrice;
}

#pragma mark - Calculated
- (void)calculatePrice:(HKMutualInsList *)dataModel forIndex:(NSInteger)insIndex
{
    CGFloat thirdDiscountFloat = [[dataModel.insList[1] objectForKey:@"discount"] floatValue] / 100;
    CGFloat seatDiscountFloat = [[dataModel.insList[2] objectForKey:@"discount"] floatValue] / 100;
    CGFloat xmDiscount = dataModel.xmddDiscount * 0.01;
    //三者险是否被选择
    CKDict *thirdInsDic = self.datasource[@"insSection"][1];
    BOOL isThirdSelected = [[thirdInsDic objectForKeyedSubscript:@"isSelected"] boolValue];
    //座位险是否被选择
    CKDict *seatInsDic = self.datasource[@"insSection"][2];
    BOOL isSeatSelected = [[seatInsDic objectForKeyedSubscript:@"isSelected"] boolValue];
    if (insIndex == 1) {
        //三者险价格（标准报价*险种折扣*小马折扣）
        self.thirdPrice = isThirdSelected ? [[ThirdPiceArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue] * thirdDiscountFloat * xmDiscount : 0;
        //重新计算座位险
        NSInteger realSeat = self.seatInsSelect;
        if ([[ThirdInsArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue] >= [dataModel.minthirdSum integerValue] && isThirdSelected) {
            realSeat = self.seatInsSelect - 1;
        }
        self.seatPrice = isSeatSelected ? (realSeat * 10000 * DriverDiscount + realSeat * 10000 * (self.numberOfSeat - 1) * PassengerDiscount) * seatDiscountFloat * xmDiscount : 0;
    }
    else {
        //座位险价格（（司机保费+乘客保费）* 险种折扣*小马折扣）
        NSInteger realSeat = self.seatInsSelect;
        if ([[ThirdInsArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue] >= [dataModel.minthirdSum integerValue] && isThirdSelected) {
            realSeat = self.seatInsSelect - 1;
        }
        self.seatPrice = isSeatSelected ? (realSeat * 10000 * DriverDiscount + realSeat * 10000 * (self.numberOfSeat - 1) * PassengerDiscount) * seatDiscountFloat * xmDiscount : 0;
        //重新计算三者险
        self.thirdPrice = isThirdSelected ? [[ThirdPiceArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue] * thirdDiscountFloat * xmDiscount : 0;
    }
    self.totalPrice = self.carPrice + self.thirdPrice + self.seatPrice;
    //刷新价格
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:[self.datasource indexOfObjectForKey:@"priceSection"]];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (IBAction)submitAction:(id)sender {
    UpdateCooperationInsInfoOp * op = [UpdateCooperationInsInfoOp operation];
    
    NSString * insListStr = [NSString stringWithFormat:@"%@@%@@0",[[self.insListArray safetyObjectAtIndex:0] objectForKey:@"id"], [[self.insListArray safetyObjectAtIndex:0] objectForKey:@"name"]];
    
    CKDict * thirdIns = self.datasource[@"insSection"][1];
    if (thirdIns[@"isSelected"]) {
        insListStr = [NSString stringWithFormat:@"%@|%@@%@@%@", insListStr, [[self.insListArray safetyObjectAtIndex:1] objectForKey:@"id"], [[self.insListArray safetyObjectAtIndex:1] objectForKey:@"name"], [NSString stringWithFormat:@"%ld万", [[ThirdInsArr safetyObjectAtIndex:self.thirdInsSelectIndex] integerValue]]];
    }
    
    CKDict * seatIns = self.datasource[@"insSection"][2];
    if (seatIns[@"isSelected"]) {
        insListStr = [NSString stringWithFormat:@"%@|%@@%@@%@万", insListStr, [[self.insListArray safetyObjectAtIndex:2] objectForKey:@"id"], [[self.insListArray safetyObjectAtIndex:2] objectForKey:@"name"], [NSString stringWithFormat:@"%ld万", (long)self.seatInsSelect]];
    }
    
    op.req_memberid = self.memberId;
    op.req_inslist = insListStr;
    op.req_proxybuy = [NSNumber numberWithInteger:self.isAgent];
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在提交..."];
    }] subscribeNext:^(id x) {
        [gToast dismiss];
        [self submitSuccessful];
    } error:^(NSError *error) {
        [gToast showText:error.domain];
    }];
}

- (void)submitSuccessful
{
    for (NSInteger i = self.navigationController.viewControllers.count - 1 ; i >= 0; i--)
    {
        UIViewController * vc = [self.navigationController.viewControllers safetyObjectAtIndex:i];
        if ([vc isKindOfClass:[MutualInsGrouponVC class]])
        {
            [((MutualInsGrouponVC *)vc) requestGroupDetailInfo];
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
        if ([vc isKindOfClass:[MutualInsHomeVC class]])
        {
            [((MutualInsHomeVC *)vc) requestMyGourpInfo];
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
@end
