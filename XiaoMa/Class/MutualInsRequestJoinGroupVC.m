//
//  MutuallnsRequestJoinGroupVC.m
//  XiaoMa
//
//  Created by St.Jimmy on 3/18/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "MutualInsRequestJoinGroupVC.h"

@interface MutualInsRequestJoinGroupVC ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation MutualInsRequestJoinGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
        
    } else if (section == 1) {
        
        return 1;
        
    }
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            return 105;
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            return 241;
            
        }
        
    }
    
    return 90;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 20;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 10;
        
    }
    
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadCipherBannerCellAtIndexPath:indexPath];
            
        }
        
    } else if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            
            cell = [self loadTipsCellAtIndexPath:indexPath];
            
        }
    }
    
    return cell;
}

- (UITableViewCell *)loadCipherBannerCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CipherBannerCell" forIndexPath:indexPath];
    
    UITextField *cipherTextField = (UITextField *)[cell.contentView viewWithTag:101];
    
    [cipherTextField setBorderColor:HEXCOLOR(@"#ECEDED")];
    [cipherTextField setBorderWidth:1];
    [cipherTextField setCornerRadius:1];
    cipherTextField.layer.masksToBounds = YES;
    
    return cell;
}

- (UITableViewCell *)loadTipsCellAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TipsCell" forIndexPath:indexPath];
    
    UILabel *tipsLabel1 = (UILabel *)[cell.contentView viewWithTag:107];
    UILabel *tipsLabel2 = (UILabel *)[cell.contentView viewWithTag:108];
    UILabel *tipsLabel3 = (UILabel *)[cell.contentView viewWithTag:109];
    
    tipsLabel1.text = @"1、您需要输入正确暗号，并确认团队信息。";
    tipsLabel2.text = @"2、确认本团信息后，选择车辆后即可入团。";
    tipsLabel3.attributedText = [self generateAttributedStringWithLineSpacing:@"3、完善资料，填写信息后我们将对您的信息进行审核。"];
    
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
