//
//  MutualInsAcceptCompensationVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 6/2/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsAcceptCompensationVC.h"
#import "NSString+RectSize.h"
#import "CKLimitTextField.h"
#import "NSString+Split.h"
#import "ConfirmClaimOp.h"

@interface MutualInsAcceptCompensationVC () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, copy) NSString *bankCardNumber;

@property (nonatomic, strong) CKLimitTextField *bankCardTextField;

@end

@implementation MutualInsAcceptCompensationVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"MutualInsAccecptCompensationVC deallocated");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.descriptionLabel.attributedText = [self generateAttributedStringWithLineSpacing:self.descriptionString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)confirmButtonClicked:(id)sender
{
    if (self.bankCardTextField.text.length < 1) {
        [gToast showMistake:@"请输入借记卡卡号"];
    } else {
        if ([self.bankCardTextField.text rangeOfString:@"*"].location != NSNotFound) {
            DebugLog(@"TH CARD NUMBER IS: %@", self.fetchedBankCardNumber);
            [self confirmClaimWithAgreement:@(2) andBankNo:self.fetchedBankCardNumber];
        } else {
            NSString *bankNumber = [self.bankCardTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
            DebugLog(@"TH CARD NUMBER IS: %@", bankNumber);
            [self confirmClaimWithAgreement:@(2) andBankNo:bankNumber];
        }
    }
}

-(void)confirmClaimWithAgreement:(NSNumber *)agreement andBankNo:(NSString *)bankcardNo
{
    ConfirmClaimOp *op = [[ConfirmClaimOp alloc]init];
    op.req_claimid = self.claimID;
    op.req_agreement = agreement;
    op.req_bankcardno = bankcardNo;
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        @strongify(self);
        [gToast showingWithText:@"" inView:self.view];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [gToast dismissInView:self.view];
        
        [self postCustomNotificationName:kNotifyUpdateClaimList object:nil];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } error:^(NSError *error) {
        @strongify(self);
        [gToast showError:error.domain inView:self.view];
    }];
}

#pragma mark - Utilities
/// 生成带有行高的 NSAttributedString
- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 4.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}

- (NSString *)convertAccount:(NSString *)account
{
    if (account.length > 7)
    {
        NSString *temp1 = [account substringWithRange:NSMakeRange(0, 4)];
        NSString *temp2 = [account substringWithRange:NSMakeRange(account.length - 4, 4)];
        
        NSMutableString *ciphertext = [[NSMutableString alloc] init];
        [ciphertext appendString:temp1];
        
        for (NSInteger i = 4 ; i < account.length - 4 ; i ++ )
        {
            [ciphertext appendString:@"*"];
        }
        [ciphertext appendString:temp2];
        
        NSString * text = [ciphertext splitByStep:4 replacement:@" "];
        
        return text;
    }
    return account;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.row == 0) {
        cell = [self loadUsernameCellAtIndexPath:indexPath];
    } else {
        cell = [self loadBankCardCellAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UITableViewCell *)loadUsernameCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"UsernameCell"];
    
    UILabel *usernameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    usernameLabel.text = self.usernameString;
    
    return cell;
}

- (UITableViewCell *)loadBankCardCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [self.tableView dequeueReusableCellWithIdentifier:@"BankCardCell"];
    
    CKLimitTextField *bankCardTextField = (CKLimitTextField *)[cell.contentView viewWithTag:100];
    self.bankCardTextField = bankCardTextField;
    
    @weakify(self);
    [bankCardTextField setTextChangingBlock:^(CKLimitTextField *textField, NSString *replacement) {
        @strongify(self);
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
        NSString *text = [orgText splitByStep:4 replacement:@" "];
        
        //            当时可编辑状态，又是星号显示的时候，删一下，输入框内容，清空
        if (replacement.length == 0 && [textField.text rangeOfString:@"*"].location != NSNotFound)
        {
            text = @"";
        }
        
        
        textField.text = text;
        
        self.bankCardNumber = text;
    }];
    
    bankCardTextField.text = self.bankCardNumber.length ? self.bankCardNumber : [self convertAccount:self.fetchedBankCardNumber];
    
    return cell;
}

@end
