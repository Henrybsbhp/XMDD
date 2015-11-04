//
//  GasAddCardVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasAddCardVC.h"
#import "GasCardStore.h"
#import "HKTableViewCell.h"
#import "NSString+Split.h"
#import "CKLimitTextField.h"
#import "UIView+Shake.h"
#import <KeyboardManager.h>

@interface GasAddCardVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
///中石化
@property (nonatomic, strong) GasCard *snpnCard;
///中石油
@property (nonatomic, strong) GasCard *cnpcCard;
///当前选择的油卡
@property (nonatomic, weak) GasCard *curCard;
@end

@implementation GasAddCardVC

- (void)awakeFromNib
{
    self.snpnCard = [[GasCard alloc] init];
    self.snpnCard.cardtype = 1;
    self.cnpcCard = [[GasCard alloc] init];
    self.cnpcCard.cardtype = 2;
    self.curCard = self.snpnCard;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].shouldShowTextFieldPlaceholder = YES;
}
#pragma mark - Action
- (IBAction)actionSwitch:(UIButton *)sender
{
    self.curCard = sender.tag == 1001 ? self.snpnCard : self.cnpcCard;
}

- (IBAction)actionAddCard:(id)sender
{
    if (self.curCard.gascardno.length != [self.curCard maxCardNumberLength]) {
        [self shakeTextFieldCellAtRow:1];
        return;
    }
    if (![self.curCard.gascardno isEqual:self.curCard.customObject]) {
        [self shakeTextFieldCellAtRow:2];
        return;
    }
    GasCardStore *store = [GasCardStore fetchOrCreateStore];
    @weakify(self);
    [[[[store sendEvent:[store addCard:self.curCard]] signal] initially:^{
        
        [gToast showingWithText:@"正在添加..."];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        [gToast dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
    }];
}
#pragma mark - UITableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 120;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self brandCellAtIndexPath:indexPath];
    }
    return [self cardCellAtIndexPath:indexPath];
}

- (UITableViewCell *)brandCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BrandCell" forIndexPath:indexPath];
    UIButton *iconBtn1 = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *iconBtn2 = (UIButton *)[cell.contentView viewWithTag:1002];
    UIImageView *checkedV1 = (UIImageView *)[cell.contentView viewWithTag:1003];
    UIImageView *checkedV2 = (UIImageView *)[cell.contentView viewWithTag:1004];
    
    iconBtn1.layer.borderWidth = 0.5;
    iconBtn1.layer.cornerRadius = 5;
    iconBtn1.layer.masksToBounds = YES;
    iconBtn2.layer.borderWidth = 0.5;
    iconBtn2.layer.cornerRadius = 5;
    iconBtn2.layer.masksToBounds = YES;
    [[RACObserve(self, curCard) takeUntilForCell:cell] subscribeNext:^(GasCard *card) {
        if (card.cardtype == 2) {
            iconBtn1.borderColor = HEXCOLOR(@"#dddddd");
            iconBtn2.borderColor = HEXCOLOR(@"#20ab2a");
            checkedV1.hidden = YES;
            checkedV2.hidden = NO;
        } else {
            iconBtn2.borderColor = HEXCOLOR(@"#dddddd");
            iconBtn1.borderColor = HEXCOLOR(@"#20ab2a");
            checkedV2.hidden = YES;
            checkedV1.hidden = NO;
        }
    }];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalTop insets:UIEdgeInsetsZero];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsZero];
    return cell;
}

- (UITableViewCell *)cardCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1002];
    
    titleL.text = indexPath.row == 1 ? @"加油卡号" : @"确认卡号";
    
    [[RACObserve(self, curCard) distinctUntilChanged] subscribeNext:^(GasCard *card) {
        field.placeholder = card.cardtype == 1 ? @"请输入19位加油卡号" : @"请输入16位加油卡号";
        field.textLimit = card.cardtype == 1 ? 23 : 19;
        if (indexPath.row == 1) {
            field.text = [card.gascardno splitByStep:4 replacement:@" "];
        } else {
            field.text = [card.customObject splitByStep:4 replacement:@" "];
        }
        [field setTextChangingBlock:^(CKLimitTextField *textField, NSString *replacement) {
            NSInteger cursor = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.curCursorPosition];
            NSInteger posOffset = 0;
            NSInteger partOffset = cursor % 5;
            //删除空格后一位
            if (cursor > 0 && partOffset == 0 && replacement.length == 0) {
                posOffset = -1;
            }
            //在空格前插入
            else if (cursor > 0 && (partOffset == 0) && replacement.length > 0) {
                posOffset = 1;
            }
            if (posOffset != 0) {
                textField.curCursorPosition = [textField positionFromPosition:textField.curCursorPosition offset:posOffset];
            }

            NSString *orgText = textField.text.length > 0 ?
            [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] : @"";
            NSInteger maxLen = card.cardtype == 1 ? 19 : 16;
            NSString *realText = orgText.length > maxLen ? [orgText substringToIndex:maxLen] : orgText;
            if (indexPath.row == 1)  {
                self.curCard.gascardno = realText;
            }
            else {
                self.curCard.customObject = realText;
            }
            NSString *text = [orgText splitByStep:4 replacement:@" "];
            textField.text = text;
        }];
    }];
    
    UIEdgeInsets insets = indexPath.row == 2 ? UIEdgeInsetsZero : UIEdgeInsetsMake(0, 12, 0, 0);
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:insets];
    return cell;
}

#pragma mark - Utility
- (void)shakeTextFieldCellAtRow:(NSUInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}
@end
