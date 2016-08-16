//
//  MutualInsGroupDetailMeVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/7/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGroupDetailMeVC.h"
#import "MutualInsGroupMyBottomButtonCell.h"
#import "MutualInsGroupMyButtonCell.h"
#import "MutualInsGroupMySimpleHeaderCell.h"
#import "MutualInsGroupMyDetailHeaderCell.h"
#import "MutualInsGroupMyDetailCell.h"
#import "MutualInsPicUpdateVC.h"
#import "MutualInsConstants.h"
#import "GetCooperationUsercarListOp.h"
#import "MutualInsPickCarVC.h"
#import "HKMyCar.h"


@interface MutualInsGroupDetailMeVC ()
@end

@implementation MutualInsGroupDetailMeVC
- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTableView];
    [self subscribeReloadSignal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupTableView {
    [self.tableView registerClass:[MutualInsGroupMySimpleHeaderCell class] forCellReuseIdentifier:@"SimpleHeader"];
    [self.tableView registerClass:[MutualInsGroupMyButtonCell class] forCellReuseIdentifier:@"Button"];
    [self.tableView registerClass:[MutualInsGroupMyDetailHeaderCell class] forCellReuseIdentifier:@"DetailHeader"];
    [self.tableView registerClass:[MutualInsGroupMyDetailCell class] forCellReuseIdentifier:@"Detail"];
    [self.tableView registerClass:[MutualInsGroupMyBottomButtonCell class] forCellReuseIdentifier:@"BottomButton"];
}

#pragma mark - Subscribe
- (void)subscribeReloadSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, reloadMyInfoSignal) distinctUntilChanged] subscribeNext:^(RACSignal *signal) {
        
        @strongify(self);
        [[signal initially:^{
            
            @strongify(self);
            [self.tableView setHidden:YES animated:NO];
            CGPoint pos = CGPointMake(ScreenWidth/2, ScreenHeight/2 - 64);
            [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:pos];
        }] subscribeNext:^(GetCooperationGroupMyInfoOp *op) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.tableView setHidden:NO animated:YES];
            [self reloadDatasource];
        } error:^(NSError *error) {
            
            @strongify(self);
            [self.view stopActivityAnimation];
            [self.view showImageEmptyViewWithImageName:kImageFailConnect text:error.domain tapBlock:^{
                @strongify(self);
                [self.view hideDefaultEmptyView];
                [self.viewModel fetchMyInfoForce:YES];
            }];
            
        }];
    }];
}

#pragma mark - Action
/// 完善资料
- (void)actionFillInfo {
    if (self.viewModel.myInfo.rsp_status == 1 || self.viewModel.myInfo.rsp_status == 0) {
        [MobClick event:@"tuanxiangqing" attributes:@{@"tuanxiangqing":@"tuanxiangqing7"}];
    }
    else if (self.viewModel.myInfo.rsp_status == 20) {
        [MobClick event:@"tuanxiangqing" attributes:@{@"tuanxiangqing":@"tuanxiangqing8"}];
    }
    
    
    if (self.viewModel.myInfo.rsp_usercarid && self.viewModel.myInfo.rsp_licensenumber)
    {
        // 有车
        HKMyCar *car = [[HKMyCar alloc] init];
        car.carId = self.viewModel.myInfo.rsp_usercarid;
        car.licencenumber = self.viewModel.myInfo.rsp_licensenumber;
        
        MutualInsPicUpdateVC* vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
        vc.curCar = car;
        vc.groupId = self.viewModel.myInfo.req_groupid;
        vc.memberId = self.viewModel.myInfo.req_memberid;
        vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
        if ([self.viewModel.myInfo.req_memberid integerValue] > 0)
        {
            /// 有member的时候完善信息成功后返回到此页面。如果出现memberid为0的情况只会是团长没车的情况
            vc.router.userInfo[kOriginRoute] = self.parentViewController.router;
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        // 没车，此情况比较少见，（团长无车） @fq
        GetCooperationUsercarListOp * op = [[GetCooperationUsercarListOp alloc] init];
        [[[op rac_postRequest] initially:^{
            
            [gToast showingWithText:@"获取车辆数据中..." inView:self.view];
        }] subscribeNext:^(GetCooperationUsercarListOp * x) {
            
            [gToast dismissInView:self.view];
            if (x.rsp_carArray.count)
            {
                MutualInsPickCarVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPickCarVC"];
                vc.mutualInsCarArray = x.rsp_carArray;
                [vc setFinishPickCar:^(HKMyCar *car) {
                    
                    [self jumpToUpdateInfoVC:car andGroupId:self.viewModel.myInfo.req_groupid];
                }];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                [self jumpToUpdateInfoVC:nil andGroupId:self.viewModel.myInfo.req_groupid];
            }
        } error:^(NSError *error) {
            
            [gToast showError:@"获取失败，请重试" inView:self.view];
        }];
    }
}

/// 我的协议
- (void)actionAgreement {
    [MobClick event:@"tuanxiangqing" attributes:@{@"tuanxiangqing":@"tuanxiangqing9"}];
    DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
    vc.title = @"我的协议";
    vc.url = self.viewModel.myInfo.rsp_contracturl;
    [self.navigationController pushViewController:vc animated:YES];
}

/// 去支付
- (void)actionPay {
    UIViewController *vc = [mutualInsPayStoryboard instantiateViewControllerWithIdentifier:@"MutualInsOrderInfoVC"];
    [vc setValue:self.viewModel.baseInfo.rsp_contractid forKey:@"contractId"];
    vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
    vc.router.userInfo[kOriginRoute] = self.parentViewController.router;
    [self.router.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToUpdateInfoVC:(HKMyCar *)car andGroupId:(NSNumber *)groupId
{
    MutualInsPicUpdateVC * vc = [mutualInsJoinStoryboard instantiateViewControllerWithIdentifier:@"MutualInsPicUpdateVC"];
    vc.curCar = car;
    vc.memberId = nil;// 挑选车说明没有memberId
    vc.groupId = groupId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Datasource
- (void)reloadDatasource {
    switch (self.viewModel.myInfo.rsp_status) {
        case 5: case 6: case 7: case 8:
            self.datasource = $($([self itemForDetailHeader], [self itemForDetail], [self itemForBottomButton]));
            break;
        default:
            self.datasource = $($([self itemForSimpleHeader], [self itemForButton]));
    }
    [self.tableView reloadData];
}


- (CKDict *)itemForSimpleHeader {
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"SimpleHeader"}];

    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {

        @strongify(self);
        BOOL isTail = self.viewModel.myInfo.rsp_buttonname.length == 0;
        return [MutualInsGroupMySimpleHeaderCell heightWithDesc:self.viewModel.myInfo.rsp_tip isTail:isTail];
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMySimpleHeaderCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        GetCooperationGroupMyInfoOp *info = self.viewModel.myInfo;
        cell.logoView.hidden = info.rsp_licensenumber.length == 0;
        [cell.logoView setImageByUrl:info.rsp_carlogourl withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        cell.titleLabel.hidden = info.rsp_licensenumber.length == 0;
        cell.titleLabel.text = info.rsp_licensenumber;
        cell.descLabel.text = info.rsp_tip;
        cell.tipButton.hidden = [info.rsp_statusdesc length] == 0;
        [cell.tipButton setTitle:info.rsp_statusdesc forState:UIControlStateNormal];
    });
    return item;
}


- (id)itemForButton {
    if (self.viewModel.myInfo.rsp_buttonname.length == 0) {
        return CKNULL;
    }
    
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"Button"}];
    
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 70;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMyButtonCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        [cell.actionButton setTitle:self.viewModel.myInfo.rsp_buttonname forState:UIControlStateNormal];
        [[[cell.actionButton rac_signalForControlEvents:UIControlEventTouchUpInside]
          takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            switch (self.viewModel.myInfo.rsp_status) {
                case 0: case 1: case 20:
                    [self actionFillInfo];
                    break;
            }
        }];
    });
    
    return item;
}


- (id)itemForDetailHeader {

    CKDict *item = [CKDict dictWith:@{kCKCellID: @"DetailHeader"}];
    
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return 56;
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMyDetailHeaderCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        GetCooperationGroupMyInfoOp *info = self.viewModel.myInfo;
        [cell.logoView setImageByUrl:info.rsp_carlogourl withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        cell.titleLabel.text = info.rsp_licensenumber;
        [cell.tipButton setTitle:info.rsp_statusdesc forState:UIControlStateNormal];
    });
    return item;
}


- (id)itemForDetail {
    
    GetCooperationGroupMyInfoOp *info = self.viewModel.myInfo;
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"Detail"}];
    item[@"times"] = @[RACTuplePack(@"保障开始时间", self.viewModel.myInfo.rsp_insstarttime),
                       RACTuplePack(@"保障结束时间", self.viewModel.myInfo.rsp_insendtime)];
    if (info.rsp_status == 5) {
        CKList *list = $(RACTuplePack(@"互助金", info.rsp_sharemoney),
                         RACTuplePack(@"服务费", info.rsp_servicefee),
                         info.rsp_forcefee.length ==0 ? CKNULL : RACTuplePack(@"交强险", info.rsp_forcefee),
                         info.rsp_shiptaxfee.length == 0 ? CKNULL : RACTuplePack(@"车船税", info.rsp_shiptaxfee));
        item[@"prices"] = [list allObjects];
    }
    else if(info.rsp_status == 6 || info.rsp_status == 7 || info.rsp_status == 8) {
        CKList *list =  $(RACTuplePack(@"补偿次数", ([NSString stringWithFormat:@"%d次", info.rsp_claimcnt])),
                          RACTuplePack(@"补偿金额", info.rsp_claimfee),
                          RACTuplePack(@"补偿均摊", info.rsp_helpfee));
        item[@"prices"] = [list allObjects];
    }
    
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        
        return [MutualInsGroupMyDetailCell heightWithTimeTupleCount:[item[@"times"] count] andDesc:info.rsp_tip];
    });
    
    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMyDetailCell *cell, NSIndexPath *indexPath) {
       
        cell.feeLabel.text = info.rsp_fee;
        cell.feeDescLabel.text = info.rsp_feedesc;
        cell.priceTuples = item[@"prices"];
        cell.timeTuples = item[@"times"];
        cell.descLabel.text = info.rsp_tip;
    });
    return item;
}


- (id)itemForBottomButton {
    if (self.viewModel.myInfo.rsp_buttonname.length == 0) {
        return CKNULL;
    }
    
    CKDict *item = [CKDict dictWith:@{kCKCellID: @"BottomButton"}];
    @weakify(self);
    item[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 49;
    });

    item[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, MutualInsGroupMyBottomButtonCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        [cell.actionButton setTitle:self.viewModel.myInfo.rsp_buttonname forState:UIControlStateNormal];
        [[[cell.actionButton rac_signalForControlEvents:UIControlEventTouchUpInside]
         takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            switch (self.viewModel.myInfo.rsp_status) {
                case 5:
                    [self actionPay];
                    break;
                case 6: case 7: case 8:
                    [self actionAgreement];
                    break;
            }
        }];
    });
    return item;
}


@end
