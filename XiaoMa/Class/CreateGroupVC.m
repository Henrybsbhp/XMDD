//
//  CreateGroupVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/16/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "CreateGroupVC.h"
#import "CreateGroupOp.h"
#import <QuartzCore/QuartzCore.h>

@interface CreateGroupVC () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) NSString *textFieldString;

@end

@implementation CreateGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}
- (IBAction)confirmButtonDidClick:(id)sender
{
    [self requestCreateGroup:self.textFieldString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestCreateGroup:(NSString *)groupNameToCreate
{
    CreateGroupOp *op = [[CreateGroupOp alloc] init];
    op.req_name = groupNameToCreate;
    
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithoutText];
        
    }] subscribeNext:^(CreateGroupOp *rop) {
        
        [gToast dismiss];
        
    } error:^(NSError *error) {
        
        [gToast showError:error.domain];
        
    }];
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        return 1;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 21;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    } else if (section == 1) {
        return 148;
    }
    
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            return 81;
        } else if (indexPath.row == 1) {
            return 103;
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            return 192;
        }
        
    } else if (indexPath.section == 2) {
        
        if (indexPath.row == 0) {
            return 69;
        }
        
    }
    return 81;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
        
            cell = [self loadBannerCellAtIndexPath:indexPath];
        
        } else if (indexPath.row == 1) {
        
            cell = [self loadGroupNameInputCellAtIndexPath:indexPath];
        
        }
        
    } else if (indexPath.section == 1) {
        
        cell = [self loadTipsCellAtIndexPath:indexPath];
        
    } else if (indexPath.section == 2) {
        
        cell = [self loadConfirmButtonCellAtIndexPath:indexPath];
        
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell" forIndexPath:indexPath];
    
    UILabel *infoLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UIImageView *notesImageView = (UIImageView *)[cell.contentView viewWithTag:102];
    
    notesImageView.image = [UIImage imageNamed:@"mutuallns_createGroup_notes"];
    infoLabel.text = @"立即组团";
    
    cell.backgroundColor = [UIColor colorWithHTMLExpression:@"#18d06a"];
    
    return cell;
}

- (UITableViewCell *)loadGroupNameInputCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupNameInputCell" forIndexPath:indexPath];
    
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:103];
    UITextField *groupTextField = (UITextField *)[cell.contentView viewWithTag:104];
    
    titleLabel.text = @"团队名称";
    
    // 设置 groupTextField 的左边留白
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 19, 20)];
    groupTextField.leftView = paddingView;
    groupTextField.leftViewMode = UITextFieldViewModeAlways;
    
    groupTextField.layer.borderColor = [[UIColor colorWithHTMLExpression:@"#EEEFEF"] CGColor];
    groupTextField.layer.cornerRadius = 1;
    groupTextField.layer.borderWidth = 1;
    groupTextField.layer.masksToBounds = YES;
    [groupTextField.rac_textSignal subscribeNext:^(id x) {
        self.textFieldString = x;
    }];
    
    return cell;
}

- (UITableViewCell *)loadTipsCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TipsCell" forIndexPath:indexPath];
    
    UILabel *tipsTitleLabel = (UILabel *)[cell.contentView viewWithTag:105];
    UIImageView *tipsImageView1 = (UIImageView *)[cell.contentView viewWithTag:106];
    UIImageView *tipsImageView2 = (UIImageView *)[cell.contentView viewWithTag:107];
    UIImageView *tipsImageView3 = (UIImageView *)[cell.contentView viewWithTag:108];
    UILabel *tipsLabel1 = (UILabel *)[cell.contentView viewWithTag:109];
    UILabel *tipsLabel2 = (UILabel *)[cell.contentView viewWithTag:110];
    UILabel *tipsLabel3 = (UILabel *)[cell.contentView viewWithTag:111];
    
    
    tipsImageView1.image = [UIImage imageNamed:@"mutuallns_createGroup_click"];
    tipsImageView2.image = [UIImage imageNamed:@"mutuallns_createGroup_share"];
    tipsImageView3.image = [UIImage imageNamed:@"mutuallns_createGroup_rectangle"];
    
    tipsTitleLabel.text = @"组团提示";
    tipsLabel1.attributedText = [self generateAttributedStringWithLineSpacing:@"输入团队名称后，点击下方 “确定” 即可发起组团并获得入团暗号。"];
    tipsLabel2.text = @"分享暗号可以邀请好友加入。";
    tipsLabel3.attributedText = [self generateAttributedStringWithLineSpacing:@"建团后，您也可以选择完善信息选择购买的小马互助种类后，再去邀请好友入团。"];
    
    
    return cell;
}

- (UITableViewCell *)loadConfirmButtonCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ConfirmButtonCell" forIndexPath:indexPath];
    UIButton *confirmButton = (UIButton *)[cell.contentView viewWithTag:112];
    
    confirmButton.layer.cornerRadius = 5.0f;
    confirmButton.clipsToBounds = YES;
    
    return cell;
}

// 生成带有行高的 NSAttributedString
- (NSAttributedString *)generateAttributedStringWithLineSpacing:(NSString *)string
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = 4.0f;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}


@end
