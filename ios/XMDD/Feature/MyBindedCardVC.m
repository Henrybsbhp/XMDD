//
//  MyBindedCardVC.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MyBindedCardVC.h"
#import "NSString+RectSize.h"
#import "AddBankCardVC.h"
#import "GetBankCardListV2Op.h"
#import "UnbindingBankCardOp.h"
#import "MyBankCardListModel.h"
#import "JGActionSheet.h"
#import "BindBankCardVC.h"

@interface MyBindedCardVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *fetchedData;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (nonatomic, assign) BOOL isEditing;

/// 用作没有银行卡页面时添加银行卡的 Button
@property (nonatomic, strong) UIButton *addbutton;

@end

@implementation MyBindedCardVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MyBindedCardVC is deallocated");
    
}

- (void)viewDidLoad {
    
    @weakify(self)
    
    
    [super viewDidLoad];
    
    CKAfter (0.5, ^{
        [self observeTheFetchedDataToDetemineTheHiddenOfBarButtonItem];
        [self observeIsEditingValueToChangeBarButtonItemName];
        [self observeWhetherOrNotCardBindingSuccess];
    });
    
    [self fetchData];
    
    [self listenNotificationByName:kNotifyRefreshMyBankcardList withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);

        [self fetchData];
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)actionToCheckPrivilege
{
    DebugLog(@"Prvilege cell clicked");
}

// 浙商加油卡
- (void)actionToCZJCard
{
    BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
    [self.navigationController pushViewController:vc animated:YES];
}

// 添加银行卡
- (void)actionToAddCard
{
    AddBankCardVC *vc = [UIStoryboard vcWithId:@"AddBankCardVC" inStoryboard:@"Bank"];
    vc.router.userInfo = [CKDict dictWithCKDict:self.router.userInfo];
    vc.router.userInfo[kOriginRoute]= self.router;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)actionToUnbindTheBankCardWithTokenID:(NSString *)tokenID AtIndexPath:(NSIndexPath *)indexPath
{
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"否" color:kDefTintColor clickBlock:nil];
    HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"是" color:kGrayTextColor clickBlock:^(id alertVC) {
        UnbindingBankCardOp *op = [UnbindingBankCardOp operation];
        op.tokenID = tokenID;
        
        [[[op rac_postRequest] initially:^{
            [gToast showingWithText:@"正在解绑中..."];
        }] subscribeNext:^(id x) {
            [gToast showSuccess:@"解绑成功"];
            [self.datasource[indexPath.section] removeObjectAtIndex:indexPath.row];
            [self.fetchedData removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        } error:^(NSError *error) {
            [gToast showError:error.domain];
        }];
    }];
    
    HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" Message:@"是否确定解除绑定银行卡" ActionItems:@[confirm, cancel]];
    
    [alert show];
}

- (IBAction)actionEdit:(id)sender
{
    if (!self.isEditing) {
        [self.tableView setEditing:YES animated:YES];
        self.isEditing = YES;
    } else {
        [self.tableView setEditing:NO animated:YES];
        self.isEditing = NO;
    }
}

#pragma mark - Fetch data
- (void)fetchData
{
    GetBankCardListV2Op *op = [GetBankCardListV2Op operation];
    op.cardType = @(10);
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
        @strongify(self);
        CGFloat reducingY = self.view.frame.size.height * 0.1056;
        [self.view startActivityAnimationWithType:GifActivityIndicatorType atPositon:CGPointMake(self.view.center.x, self.view.center.y - reducingY)];
        self.tableView.hidden = YES;
        [self removeButton];
        
    }] subscribeNext:^(GetBankCardListV2Op *rop) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        if (rop.cards.count > 0) {
            self.fetchedData = [NSMutableArray arrayWithArray:rop.cards];
            [self setDataSourceWithDataArray:rop.cards];
            self.tableView.hidden = NO;
        } else {
            self.tableView.hidden = YES;
            [self addBtn];
        }
        
    } error:^(NSError *error) {
        
        @strongify(self);
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取银行卡信息失败，请点击重试" tapBlock:^{
            @strongify(self);
            [self.view hideDefaultEmptyView];
            [self fetchData];
        }];
    }];
}

- (void)setDataSourceWithDataArray:(NSArray *)dataArray
{
    self.datasource = [CKList list];
    CKList *bankCardList = [CKList list];
    for (MyBankCardListModel *model in dataArray) {
        CKDict *cardInfoCell = [self setupCardInfoCellWithModel:model];
        [bankCardList addObject:cardInfoCell forKey:nil];
    }
    
    [self.datasource addObject:bankCardList forKey:nil];
    [self.datasource addObject:$([self setupAddBankCardCell]) forKey:nil];
    [self.tableView reloadData];
}

#pragma mark - The settings of cells
- (CKDict *)setupCardInfoCellWithModel:(MyBankCardListModel *)model
{
    CKDict *cardInfoCell = [CKDict dictWith:@{kCKItemKey: @"cardInfoCell", kCKCellID: @"CardInfoCell"}];
    
    @weakify(self);
    cardInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        if (model.bankTips.length > 0) {
            CGSize size = [model.bankTips labelSizeWithWidth:gAppMgr.deviceInfo.screenSize.width - 88 font:[UIFont systemFontOfSize:12]];
            CGFloat height = size.height + 86;
            return MAX(height, 101);
        }
        
        return 80;
    });
    
    cardInfoCell[kCKCellSelected] = CKCellSelected(^(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        if (model.czbFlag == 1) {
            [self actionToCheckPrivilege];
        }
    });
    
    cardInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *logoImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
        UILabel *bankNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UILabel *cardNumLabel = (UILabel *)[cell.contentView viewWithTag:1002];
        UILabel *bankTipsLabel = (UILabel *)[cell.contentView viewWithTag:1003];
        UILabel *cardTypeLabel = (UILabel *)[cell.contentView viewWithTag:1004];
        UIButton *checkButton = (UIButton *)[cell.contentView viewWithTag:1005];
        UIImageView *separator = (UIImageView *)[cell.contentView viewWithTag:1006];
        
        checkButton.layer.borderColor = HEXCOLOR(@"#009CFF").CGColor;
        checkButton.layer.borderWidth = 0.5;
        checkButton.layer.cornerRadius = 7;
        checkButton.layer.masksToBounds = YES;
        
        CKList *cellList = self.datasource[indexPath.section];
        separator.hidden = indexPath.row == cellList.count - 1 ? YES : NO;
        
        [logoImageView setImageByUrl:model.bankLogo withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        bankNameLabel.text = model.issueBank;
        cardNumLabel.text = model.cardNo;
        bankTipsLabel.text = model.bankTips;
        cardTypeLabel.text = model.cardType;
        
        checkButton.hidden = model.czbFlag == 1 ? NO : YES;
        checkButton.enabled = NO;
    });
    
    return cardInfoCell;
}

- (CKDict *)setupAddBankCardCell
{
    CKDict *addBankCardCell = [CKDict dictWith:@{kCKItemKey: @"addBankCardCell", kCKCellID: @"AddBankCardCell"}];
    
    @weakify(self);
    addBankCardCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 62;
    });
    
    addBankCardCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        UIButton *addButton = (UIButton *)[cell.contentView viewWithTag:1000];
        @strongify(self);
        [[[addButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self popUpAddCardActionSheet];
        }];
    });
    
    return addBankCardCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return NO;
    }
    
    if (self.isEditing) {
        self.isEditing = NO;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return;
    }
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        MyBankCardListModel *model = [self.fetchedData safetyObjectAtIndex:indexPath.row];
        [self actionToUnbindTheBankCardWithTokenID:model.tokenID AtIndexPath:indexPath];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.isEditing = YES;
    return @"解除绑定";
}

#pragma mark - Utilities
-(void)addBtn
{
    //暂停动画并且显示缺省页
    @weakify(self)
    [self.view stopActivityAnimation];
    [self.view showEmptyViewWithImageName:@"def_withoutCard" text:@"暂无银行卡" centerOffset:-100 tapBlock:^{
        @strongify(self)
        [self fetchData];
    }];
    [self.view addSubview:self.addbutton];
    const CGFloat top = gAppMgr.deviceInfo.screenSize.height / 2 + 30;
    [self.addbutton mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(top);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(50);
    }];
}

- (void)removeButton
{
    NSArray *subViews = self.view.subviews;
    [self.view hideDefaultEmptyView];
    if ([subViews containsObject:self.addbutton]) {
        [self.addbutton removeFromSuperview];
    }
}

/// 监听 fetchedData 来决定右上角 barButton 的显示
- (void)observeTheFetchedDataToDetemineTheHiddenOfBarButtonItem
{
    @weakify(self);
    [RACObserve(self, fetchedData) subscribeNext:^(id x) {
        @strongify(self);
        if (self.fetchedData.count > 0) {
            self.editButton.title = @"编辑";
            self.editButton.enabled = YES;
        } else {
            [self.editButton setTitle:@""];
            self.editButton.enabled = NO;
        }
    }];
}

/// 监听 isEditing 的值来改变右上角 barButton 的名字
- (void)observeIsEditingValueToChangeBarButtonItemName
{
    @weakify(self);
    [RACObserve(self, isEditing) subscribeNext:^(id x) {
        @strongify(self);
        if (self.isEditing && self.fetchedData > 0) {
            [self.editButton setTitle:@"完成"];
            self.editButton.enabled = YES;
        } else if (!self.isEditing && self.fetchedData > 0) {
            [self.editButton setTitle:@"编辑"];
            self.editButton.enabled = YES;
        }
    }];
}

/// 监听银行卡是否绑定成功
- (void)observeWhetherOrNotCardBindingSuccess
{
    @weakify(self)
    [self listenNotificationByName:kNotifyCardBindingSuccess withNotifyBlock:^(NSNotification *note, id weakSelf) {
        @strongify(self);
        [self fetchedData];
    }];
}

- (void)popUpAddCardActionSheet
{
    JGActionSheetSection *opSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"浙商汽车卡", @"绑定银联支付"] buttonStyle:JGActionSheetButtonStyleDefault];
    JGActionSheetSection *cancelSection = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"取消"] buttonStyle:JGActionSheetButtonStyleCancel];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[opSection, cancelSection]];
    sheet.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [sheet showInView:self.navigationController.view animated:YES];
    
    @weakify(self);
    [sheet setButtonPressedBlock:^(JGActionSheet *rsheet, NSIndexPath *indexPath) {
        
        [rsheet dismissAnimated:YES];
        
        if (indexPath.section != 0) {
            return;
        }
        
        if (indexPath.section == 0 && indexPath.row == 0) {
            @strongify(self);
            [self actionToCZJCard];
            
        } else if (indexPath.section == 0 && indexPath.row == 1) {
            @strongify(self);
            [self actionToAddCard];
        }
    }];
}

#pragma mark - Lazy instantiation
- (UIButton *)addbutton
{
    if (!_addbutton)
    {
        _addbutton = [[UIButton alloc]init];
        _addbutton.backgroundColor = kDefTintColor;
        [_addbutton setTitle:@"添加银行卡" forState:UIControlStateNormal];
        _addbutton.layer.cornerRadius = 5;
        _addbutton.layer.masksToBounds = YES;
        @weakify(self);
        [[_addbutton rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            @strongify(self);
            [self popUpAddCardActionSheet];
        }];
    }
    return _addbutton;
}

@end
