//
//  BankCardDetailVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 4/1/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "BankCardDetailVC.h"
#import "UnbundlingVC.h"
#import "JGActionSheet.h"

@interface BankCardDetailVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;

@end

@implementation BankCardDetailVC

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    DebugLog(@"BankCardDetailVC deallocated!");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
        self.tableView.estimatedRowHeight = 26;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 2;
        
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return CGFLOAT_MIN;
        
    }
    
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            return [self heightForRowAutomaticallyAtIndexPath:indexPath];
            
        } else {
            
            if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
                
                return [self heightForRowAutomaticallyAtIndexPath:indexPath];
                
            }
            
            return 83;
            
        }
        
    } else {
        
        if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
            
            return [self heightForRowAutomaticallyAtIndexPath:indexPath];
            
        }
        
        return 83;
        
    }
    
    return 123;
}

- (CGFloat)heightForRowAutomaticallyAtIndexPath:(NSIndexPath *)indexPath;
{

    if (IOSVersionGreaterThanOrEqualTo(@"8.0")) {
            
        return UITableViewAutomaticDimension;
            
    }
    if (indexPath.section == 0 && indexPath.row == 0) {
        return self.view.bounds.size.width * 100 / 300;
    }
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    [cell layoutIfNeeded];
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingExpandedSize];
        
    return ceil(size.height + 1);
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        self.expandedIndexPath = nil;
    } else {
        self.expandedIndexPath = indexPath;
    }
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
        
            cell = [self loadBannerCellAtIndexPath:indexPath];
            
        } else if (indexPath.row == 1) {
            
            cell = [self loadStepCell1AtIndexPath:indexPath];
            
        }

    } else if (indexPath.section == 1) {
        
        cell = [self loadStepCell2AtIndexPath:indexPath];
        
    } else {
        
        cell = [self loadStepCell3AtIndexPath:indexPath];
        
    }
    
    return cell;
}

- (UITableViewCell *)loadBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"BannerCell"];
    
    return cell;
}

- (UITableViewCell *)loadStepCell1AtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StepCell1"];
    
    UIButton *naviButton = (UIButton *)[cell.contentView viewWithTag:100];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        naviButton.selected = YES;
    } else {
        naviButton.selected = NO;
    }
    
    contentLabel.attributedText = [self generateAttributedString:@"• 全年优惠洗车，洗车超便宜！\n• 开卡激活即送 5 张 1 分洗车券，有效期 30 天，自派券日起，一周限用 1 次；\n• 开卡激活次月起每月送 2 张 5 元洗车券，每月 1 日派券，有效期为派券当月。" lineSpacing:8];
    contentLabel.textColor = [UIColor colorWithHTMLExpression:@"#888888"];
    contentLabel.preferredMaxLayoutWidth =  gAppMgr.deviceInfo.screenSize.width - 28;
    contentLabel.numberOfLines = 0;
    return cell;
}

- (UITableViewCell *)loadStepCell2AtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StepCell2"];
    
    UIButton *naviButton = (UIButton *)[cell.contentView viewWithTag:100];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        naviButton.selected = YES;
    } else {
        naviButton.selected = NO;
    }
    
    contentLabel.attributedText = [self generateAttributedString:@"全年免费道路救援服务！\n• 免费拖车服务 3 次（限单程 20 公里内）；\n• 免费换胎服务 3 次（需自带完好自备胎）；\n• 免费泵电服务 3 次。\n\n注：救援服务仅限故障车辆且不受交通管制路段，事故车不在免费救援范围内，高速高架第三方活动限行等交通管制路段不在服务范围内。" lineSpacing:8];
    contentLabel.textColor = [UIColor colorWithHTMLExpression:@"#888888"];
    contentLabel.preferredMaxLayoutWidth =  gAppMgr.deviceInfo.screenSize.width - 28;
    contentLabel.numberOfLines = 0;
    
    return cell;
}

- (UITableViewCell *)loadStepCell3AtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StepCell3"];
    
    UIButton *naviButton = (UIButton *)[cell.contentView viewWithTag:100];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:101];
    
    if ([indexPath compare:self.expandedIndexPath] == NSOrderedSame) {
        naviButton.selected = YES;
    } else {
        naviButton.selected = NO;
    }
    
    contentLabel.attributedText = [self generateAttributedString:@"持卡客户指定车辆享受免费年检协办服务，需提前 3 天预约；\n• 车辆年检前客户需准备以下资料：\n• 机动车行驶证（在签证有效期范围内）\n• 有效机动车保险单证\n• 私车需车主身份证复印件，公车需车主单位有效的委托书（盖公章）\n• 非本地区号牌车辆需开具车辆所属地车管部门委托书\n• 具备其他当地行政主管部门要求必备的条件\n汽车卡发行区域内免服务费，检测站需缴纳的行政收费由客户自行承担；\n从客户车辆的安全性出发，年检时客户须把车开至检测站或小马达达指定地点。" lineSpacing:8];
    contentLabel.textColor = [UIColor colorWithHTMLExpression:@"#888888"];
    contentLabel.preferredMaxLayoutWidth =  gAppMgr.deviceInfo.screenSize.width - 28;
    contentLabel.numberOfLines = 0;
    
    return cell;
}


- (NSAttributedString *)generateAttributedString:(NSString *)string lineSpacing:(CGFloat)lineSpacing
{
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.lineSpacing = lineSpacing;
    
    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:string attributes:@{ NSParagraphStyleAttributeName : style}];
    
    return attrText;
}

- (IBAction)deactiveButtonClicked:(id)sender
{
    [MobClick event:@"rp315_1"];
//    UIActionSheet * sheet = [[UIActionSheet alloc] init];
//    NSInteger cancelIndex = 1;
//    [sheet addButtonWithTitle:@"解除绑定"];
//    [sheet addButtonWithTitle:@"取消"];
//    sheet.cancelButtonIndex = cancelIndex;
//    
//    [sheet showInView:self.view];
    
    JGActionSheetSection *section1 = [JGActionSheetSection sectionWithTitle:nil message:nil buttonTitles:@[@"解除绑定", @"取消"]
                                                                buttonStyle:JGActionSheetButtonStyleDefault];
    [section1 setButtonStyle:JGActionSheetButtonStyleRed forButtonAtIndex:0];
    JGActionSheet *sheet = [JGActionSheet actionSheetWithSections:@[section1]];
    [sheet showInView:self.navigationController.view animated:YES];
    
    [sheet setButtonPressedBlock:^(JGActionSheet *sheet, NSIndexPath *sheetIndexPath) {
        
        [sheet dismissAnimated:YES];
        if (sheetIndexPath.row == 1) {
            [MobClick event:@"rp315_3"];
            return ;
        }
        
        if ([sheetIndexPath integerValue] == 0) {
            [MobClick event:@"rp315_2"];
            UnbundlingVC *vc = [UIStoryboard vcWithId:@"UnbundlingVC" inStoryboard:@"Bank"];
            vc.originVC = self.originVC;
            vc.card = self.card;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else {
            [MobClick event:@"rp315_3"];
        }
    }];
        
    
//    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * index) {
//        if ([index integerValue] == 0) {
//            [MobClick event:@"rp315_2"];
//            UnbundlingVC *vc = [UIStoryboard vcWithId:@"UnbundlingVC" inStoryboard:@"Bank"];
//            vc.originVC = self.originVC;
//            vc.card = self.card;
//            [self.navigationController pushViewController:vc animated:YES];
//            
//        }
//        else {
//            [MobClick event:@"rp315_3"];
//        }
//    }];
}

@end
