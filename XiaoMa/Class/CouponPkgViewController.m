//
//  CouponPkgViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-23.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CouponPkgViewController.h"
#import "GetUserCouponPkgOp.h"
#import "HKCouponPkg.h"
#import "GainCouponPkgOp.h"

@interface CouponPkgViewController ()

@property (weak, nonatomic) IBOutlet JTTableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *textFeildView;
@property (weak, nonatomic) IBOutlet UITextField *pkgCodeTxtFeild;
@property (weak, nonatomic) IBOutlet UIButton *receiveBtn;

@property (nonatomic,strong)NSArray * pkgArray;

@end

@implementation CouponPkgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestGetPkgs];
    [self setupUI];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc
{
    DebugLog(@"CouponPkgViewController dealloc");
}

#pragma mark - SetupUI
- (void)setupUI
{
    self.textFeildView.borderWidth = 1.0f;
    self.textFeildView.borderColor = [UIColor colorWithHex:@"#DFDFDF" alpha:1.0f];
    self.textFeildView.layer.masksToBounds = YES;
    self.pkgCodeTxtFeild.placeholder = @"输入礼包兑换码，领取礼包";
    
    @weakify(self)
    [[self.receiveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        @strongify(self)
        if (self.pkgCodeTxtFeild.text.length)
        {
            [self requestGainPkg];
        }
    }];
}

#pragma mark - Utilitly
- (void)requestGetPkgs
{
    GetUserCouponPkgOp * op = [GetUserCouponPkgOp operation];
    [[[op rac_postRequest] initially:^{
        
    }] subscribeNext:^(GetUserCouponPkgOp * op) {
        
        self.pkgArray = op.rsp_pkgArray;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        
    }];
}

- (void)requestGainPkg
{
    GainCouponPkgOp * op = [GainCouponPkgOp operation];
    op.pkgCode = self.pkgCodeTxtFeild.text;
    [[[op rac_postRequest] initially:^{
        
        [gToast showText:@"获取中..."];
    }] subscribeNext:^(id x) {
        
        [gToast showSuccess:@"获取成功"];
        [self requestGetPkgs];
    } error:^(NSError *error) {
        
        [gToast showSuccess:@"获取失败"];
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.pkgArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    HKCouponPkg * pkg = [self.pkgArray safetyObjectAtIndex:section];
    NSInteger num = pkg.couponsArray.count + 2;
    return num;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCouponPkg * pkg = [self.pkgArray safetyObjectAtIndex:indexPath.section];
    NSInteger num = pkg.couponsArray.count + 2;
    if (indexPath.row == 0)
    {
        return 13;
    }
    else if (indexPath.row == num - 1)
    {
        return 44;
    }
    else
    {
        if (pkg.couponsArray.count > 2)
        {
            return 25;
        }
        else
        {
            return 40;
        }
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKCouponPkg * pkg = [self.pkgArray safetyObjectAtIndex:indexPath.section];
    NSInteger num = pkg.couponsArray.count + 2;
    if (indexPath.row == 0)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PgkHeaderCell" forIndexPath:indexPath];
        UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:101];
        UIImage * image = [UIImage imageNamed:@"pkg_cell_header"];
        UIImage * processedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(11, 12, 1, 12)];
        imageView.image = processedImage;
        return cell;
    }
    else if (indexPath.row == num - 1)
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PgkBottomCell" forIndexPath:indexPath];
        UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:101];
        UIImage * image = [UIImage imageNamed:@"pkg_cell_bg"];
        imageView.image = image;
        if ([NSStringFromClass([cell.contentView.superview class]) isEqualToString:@"UITableViewCellScrollView"])
        {
            cell.contentView.superview.clipsToBounds = NO;
        }
        UILabel * title = (UILabel *)[cell searchViewWithTag:102];
        title.text = pkg.pkgName;
        return cell;

    }
    else
    {
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"PgkMiddleCell" forIndexPath:indexPath];
        UIImageView * imageView = (UIImageView *)[cell searchViewWithTag:101];
        UIImage * image = [UIImage imageNamed:@"pkg_cell"];
        UIImage * processedImage = [image resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
        imageView.image = processedImage;
        
        UILabel * title = (UILabel *)[cell searchViewWithTag:102];
        UILabel * content = (UILabel *)[cell searchViewWithTag:103];

        NSDictionary * dict = [pkg.couponsArray safetyObjectAtIndex:indexPath.row - 1];
        
        title.text = dict[@"couponname"];
        content.text = [NSString stringWithFormat:@"可用%@次",dict[@"leftamount"]] ;
        [cell.contentView bringSubviewToFront:title];
        [cell.contentView bringSubviewToFront:content];

        return cell;
    }
}

@end
