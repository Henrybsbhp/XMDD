//
//  GasAddCardVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/10/16.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "GasAddCardVC.h"
#import "GasCard.h"
#import "GasStore.h"
#import "HKTableViewCell.h"
#import "NSString+Split.h"
#import "CKLimitTextField.h"
#import "UIView+Shake.h"
#import "GetGasCardInfoOp.h"

@interface GasAddCardVC ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
///中石化
@property (nonatomic, strong) GasCard *snpnCard;
///中石油
@property (nonatomic, strong) GasCard *cnpcCard;
///当前选择的油卡
@property (nonatomic, weak) GasCard *curCard;

@property (nonatomic, copy) NSString *snpnUsername;

@property (nonatomic, copy) NSString *cnpcUsername;

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, strong) CKLimitTextField *cardNumTextField;

@property (nonatomic) BOOL isLoading;

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

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"GasAddCardVC dealloc ~");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action
- (IBAction)actionSwitch:(UIButton *)sender
{
    if (sender.tag != self.tag) {
        if (self.spinner.animating) {
            self.spinner.hidden = YES;
            CGRect frame = self.cardNumTextField.rightView.frame;
            frame.size.width = 0;
            self.cardNumTextField.rightView.frame = frame;
        }
    } else {
        if (self.spinner.animating) {
            self.spinner.hidden = NO;
            CGRect frame = self.cardNumTextField.rightView.frame;
            frame.size.width = 25;
            self.cardNumTextField.rightView.frame = frame;
        }
    }
    
    
    if (sender.tag == 1001) {
        [MobClick event:@"rp504_1"];
    }
    else {
        [MobClick event:@"rp504_2"];
    }
    self.curCard = sender.tag == 1001 ? self.snpnCard : self.cnpcCard;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (IBAction)actionAddCard:(id)sender
{
    [self.view endEditing:NO];
    
    if (self.curCard.gascardno.length != [self.curCard maxCardNumberLength]) {
        [self shakeTextFieldCellAtRow:1];
        return;
    }
    
    if (self.isLoading) {
        
        [gToast showingWithText:nil];
        
        @weakify(self);
        __block RACDisposable *handler = [RACObserve(self, isLoading) subscribeNext:^(id x) {
            @strongify(self);
            if (!self.isLoading) {
                CKAfter (0.3, ^{
                    [self performSelector:@selector(actionAddCard:) withObject:nil];
                    [handler dispose];
                });
            }
        }];
        
    } else {
    
        NSMutableAttributedString *alertMessage;
        NSMutableParagraphStyle *ps = [[NSMutableParagraphStyle alloc] init];
        ps.lineSpacing = 5;
        ps.alignment = NSTextAlignmentCenter;
        
        if (self.curCard.cardtype == 1) {
            NSString *splitedCardNumber = [self.curCard.gascardno splitByStep:4 replacement:@" "];
            if (self.snpnUsername.length > 0) {
                alertMessage = [[NSMutableAttributedString alloc] initWithString:@"请核对如下信息并确认\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:kGrayTextColor, NSParagraphStyleAttributeName: ps}];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"油卡持卡人姓名：%@\n加油卡号\n%@", self.snpnUsername, splitedCardNumber] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:HEXCOLOR(@"#000000"), NSParagraphStyleAttributeName: ps}];
                [alertMessage appendAttributedString:nameString];
            } else {
                alertMessage = [[NSMutableAttributedString alloc] initWithString:@"请核对如下信息并确认\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:kGrayTextColor, NSParagraphStyleAttributeName: ps}];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"油卡卡号\n%@", splitedCardNumber] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:HEXCOLOR(@"#000000"), NSParagraphStyleAttributeName: ps}];
                [alertMessage appendAttributedString:nameString];
            }
        } else {
            NSString *splitedCardNumber = [self.curCard.gascardno splitByStep:4 replacement:@" "];
            if (self.cnpcUsername.length > 0) {
                alertMessage = [[NSMutableAttributedString alloc] initWithString:@"请核对如下信息并确认\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:kGrayTextColor, NSParagraphStyleAttributeName: ps}];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"油卡持卡人姓名：%@\n加油卡号\n%@", self.cnpcUsername, splitedCardNumber] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:HEXCOLOR(@"#000000"), NSParagraphStyleAttributeName: ps}];
                [alertMessage appendAttributedString:nameString];
            } else {
                alertMessage = [[NSMutableAttributedString alloc] initWithString:@"请核对如下信息并确认\n" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:kGrayTextColor, NSParagraphStyleAttributeName: ps}];
                NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"油卡卡号\n%@", splitedCardNumber] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16], NSForegroundColorAttributeName:HEXCOLOR(@"#000000"), NSParagraphStyleAttributeName: ps}];
                [alertMessage appendAttributedString:nameString];
            }
        }
        
        HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"返回" color:kGrayTextColor clickBlock:nil];
        
        HKAlertActionItem *confirm = [HKAlertActionItem itemWithTitle:@"确认无误" color:HEXCOLOR(@"#F39C12") clickBlock:^(id alertVC) {
            [MobClick event:@"rp504_5"];
            
            //    if (![self.curCard.gascardno isEqual:self.curCard.customObject]) {
            //        [self shakeTextFieldCellAtRow:2];
            //        return;
            //    }
            
            GasStore *store = [GasStore fetchOrCreateStore];
            
            @weakify(self);
            [[[[store addGasCard:self.curCard] sendAndIgnoreError] initially:^{
                
                [gToast showingWithText:@"正在添加..."];
            }] subscribeNext:^(id x) {
                
                @strongify(self);
                [gToast dismiss];
                [self.navigationController popViewControllerAnimated:YES];
            } error:^(NSError *error) {
                
                [gToast showError:error.domain];
            }];
        }];
        
        HKImageAlertVC *alert = [HKImageAlertVC alertWithTopTitle:@"温馨提示" ImageName:@"mins_bulb" attributedMessage:alertMessage ActionItems:@[cancel, confirm]];
        [alert show];
    }
}
#pragma mark - UITableView datasource and delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 184;
    } else if (indexPath.row == 1) {
        return 44;
    } else if ((self.curCard.cardtype == 1 && self.snpnUsername.length > 0) || (self.curCard.cardtype == 2 && self.cnpcUsername.length > 0)) {
        return 44;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [self brandCellAtIndexPath:indexPath];
    } else if (indexPath.row == 1) {
        return [self cardCellAtIndexPath:indexPath];
    }
    return [self usernameCellAtIndexPath:indexPath];
}

- (UITableViewCell *)brandCellAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BrandCell" forIndexPath:indexPath];
    UIButton *iconBtn1 = (UIButton *)[cell.contentView viewWithTag:1001];
    UIButton *iconBtn2 = (UIButton *)[cell.contentView viewWithTag:1002];
    UIImageView *checkedV1 = (UIImageView *)[cell.contentView viewWithTag:1003];
    UIImageView *checkedV2 = (UIImageView *)[cell.contentView viewWithTag:1004];
    
    iconBtn1.layer.borderWidth = 1;
    iconBtn1.layer.cornerRadius = 5;
    iconBtn1.layer.masksToBounds = YES;
    iconBtn2.layer.borderWidth = 1;
    iconBtn2.layer.cornerRadius = 5;
    iconBtn2.layer.masksToBounds = YES;
    [[RACObserve(self, curCard) takeUntilForCell:cell] subscribeNext:^(GasCard *card) {
        if (card.cardtype == 2) {
            iconBtn1.borderColor = HEXCOLOR(@"#dddddd");
            iconBtn2.borderColor = kDefTintColor;
            checkedV1.hidden = YES;
            checkedV2.hidden = NO;
        } else {
            iconBtn2.borderColor = HEXCOLOR(@"#dddddd");
            iconBtn1.borderColor = kDefTintColor;
            checkedV2.hidden = YES;
            checkedV1.hidden = NO;
        }
    }];
    [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 16, 0, 0)];
    return cell;
}

- (UITableViewCell *)cardCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CardCell" forIndexPath:indexPath];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1001];
    CKLimitTextField *field = (CKLimitTextField *)[cell.contentView viewWithTag:1002];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell.contentView viewWithTag:1003];
    self.spinner = spinner;
    self.cardNumTextField = field;
    
    titleL.text = indexPath.row == 1 ? @"加油卡号" : @"确认卡号";
    
    @weakify(self);
    [[RACObserve(self, curCard) distinctUntilChanged] subscribeNext:^(GasCard *card) {
        @strongify(self);
        field.placeholder = card.cardtype == 1 ? @"请输入19位加油卡号" : @"请输入16位加油卡号";
        field.textLimit = card.cardtype == 1 ? 23 : 19;
        if (indexPath.row == 1) {
            field.text = [card.gascardno splitByStep:4 replacement:@" "];
        } else {
            field.text = [card.customObject splitByStep:4 replacement:@" "];
        }
        [field setDidBeginEditingBlock:^(CKLimitTextField *textField) {
            if (indexPath.row == 1) {
                [MobClick event:@"rp504_3"];
            } else {
                [MobClick event:@"rp504_4"];
            }
            
        }];
        
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
            
            if (orgText.length == maxLen) {
                [textField resignFirstResponder];
                [self textField:textField getUserInfoWithCardType:card.cardtype gasCard:realText spinner:spinner];
            } else {
                
                if (card.cardtype == 1) {
                    self.snpnUsername = @"";
                } else {
                    self.cnpcUsername = @"";
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
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
    
    return cell;
}

- (UITableViewCell *)usernameCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UsernameCell" forIndexPath:indexPath];
    UILabel *usernameLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if (self.curCard.cardtype == 1 && self.snpnUsername.length > 0) {
        usernameLabel.text = self.snpnUsername;
        usernameLabel.textColor = HEXCOLOR(@"#000000");
    } else if (self.curCard.cardtype == 1 && self.snpnUsername.length < 1) {
        usernameLabel.text = @"无匹配用户";
        usernameLabel.textColor = HEXCOLOR(@"#FB0000");
    }
    
    if (self.curCard.cardtype == 2 && self.cnpcUsername.length > 0) {
        usernameLabel.text = self.cnpcUsername;
        usernameLabel.textColor = HEXCOLOR(@"#000000");
    } else if (self.curCard.cardtype == 2 && self.cnpcUsername.length < 1) {
        usernameLabel.text = @"无匹配用户";
        usernameLabel.textColor = HEXCOLOR(@"#FB0000");
    }
    
    return cell;
}

#pragma mark - 获取用户名称
- (void)textField:(UITextField *)textField getUserInfoWithCardType:(NSUInteger)cardType gasCard:(NSString *)gasCard spinner:(UIActivityIndicatorView *)spinner
{
    GetGasCardInfoOp *op = [[GetGasCardInfoOp alloc] init];
    op.gasCard = gasCard;
    op.cardType = @(cardType);
    
    @weakify(self);
    [[[op rac_postRequest] initially:^{
        [spinner startAnimating];
        self.isLoading = YES;
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
        [textField addSubview:paddingView];
        textField.rightView = paddingView;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.enabled = NO;
        
        if (cardType == 1) {
            self.snpnUsername = @"";
            self.tag = 1001;
        } else {
            self.cnpcUsername = @"";
            self.tag = 1002;
        }
        
    }] subscribeNext:^(GetGasCardInfoOp *rop) {
        @strongify(self);
        [gToast dismiss];
        textField.rightView = nil;
        [spinner stopAnimating];
        self.isLoading = NO;
        if (cardType == 1) {
            self.snpnUsername = rop.username;
        } else {
            self.cnpcUsername = rop.username;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        textField.enabled = YES;
    } error:^(NSError *error) {
        [gToast dismiss];
        textField.rightView = nil;
        [spinner stopAnimating];
        self.isLoading = NO;
        textField.enabled = YES;
    }];
}

#pragma mark - Utility
- (void)shakeTextFieldCellAtRow:(NSUInteger)row
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    UIView *container = [cell.contentView viewWithTag:100];
    [container shake];
}
@end
