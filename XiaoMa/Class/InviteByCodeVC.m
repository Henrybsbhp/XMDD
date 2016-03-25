//
//  InviteByCodeVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/3/11.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "InviteByCodeVC.h"
#import "GetGroupPasswordOp.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "GetShareButtonOpV2.h"
#import "SocialShareViewController.h"
#import "InviteAlertVC.h"

@interface InviteByCodeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

//暗号
@property (nonatomic, copy) NSString * cipherForCopy;
//口令
@property (nonatomic, copy) NSString * wordForShare;

@end

@implementation InviteByCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self requestInviteInfo];
    
}

- (void)setupUI;
{
    if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
    {
        self.tableView.estimatedRowHeight = 26; //估算高度
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)requestInviteInfo
{
    GetGroupPasswordOp * op = [GetGroupPasswordOp operation];
    op.req_groupId = self.groupId;
    [[op rac_postRequest] subscribeNext:^(GetGroupPasswordOp * rspOp) {
        
        self.tableView.hidden = NO;
        [self.view stopActivityAnimation];
        
        self.cipherForCopy = rspOp.rsp_groupCipher;
        self.wordForShare = rspOp.rsp_wordForShare;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        @weakify(self);
        [self.view showDefaultEmptyViewWithText:@"获取邀请信息失败，点击重试" tapBlock:^{
            
            @strongify(self);
            [self requestInviteInfo];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            return 44;
        }
        else {
            return 40;
        }
    }
    else if (indexPath.row == 3) {
        return 68;
    }
    else {
        if (IOSVersionGreaterThanOrEqualTo(@"8.0"))
        {
            return UITableViewAutomaticDimension;
        }
        
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        [cell layoutIfNeeded];
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        return ceil(size.height + 9);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        if (indexPath.section == 0) {
            cell = [self codeCellAtIndexPath:indexPath];
        }
        else {
            cell = [self headerCellAtIndexPath:indexPath];
        }
    }
    else if (indexPath.row == 3) {
        cell = [self btnCellAtIndexPath:indexPath];
    }
    else {
        cell = [self contentCellAtIndexPath:indexPath];
    }
    return cell;
}

- (UITableViewCell *)codeCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"CodeCell" forIndexPath:indexPath];
    UILabel *codeLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    UIButton *copyBtn = (UIButton *)[cell.contentView viewWithTag:1002];
    codeLabel.text = [NSString stringWithFormat:@"团队暗号：%@", self.cipherForCopy ?: @""];
    
    [copyBtn setTitle:@"复制暗号" forState:UIControlStateNormal];
    [copyBtn setCornerRadius:5];
    [copyBtn setBorderColor:HEXCOLOR(@"#18d05a")];
    [copyBtn setBorderWidth:1];
    
    [[[copyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.cipherForCopy;
        
        InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
        alertVC.alertType = InviteAlertTypeCopyCode;
        HKAlertActionItem *ok = [HKAlertActionItem itemWithTitle:@"确定" color:HEXCOLOR(@"#18d06a") clickBlock:nil];
        alertVC.actionItems = @[ok];
        [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
            [alertView dismiss];
        }];
    }];
    
    return cell;
}

- (UITableViewCell *)headerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"HeaderCell" forIndexPath:indexPath];
    UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        titleLabel.text = @"如果您的好友已下载小马达达App";
    }
    else {
        titleLabel.text = @"如果您的好友未下载小马达达App";
    }
    return cell;
}

- (UITableViewCell *)btnCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"BtnCell" forIndexPath:indexPath];
    UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        [btn setTitle:@"分享入团口令" forState:UIControlStateNormal];
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            if ([WXApi isWXAppInstalled]) {
                SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                req.text = self.wordForShare;
                req.bText = YES;
                [WXApi sendReq:req];
            }
            else {
                [gToast showText:@"您未安装微信，无法分享口令"];
            }
        }];
    }
    else {
        [btn setTitle:@"邀请好友下载小马达达" forState:UIControlStateNormal];
        [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            [gToast showingWithText:@"分享信息拉取中..."];
            GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
            op.pagePosition = ShareSceneCipher;
            [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
                
                [gToast dismiss];
                SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
                vc.sceneType = ShareSceneCipher;    //页面位置
                vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
                
                MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
                sheet.shouldCenterVertically = YES;
                [sheet presentAnimated:YES completionHandler:nil];
                
                [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                    [MobClick event:@"rp110-7"];
                    [sheet dismissAnimated:YES completionHandler:nil];
                }];
                [vc setClickAction:^{
                    [sheet dismissAnimated:YES completionHandler:nil];
                }];
                
            } error:^(NSError *error) {
                [gToast showError:@"分享信息拉取失败，请重试"];
            }];
        }];
    }
    return cell;
}

/** 
 使字符串内容局部高亮
 
 @param string 需要高亮的文本
 @param
 @param sourceString 完整的源字符串文本
 @param
 @param withPositionTag 1 表示需要高亮的文本在源字符串文本的开头
 @param                 2 表示需要高亮的文本在源字符串文本的中间
 @param                 3 表示需要高亮的文本在源字符串文本的末端
*/
- (NSAttributedString *)attributedStringWithParticularHighlightString:(NSString *)string fromSourceString:(NSString*)sourceString withPositionTag:(NSInteger)integer
{
    
    // 给需要高亮的字符串添加高亮属性。
    UIColor *color = [UIColor colorWithHTMLExpression:@"#18D06A"];
    NSDictionary *attributes = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *hightlightedString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];

    // 需要用来拼接的字符串。
    NSString *headerString;
    NSString *middleString;
    NSString *footerString;
    
    // 以下是分割源字符串为 NSArray 来和高亮文本重新拼接的步骤。
    if ([sourceString containsString:string]) {
        
        NSArray *stringArray = [sourceString componentsSeparatedByString:string];
        
        if (stringArray.count == 0) {
            
            [attributedString appendAttributedString:hightlightedString];
            
            return attributedString;
            
        }
        
        if (stringArray.count == 1) {
            
            // 判断高亮文本在源字符串文本中的位置。
            if (integer == 3) {
                
                headerString = stringArray[0];
                
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:headerString]];
                [attributedString appendAttributedString:hightlightedString];
                
                return attributedString;
                
            }
            
            // 判断高亮文本在源字符串文本中的位置。
            if (integer == 1) {
                
                footerString = stringArray[0];
                
                [attributedString appendAttributedString:hightlightedString];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:footerString]];
                
                return attributedString;
                
            }
        }

        if (stringArray.count == 2) {
            
            // 判断高亮文本在源字符串文本中的位置。
            if (integer == 1) {
                
                footerString = stringArray[1];
                
                [attributedString appendAttributedString:hightlightedString];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:footerString]];
                
                return attributedString;
                
            }
            
            // 判断高亮文本在源字符串文本中的位置。
            if (integer == 2) {
                
                headerString = stringArray[0];
                footerString = stringArray[1];
                
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:headerString]];
                [attributedString appendAttributedString:hightlightedString];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:footerString]];
                
                return attributedString;
                
            }
            
            // 判断高亮文本在源字符串文本中的位置。
            if (integer == 3) {
                
                headerString = stringArray[0];
                middleString = stringArray[1];
                
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:headerString]];
                [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:middleString]];
                [attributedString appendAttributedString:hightlightedString];
                
                return attributedString;
                
            }
        }
    }
    
    return attributedString;
}

- (UITableViewCell *)contentCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1001];
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            contentLabel.text = @"1，您需要通过微信分享入团口令邀请您的好友加入";
        }
        else if (indexPath.row == 2) {
            contentLabel.text = @"2，您的好友复制口令后，打开App即可成功加入您创建的团";
        }
        else {
            contentLabel.attributedText = [self attributedStringWithParticularHighlightString:@"首页→小马互助→自组互助团→申请加入" fromSourceString:@"如果您的好友无法长按复制暗号，可打开小马达达后，通过“首页→小马互助→自组互助团→申请加入”后录入您互助团的暗号同样可成功加入您的互助团 \n " withPositionTag:2];
        }
    }
    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            contentLabel.text = @"1，您需要先邀请您的好友下载小马达达App";
        }
        else {
            contentLabel.text = @"2，受邀好友下载成功后，告知受邀好友入团暗号或分享入团口令邀请对方加入";
        }
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
