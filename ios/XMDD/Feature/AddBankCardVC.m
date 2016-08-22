//
//  AddBankCardVC.m
//  XMDD
//
//  Created by St.Jimmy on 8/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "AddBankCardVC.h"
#import "NSString+Split.h"
#import "UIView+Shake.h"
#import "GetBankCardBaseInfoOp.h"
#import "PrebindingBankCardOp.h"
#import "DetailWebVC.h"

@interface AddBankCardVC ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *issueBankName;
@property (nonatomic, copy) NSString *bankLogoURL;
@property (nonatomic, copy) NSString *cardType;

@end

@implementation AddBankCardVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"AddBankCardVC is deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datasource = $($([self setupAddCardNumCell], [self setupCardInfoCell], [self setupNextUpCell]));
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions
- (void)actionCheckSupportedBankCard
{
    
}

- (void)actionToNextSteup
{
    [self.view endEditing:YES];
    
    if (self.cardNum.length < 16) {
        [self shakeTextFieldCellAtRow:0];
        return;
    }
        
    PrebindingBankCardOp *op = [PrebindingBankCardOp operation];
    op.cardNo = self.cardNum;
    op.tradeNo = self.tradeNum;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"正在请求中..."];
        
    }] subscribeNext:^(PrebindingBankCardOp *rop) {
        
        [gToast dismiss];
        DetailWebVC *vc = [UIStoryboard vcWithId:@"DetailWebVC" inStoryboard:@"Discover"];
        
        vc.title = @"绑定银行卡";
        vc.subject = self.tradeNum.length == 0 ? nil : self.subject;
        
//        @YZC 记得修改
        
//        vc.url = rop.bindURL;
        vc.url = @"http://dev.xiaomadada.com/print.html";
        [self.navigationController pushViewController:vc animated:YES];
        
    } error:^(NSError *error) {
        
        [gToast dismiss];
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"确认" color:kDefTintColor clickBlock:nil];
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:error.domain ImageName:@"mins_error" Message:nil ActionItems:@[cancel]];
        
        [alert show];
    }];
}

#pragma mark - The settings of cells
- (CKDict *)setupAddCardNumCell
{
    CKDict *addCardNumCell = [CKDict dictWith:@{kCKItemKey: @"addCardNumCell", kCKCellID: @"AddCardNumCell"}];
    
    @weakify(self);
    addCardNumCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    
    addCardNumCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        CKLimitTextField *cardNumTextField = (CKLimitTextField *)[cell.contentView viewWithTag:1001];
        
        cardNumTextField.textLimit = 23;
        if (self.cardNum.length > 0) {
            cardNumTextField.text = self.cardNum;
        }
        
        [cardNumTextField setTextChangingBlock:^(CKLimitTextField *textField, NSString *replacement) {
            @strongify(self);
            NSInteger cursor = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.curCursorPosition];
            NSInteger posOffset = 0;
            NSInteger partOffset = cursor % 5;
            // 删除空格后一位
            if (cursor > 0 && partOffset == 0 && replacement.length == 0) {
                posOffset = -1;
            } else if (cursor > 0 && (partOffset == 0) && replacement.length > 0) {
                // 在空格前插入
                posOffset = 1;
            }
            
            if (posOffset != 0) {
                textField.curCursorPosition = [textField positionFromPosition:textField.curCursorPosition offset:posOffset];
            }
            
            NSString *originText = textField.text.length > 0 ? [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] : @"";
            NSInteger maxLength = 19;
            NSString *realText = originText.length > maxLength ? [originText substringToIndex:maxLength] : originText;
            self.cardNum = realText;
            
            if (realText.length == 12) {
                [self getUserInfoBaseOnTextField:textField withCardNumber:realText];
            } else if (realText.length < 12) {
                self.issueBankName = @"";
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            NSString *text = [originText splitByStep:4 replacement:@" "];
            textField.text = text;
        }];
    });
    
    return addCardNumCell;
}

- (CKDict *)setupCardInfoCell
{
    CKDict *cardInfoCell = [CKDict dictWith:@{kCKItemKey: @"cardInfoCell", kCKCellID: @"CardInfoCell"}];
    
    @weakify(self);
    cardInfoCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 60;
    });
    
    cardInfoCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIImageView *logoImageView = (UIImageView *)[cell.contentView viewWithTag:1000];
        UILabel *bankNameLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UIButton *checkButton = (UIButton *)[cell.contentView viewWithTag:1002];
        
        [logoImageView setImageByUrl:self.bankLogoURL withType:ImageURLTypeOrigin defImage:@"cm_shop" errorImage:@"cm_shop"];
        bankNameLabel.text = self.issueBankName;
        
        [RACObserve(self, issueBankName) subscribeNext:^(NSString *string) {
            if (string.length > 0) {
                logoImageView.hidden = NO;
                bankNameLabel.hidden = NO;
                checkButton.hidden = NO;
            } else {
                logoImageView.hidden = YES;
                bankNameLabel.hidden = YES;
                checkButton.hidden = YES;
            }
        }];
        
        @weakify(self);
        [[[checkButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionCheckSupportedBankCard];
        }];
    });
    
    return cardInfoCell;
}

- (CKDict *)setupNextUpCell
{
    CKDict *nextUpCell = [CKDict dictWith:@{kCKItemKey: @"nextUpCell", kCKCellID: @"NextUpCell"}];
    
    @weakify(self);
    nextUpCell[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 50;
    });
    
    nextUpCell[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, __kindof UITableViewCell *cell, NSIndexPath *indexPath) {
        @strongify(self);
        UIButton *nextUpButton = (UIButton *)[cell.contentView viewWithTag:1000];
        
        [[[nextUpButton rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            @strongify(self);
            [self actionToNextSteup];
        }];
    });
    
    return nextUpCell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *item = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = item[kCKCellGetHeight];
    
    if (block) {
        return block(item, indexPath);
    }
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


#pragma mark - Utility

- (void)getUserInfoBaseOnTextField:(UITextField *)textField withCardNumber:(NSString *)cardNumber
{
    GetBankCardBaseInfoOp *op = [GetBankCardBaseInfoOp operation];
    op.cardNo = cardNumber;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismiss];
        self.issueBankName = op.issueBank;
        self.cardType = op.cardType;
        self.bankLogoURL = op.bankLogo;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        textField.enabled = YES;
    } error:^(NSError *error) {
        [gToast dismiss];
        textField.enabled = YES;
    }];
}

- (void)shakeTextFieldCellAtRow:(NSUInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    [cell.contentView shake];
}

- (IBAction)actionDismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (RACSubject *)subject
{
    if (!_subject)
    {
        _subject = [RACSubject subject];
    }
    return _subject;
}

@end
