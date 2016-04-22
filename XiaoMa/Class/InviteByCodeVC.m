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
#import "MutualInsHomeVC.h"
#import "MutualInsStore.h"
#import "NSString+RectSize.h"

@interface InviteByCodeVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) CKList *datasource;
//暗号
@property (nonatomic, copy) NSString * cipherForCopy;
//口令
@property (nonatomic, copy) NSString * wordForShare;
//类型
@property (nonatomic, assign) GroupType groupType;

@end

@implementation InviteByCodeVC

- (void)dealloc
{
    DebugLog(@"InviteByCodeVC dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self requestInviteInfo];
    
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

#pragma mark - Utilitly
- (void)actionBack:(id)sender
{
    if (self.originVC)
    {
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)requestInviteInfo
{
    GetGroupPasswordOp * op = [GetGroupPasswordOp operation];
    op.req_groupId = self.groupId;
    @weakify(self);
    [[op rac_postRequest] subscribeNext:^(GetGroupPasswordOp * rspOp) {
        
        @strongify(self);
        self.tableView.hidden = NO;
        [self.view stopActivityAnimation];
        
        self.cipherForCopy = rspOp.rsp_groupCipher;
        self.wordForShare = rspOp.rsp_wordForShare;
        self.groupType = rspOp.rsp_groupType;
        
        [self setDataSource];
        
    } error:^(NSError *error) {
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view stopActivityAnimation];
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取邀请信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [self requestInviteInfo];
        }];
    }];
}

- (void)setDataSource
{
    self.datasource = [CKList list];
    
    CKDict *cipherForCopy = [self setCipherCell];
    [self.datasource addObject:$(cipherForCopy) forKey:@"copyCipherSection"];
    
    //已下载
    NSString * tipOneShareString = @"1，您需要通过微信分享入团口令邀请您的好友加入";
    NSString * tipTwoShareString = @"2，您的好友复制口令后，打开App即可成功加入您创建的团";
    
    CKDict *titleForAlreadyDownLoad = [self setTitleCellForSectionIndex:1];
    CKDict *contentTipOne = [self setNormalContentCell:tipOneShareString];
    CKDict *contentTipTwo = [self setNormalContentCell:tipTwoShareString];
    CKDict *shareButton = [self setButtonCellForSectionIndex:1];
    CKDict *contentTipFooter = [self setAttributedContentCell];
    
    [self.datasource addObject:$(titleForAlreadyDownLoad, contentTipOne, contentTipTwo, shareButton, contentTipFooter) forKey:@"shareCodeSection"];
    
    //未下载
    NSString * tipOneInviteString = @"1，您需要先邀请您的好友下载小马达达App";
    NSString * tipTwoInviteString = @"2，受邀好友下载成功后，告知受邀好友入团暗号或分享入团口令邀请对方加入\n";
    
    CKDict *titleForNoDownLoad = [self setTitleCellForSectionIndex:2];
    CKDict *inviteContentTipOne = [self setNormalContentCell:tipOneInviteString];
    CKDict *inviteContentTipTwo = [self setNormalContentCell:tipTwoInviteString];
    CKDict *inviteButton = [self setButtonCellForSectionIndex:2];
    [self.datasource addObject:$(titleForNoDownLoad, inviteContentTipOne, inviteContentTipTwo, inviteButton) forKey:@"inviteSection"];
    
    [self.tableView reloadData];
}

- (CKDict *)setCipherCell {
    //初始化身份标识
    CKDict * cipherDict = [CKDict dictWith:@{kCKCellID:@"CodeCell"}];
    //cell行高
    cipherDict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 44;
    });
    //cell准备重绘
    cipherDict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *codeLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        UIButton *copyBtn = (UIButton *)[cell.contentView viewWithTag:1002];
        codeLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 34;
        codeLabel.text = [NSString stringWithFormat:@"团队暗号：%@", self.cipherForCopy ?: @""];
        
        [copyBtn setTitle:@"复制暗号" forState:UIControlStateNormal];
        [copyBtn setCornerRadius:5];
        [copyBtn setBorderColor:HEXCOLOR(@"#18d05a")];
        [copyBtn setBorderWidth:1];
        
        @weakify(self);
        [[[copyBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
            
            @strongify(self);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.cipherForCopy;
            
            InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
            alertVC.alertType = InviteAlertTypeCopyCode;
            HKAlertActionItem *ok = [HKAlertActionItem itemWithTitle:@"确定" color:kDefTintColor clickBlock:nil];
            alertVC.actionItems = @[ok];
            [alertVC show];
        }];
    });
    return cipherDict;
}

- (CKDict *)setTitleCellForSectionIndex:(NSInteger)sectionIndex {
    //初始化身份标识
    CKDict * titleDict = [CKDict dictWith:@{kCKCellID:@"HeaderCell"}];
    //cell行高
    titleDict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 40;
    });
    //cell准备重绘
    titleDict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        titleLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 34;
        
        if (sectionIndex == 1) {
            titleLabel.text = @"如果您的好友已下载小马达达App";
        }
        else {
            titleLabel.text = @"如果您的好友未下载小马达达App";
        }
    });
    return titleDict;
}

- (CKDict *)setNormalContentCell:(NSString *)contentString {
    //初始化身份标识
    CKDict * titleDict = [CKDict dictWith:@{kCKCellID:@"ContentCell"}];
    //cell行高
    @weakify(self);
    titleDict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        @strongify(self);
        CGFloat height = [contentString labelSizeWithWidth:(self.tableView.frame.size.width - 30) font:[UIFont systemFontOfSize:14]].height;
        return height + 8;
    });
    //cell准备重绘
    titleDict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        contentLabel.preferredMaxLayoutWidth = gAppMgr.deviceInfo.screenSize.width - 30;
        contentLabel.text = contentString;
    });
    return titleDict;
}

- (CKDict *)setButtonCellForSectionIndex:(NSInteger)sectionIndex {
    //初始化身份标识
    CKDict * buttonDict = [CKDict dictWith:@{kCKCellID:@"BtnCell"}];
    //cell行高
    buttonDict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        return 68;
    });
    //cell准备重绘
    buttonDict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1001];
        if (sectionIndex == 1) {
            [btn setTitle:@"分享入团口令" forState:UIControlStateNormal];
            @weakify(self);
            [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(self);
                [gAppDelegate.pasteboardoModel prepareForShareWhisper:self.wordForShare];
                [self shareCodeAction];
            }];
        }
        else {
            [btn setTitle:@"邀请好友下载小马达达" forState:UIControlStateNormal];
            @weakify(self);
            [[[btn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:[cell rac_prepareForReuseSignal]] subscribeNext:^(id x) {
                
                @strongify(self);
                [gToast showingWithText:@"分享信息拉取中..."];
                [self inviteAction];
            }];
        }
    });
    return buttonDict;
}

- (void)shareCodeAction {
    InviteAlertVC * alertVC = [[InviteAlertVC alloc] init];
    alertVC.alertType = InviteAlertTypeGotoWechat;
    alertVC.contentStr = self.wordForShare;
    HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"取消" color:kGrayTextColor clickBlock:nil];
    HKAlertActionItem *goWechat = [HKAlertActionItem itemWithTitle:@"去微信粘贴" color:kDefTintColor clickBlock:nil];
    alertVC.actionItems = @[cancel, goWechat];
    [alertVC showWithActionHandler:^(NSInteger index, HKAlertVC *alertView) {
        if (index == 1) {
            if ([WXApi isWXAppInstalled]) {
                [WXApi openWXApp];
            }
            else {
                [gToast showText:@"您未安装微信，无法分享口令"];
            }
        }
    }];
}

- (void)inviteAction {
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
}

- (CKDict *)setAttributedContentCell {
    //初始化身份标识
    CKDict * attributedContentDict = [CKDict dictWith:@{kCKCellID:@"ContentCell"}];
    NSString * attributedFooterString = [NSString new];
    if (self.groupType != GroupTypeByself) {
        attributedFooterString = @"如果您的好友无法长按复制暗号，可打开小马达达后，通过“首页→小马互助→右上角+号→内测计划→申请入团”后录入您互助团的暗号同样可成功加入您的互助团 \n ";
    }
    else {
        attributedFooterString = @"如果您的好友无法长按复制暗号，可打开小马达达后，通过“首页→小马互助→去参团→选择团→申请加入”后录入您互助团的暗号同样可成功加入您的互助团 \n ";
    }
    //cell行高
    attributedContentDict[kCKCellGetHeight] = CKCellGetHeight(^CGFloat(CKDict *data, NSIndexPath *indexPath) {
        CGFloat height = [attributedFooterString labelSizeWithWidth:(self.tableView.frame.size.width - 30) font:[UIFont systemFontOfSize:13]].height;
        return height + 8;
    });
    //cell准备重绘
    @weakify(self);
    attributedContentDict[kCKCellPrepare] = CKCellPrepare(^(CKDict *data, UITableViewCell *cell, NSIndexPath *indexPath) {
        
        @strongify(self);
        UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:1001];
        NSString * highLightString = [NSString new];
        if (self.groupType != GroupTypeByself) {
            highLightString = @"首页→小马互助→右上角+号→内测计划→申请入团";
        }
        else {
            highLightString = @"首页→小马互助→去参团→选择团→申请加入";
        }
        contentLabel.attributedText = [self attributedStringWithParticularHighlightString:highLightString fromSourceString:attributedFooterString withPositionTag:2];
    });
    return attributedContentDict;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.datasource objectAtIndex:section] count];
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
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    CKCellGetHeightBlock block = data[kCKCellGetHeight];
    if (block) {
        return block(data,indexPath);
    }
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKDict *data = self.datasource[indexPath.section][indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:data[kCKCellID] forIndexPath:indexPath];
    CKCellPrepareBlock block = data[kCKCellPrepare];
    if (block) {
        block(data, cell, indexPath);
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
    if ([sourceString rangeOfString:string].location != NSNotFound) {
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
