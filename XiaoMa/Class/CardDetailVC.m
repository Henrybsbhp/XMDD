//
//  CardDetailVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CardDetailVC.h"
#import "UnbundlingVC.h"
#import "DetailsAlertVC.h"

@interface CardDetailVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
- (IBAction)cancelBinding:(id)sender;

@end

@implementation CardDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [MobClick beginLogPageView:@"rp315"];
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [MobClick endLogPageView:@"rp315"];
    [super viewWillDisappear:animated];
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headView" forIndexPath:indexPath];
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    return CGSizeMake(floor((self.view.frame.size.width - 40) / 3.0), (self.view.frame.size.width - 40) / 3 + 20);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    UIView * backgroundView = (UIView *)[cell.contentView viewWithTag:1001];
    UILabel * titleLabel = (UILabel *)[cell.contentView viewWithTag:1002];
    UILabel * remarksLabel = (UILabel *)[cell.contentView viewWithTag:1003];
    UIImageView * imageView = (UIImageView *)[cell.contentView viewWithTag:1004];
    
    //模拟数据
    NSArray * titleStr = @[@"全年5元洗车", @"免费道路救援", @"免费年检代办"];
    NSArray * remarksStr = @[@"每月2次", @"出行无忧", @"年检无忧"];
    NSArray * imageStr = @[@"mb_carwash", @"mb_rescue", @"mb_agency"];
    [backgroundView setCornerRadius:5.0f];
    titleLabel.text = titleStr[indexPath.row];
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    remarksLabel.text = remarksStr[indexPath.row];
    imageView.image = [UIImage imageNamed:imageStr[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [DetailsAlertVC showInTargetVC:self withType:indexPath.row];
}

- (IBAction)cancelBinding:(id)sender {
    [MobClick event:@"rp315-1"];
    UIActionSheet * sheet = [[UIActionSheet alloc] init];
    NSInteger cancelIndex = 1;
    [sheet addButtonWithTitle:@"解除绑定"];
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = cancelIndex;
    
    [sheet showInView:self.view];
    
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * index) {
        if ([index integerValue] == 0) {
            [MobClick event:@"rp315-2"];
            UnbundlingVC *vc = [UIStoryboard vcWithId:@"UnbundlingVC" inStoryboard:@"Bank"];
            vc.originVC = self.originVC;
            vc.card = self.card;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        else {
            [MobClick event:@"rp315-3"];
        }
    }];
}
@end
