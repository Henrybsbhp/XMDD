//
//  MutualInsGrouponCarsVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/16.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponMembersVC.h"
#import "MutualInsMemberInfo.h"
#import "GetCooperationMemberDetailOp.h"
#import "MutualInsConstants.h"
#import "NSString+Format.h"

#import "MutualInsAlertVC.h"

#define kItemWidth 46

@interface MutualInsGrouponMembersVC ()
@property (nonatomic, strong) UIView *bgView;
@end

@implementation MutualInsGrouponMembersVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (void)actionShowMemberAlertView:(GetCooperationMemberDetailOp *)op
{
    MutualInsAlertVC *alert = [[MutualInsAlertVC alloc] init];
    alert.topTitle = op.rsp_licensenumber;
    alert.actionItems = @[[HKAlertActionItem itemWithTitle:@"确定"]];
    NSArray *items;
    if (op.rsp_sharemoney > 0) {
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_licensenumber
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"互助资金" detailTitle:[NSString formatForRoundPrice2:op.rsp_sharemoney]
                                          detailColor:MutInsOrangeColor],
                  [MutualInsAlertVCItem itemWithTitle:@"所占比例" detailTitle:op.rsp_rate
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"目前可返" detailTitle:[NSString formatForRoundPrice2:op.rsp_returnmoney]
                                          detailColor:MutInsOrangeColor],
                  [MutualInsAlertVCItem itemWithTitle:@"出现次数" detailTitle:[NSString stringWithFormat:@"%d次", op.rsp_claimcount]
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"赔偿金额" detailTitle:[NSString formatForRoundPrice2:op.rsp_claimamount]
                                          detailColor:MutInsOrangeColor]];
    }
    else {
        items = @[[MutualInsAlertVCItem itemWithTitle:@"车    主" detailTitle:op.rsp_licensenumber
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"品牌车系" detailTitle:op.rsp_carbrand
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"互助资金" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"所占比例" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"目前可返" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"出现次数" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor],
                  [MutualInsAlertVCItem itemWithTitle:@"赔偿金额" detailTitle:@"暂无"
                                          detailColor:MutInsTextDarkGrayColor]];
    }
    alert.items = items;
    [alert show];
}

#pragma mark - Request
- (void)requestDetailInfoForMember:(NSNumber *)memberid
{
    GetCooperationMemberDetailOp *op = [GetCooperationMemberDetailOp operation];
    op.req_memberid = memberid;
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [gToast showingWithText:@"获取信息..."];
    }] subscribeNext:^(GetCooperationMemberDetailOp *op) {
        @strongify(self);
        [gToast dismiss];
        [self actionShowMemberAlertView:op];
    } error:^(NSError *error) {
        [gToast showError:error.domain];
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    UIImageView *logoV = [cell viewWithTag:1001];
    UILabel *textL = [cell viewWithTag:1002];
    
    MutualInsMemberInfo *info = [self.members safetyObjectAtIndex:indexPath.item];
    [logoV setImageByUrl:info.brandurl withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
    textL.text = info.licensenumber;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MutualInsMemberInfo *info = [self.members safetyObjectAtIndex:indexPath.item];
    [self requestDetailInfoForMember:info.memberid];
}

@end
