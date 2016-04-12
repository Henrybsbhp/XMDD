//
//  MyBankVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyBankVC.h"
#import "ADViewController.h"
#import "HKConvertModel.h"
#import "CardDetailVC.h"
#import "BindBankCardVC.h"
#import "GetBankcardListOp.h"
#import "BankStore.h"
#import "BankCardDetailVC.h"

@interface MyBankVC ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ADViewController *advc;
@property (nonatomic, strong) NSArray *bankCards;
@property (nonatomic, strong) BankStore *bankStore;

@property (nonatomic, strong) UIButton *btn;

@end

@implementation MyBankVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MyBankVC dealloc!");
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupAdView];
    [self setupBankStore];
    [self reloadDataIfNeeded];
}

- (void)setupAdView
{
    CKAsyncMainQueue(^{
        self.advc  =[ADViewController vcWithADType:AdvertisementBankCardBinding boundsWidth:self.view.bounds.size.width
                                          targetVC:self mobBaseEvent:@"rp314_1"];
        [self.advc reloadDataForTableView:self.tableView];
    });
}

- (void)setupBankStore
{
    self.bankStore = [BankStore fetchOrCreateStore];
    
    @weakify(self);
    [self.bankStore subscribeWithTarget:self domain:kDomainBankCards receiver:^(id store, CKEvent *evt) {
        @strongify(self);
        if (![self isEqual:evt.object]) {
            [self reloadWithSignal:evt.signal];
        }
    }];
}

#pragma mark - Reload
- (void)reloadDataIfNeeded
{
    CKEvent *event = [[self.bankStore getAllBankCardsIfNeeded] setObject:self];
    [self reloadWithSignal:[event sendWithIgnoreError:YES andDelay:0.4]];
}


- (void)reloadData
{
    CKEvent *event = [[self.bankStore getAllBankCards] setObject:self];
    [self reloadWithSignal:[event sendWithIgnoreError:YES andDelay:0.4]];
}

- (void)reloadWithSignal:(RACSignal *)signal
{
    if (!signal) {
        self.bankCards = [self.bankStore.bankCards allObjects];
        [self.tableView reloadData];
        return;
    }
    @weakify(self);
    [[signal initially:^{
        
        @strongify(self);
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView beginRefreshing];
        }
        else {
            [self hideContentViews];
        }
        [self removeBtn];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        if (![self.tableView isRefreshViewExists]) {
            [self setupRefreshView];
        }
        self.bankCards = [self.bankStore.bankCards allObjects];
        if (self.bankCards.count > 0)
        {
            [self showContentViews];
            [self.tableView reloadData];
        }
        else
        {
            [self hideContentViews];
            [self addBtn];
        }
        if ([self.tableView isRefreshViewExists]) {
            [self.tableView.refreshView endRefreshing];
        }
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        if (![self.tableView isRefreshViewExists])
        {
            [self.view showDefaultEmptyViewWithText:@"获取银行卡信息失败，请点击重试" tapBlock:^{
                [self reloadData];
            }];
        }
    }];
}

-(void)setupRefreshView
{
    @weakify(self)
    [[self.tableView.refreshView rac_signalForControlEvents:UIControlEventValueChanged]subscribeNext:^(id x) {
        @strongify(self)
        [self reloadData];
    }];
}

-(void)removeBtn
{
    NSArray *subViews = self.view.subviews;
    [self.view hideDefaultEmptyView];
    if ([subViews containsObject:self.btn])
    {
        [self.btn removeFromSuperview];
    }
}

-(void)addBtn
{
    @weakify(self)
    [self.view showEmptyViewWithImageName:@"def_withoutCard" text:@"添加银行卡" centerOffset:-100 tapBlock:^{
        @strongify(self)
        [self reloadData];
    }];
    [self.view addSubview:self.btn];
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.center.y + 30);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(50);
    }];
}

- (void)showContentViews
{
    self.bottomView.hidden = NO;
    self.tableView.hidden = NO;
}

- (void)hideContentViews
{
    self.bottomView.hidden = YES;
    self.tableView.hidden = YES;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //点击“添加银行卡”
    if (indexPath.row == self.bankCards.count) {
        [MobClick event:@"rp314_3"];
        BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    //点击某张银行卡
    else if (indexPath.row < self.bankCards.count) {
        [MobClick event:@"rp314_2"];
        HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row];
        if (self.didSelectedBlock) {
            self.didSelectedBlock(card);
            [self actionBack:nil];
            return;
        }
        BankCardDetailVC *vc = [UIStoryboard vcWithId:@"BankCardDetailVC" inStoryboard:@"Bank"];
        vc.card = card;
        vc.originVC = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.bankCards.count) {
        
        return 114;
        
    }
    
    return 104;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bankCards.count == 0 ? 0 : self.bankCards.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == self.bankCards.count) {
        
        cell = [self addCellAtIndexPath:indexPath];
        
    } else {
        
        cell = [self bankCellAtIndexPath:indexPath];
        
    }
    return cell;
}

#pragma mark - Abount Cell
- (UITableViewCell *)promptCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"PromptCell" forIndexPath:indexPath];
    return cell;
}

- (UITableViewCell *)bankCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BankCell" forIndexPath:indexPath];
    UIImageView *bgV = (UIImageView *)[cell.contentView viewWithTag:1000];
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel *cardTypeL = (UILabel *)[cell.contentView viewWithTag:1003];
    UILabel *numberL = (UILabel *)[cell.contentView viewWithTag:1004];
    
    HKBankCard *card = [self.bankCards safetyObjectAtIndex:indexPath.row];
    
    if (indexPath.row % 3 == 0) {
        bgV.image = [UIImage imageNamed:@"Bank_redCardBackground_imageView"];
    }
    else if (indexPath.row % 3 == 1) {
        bgV.image = [UIImage imageNamed:@"Bank_greenCardBackground_imageView"];
    }
    else if (indexPath.row % 3 == 2) {
        bgV.image = [UIImage imageNamed:@"Bank_blueCardBackground_imageView"];
    }
    
    logoV.image = [UIImage imageNamed:@"mb_logo"];
    titleL.text = card.cardName;
    cardTypeL.text = card.cardType == HKBankCardTypeCredit ? @"信用卡" : @"储蓄卡";
    numberL.text = [HKConvertModel convertCardNumberForEncryption:card.cardNumber];
    return cell;
}


- (UITableViewCell *)addCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCell" forIndexPath:indexPath];
    return cell;
}

-(UIButton *)btn
{
    if (!_btn)
    {
        _btn = [[UIButton alloc]init];
        _btn.backgroundColor = HEXCOLOR(@"#18d06a");
        [_btn setTitle:@"暂无银行卡" forState:UIControlStateNormal];
        _btn.layer.cornerRadius = 5;
        _btn.layer.masksToBounds = YES;
        @weakify(self);
        [[_btn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            @strongify(self);
            [MobClick event:@"rp314_3"];
            BindBankCardVC *vc = [UIStoryboard vcWithId:@"BindBankCardVC" inStoryboard:@"Bank"];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _btn;
}

@end
