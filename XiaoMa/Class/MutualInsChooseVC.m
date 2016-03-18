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

@interface MutualInsChooseVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *datasource;
@property (nonatomic, strong) NSArray *insListArray;

@property (nonatomic, assign) BOOL isThirdDiscount;
@property (nonatomic, assign) BOOL isSeatDiscount;

@property (nonatomic, strong) NSString *thirdInsSelect;
@property (nonatomic, strong) NSString *seatInsSelect;
@property (nonatomic, strong) NSString *numberOfSeat;

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
    op.req_memberId = @120; //self.memberId;
    [[op rac_postRequest] subscribeNext:^(GetMutualInsListOp *rop) {
        
        //初始默认选择
        self.thirdInsSelect = @"100万";
        self.seatInsSelect = @"1万";
        self.numberOfSeat = @"5座";
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
        [self.datasource addObject:topTip forKey:@"topSection"];
    }
    
    //选择保险
    CKDict *carIns = [self setInsCellWithIndex:0 andModel:dataModel];
    CKDict *thirdIns = [self setInsCellWithIndex:1 andModel:dataModel];
    CKDict *seatIns = [self setInsCellWithIndex:2 andModel:dataModel];
    CKDict *agentIns = [self setAgentCell];
    [self.datasource addObject:$(carIns, thirdIns, seatIns, agentIns) forKey:@"insSection"];
    
    //预估费用
    CKDict *estTitle = [self setEstTitleCell];
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
        return height + 24; //上下约束为12+12
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
        //默认显示优惠信息，根据用户选择，使用reloadrows刷新行高
        return 66;
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
        if (discountFloat == 0) {
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
        }
        //三者
        else {
            selectBtn.selected = [ins[@"isSelected"] boolValue];
            [[[selectBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                //改状态
                ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                selectBtn.selected = !selectBtn.selected;
                insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                //算价格
                
            }];
            insNameL.textColor = [ins[@"isSelected"] boolValue] ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
            tipL.text = insIndex == 1 ? dataModel.thirdsumTip : dataModel.seatsumTip;
            itemL.text = insIndex == 1 ? [NSString stringWithFormat:@"%@/座", self.thirdInsSelect] : [NSString stringWithFormat:@"%@/座", self.seatInsSelect];
            NSArray * sheetArr = insIndex == 1 ? @[@50, @100, @150] : @[@1, @2, @3, @4, @5];
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
                        self.thirdInsSelect = [NSString stringWithFormat:@"%@万", sheetArr[btnIndex]];
                    }
                    else {
                        self.seatInsSelect = [NSString stringWithFormat:@"%@万", sheetArr[btnIndex]];
                    }
                    
                    //根据选择刷新当前行
                    BOOL showTip = insIndex == 1 ? [sheetArr[btnIndex] integerValue] >= [dataModel.minthirdSum integerValue] : [sheetArr[btnIndex] integerValue] >= [dataModel.minseatSum integerValue];
                    ins[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
                        return showTip ? 66 : 48;
                    });
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:insIndex inSection:[self.datasource indexOfObjectForKey:@"insSection"]];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }];
            ins[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
                
                UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
                UIButton * selectBtn = [cell.contentView viewWithTag:1001];
                UILabel * insNameL = [cell.contentView viewWithTag:1002];
                
                ins[@"isSelected"] = [NSString stringWithFormat:@"%d", ![ins[@"isSelected"] boolValue]];
                selectBtn.selected = !selectBtn.selected;
                insNameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
                //算价格
                
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
            //算价格
        }];
    });
    agentIns[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        
        UITableViewCell *cell=[self.tableView cellForRowAtIndexPath:indexPath];
        UIButton * selectBtn = [cell.contentView viewWithTag:1001];
        UILabel * nameL = [cell.contentView viewWithTag:1002];
        
        self.isAgent = !self.isAgent;
        selectBtn.selected = !selectBtn.selected;
        nameL.textColor = selectBtn.selected ? HEXCOLOR(@"#454545") : HEXCOLOR(@"#dbdbdb");
        //算价格
    });
    return agentIns;
}

- (CKDict *)setEstTitleCell
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
        seatL.text = self.numberOfSeat;
        [[[itemBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            //算价格
            //                UIActionSheet
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
        
        priceL.text = @"3567.00";
        NSString * tipStr = [NSString stringWithFormat:@"若未出险，还可返还%.2f", 1560.21];
        NSMutableAttributedString * attributeStr = [[NSMutableAttributedString alloc] initWithString:tipStr];
        [attributeStr addAttributeForegroundColor:HEXCOLOR(@"#FF7428") range:NSMakeRange(9, tipStr.length - 9)];
        tipL.attributedText = attributeStr;
    });
    return estPrice;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
        insListStr = [NSString stringWithFormat:@"%@|%@@%@@%@", insListStr, [[self.insListArray safetyObjectAtIndex:1] objectForKey:@"id"], [[self.insListArray safetyObjectAtIndex:1] objectForKey:@"name"], self.thirdInsSelect];
    }
    
    CKDict * seatIns = self.datasource[@"insSection"][2];
    if (seatIns[@"isSelected"]) {
        insListStr = [NSString stringWithFormat:@"%@|%@@%@@%@", insListStr, [[self.insListArray safetyObjectAtIndex:2] objectForKey:@"id"], [[self.insListArray safetyObjectAtIndex:2] objectForKey:@"name"], self.seatInsSelect];
    }
    
    op.req_memberid = self.memberId;
    op.req_inslist = insListStr;
    op.req_proxybuy = @(self.isAgent);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"正在提交..."];
    }] subscribeNext:^(id x) {
        [gToast showText:@"提交成功"];
    } error:^(NSError *error) {
        [gToast showText:error.domain];
    }];
}
@end
