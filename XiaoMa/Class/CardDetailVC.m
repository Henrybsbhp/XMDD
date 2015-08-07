//
//  CardDetailVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/6.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CardDetailVC.h"

@interface CardDetailVC ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CardDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(cancelBinding)];
    right.tintColor = HEXCOLOR(@"#1bb745");
    right.image = [UIImage imageNamed:@"mb_more"];
    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headView" forIndexPath:indexPath];
//        headerView.textLabel.text = @"让我组成头部!";
//        headerView.textLabel.textAlignment = NSTextAlignmentCenter;
//        headerView.textLabel.textColor = [UIColor whiteColor];
    return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 3;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(110, 130);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 12;
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
    NSArray * remarksStr = @[@"每月2次", @"不限次数", @"不限次数"];
    NSArray * imageStr = @[@"mb_carwash", @"mb_rescue", @"mb_agency"];
    [backgroundView setCornerRadius:5.0f];
    titleLabel.text = titleStr[indexPath.row];
    remarksLabel.text = remarksStr[indexPath.row];
    imageView.image = [UIImage imageNamed:imageStr[indexPath.row]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)cancelBinding
{
    UIActionSheet * sheet = [[UIActionSheet alloc] init];
    NSInteger cancelIndex = 1;
    [sheet addButtonWithTitle:@"解除绑定"];
    [sheet addButtonWithTitle:@"取消"];
    sheet.cancelButtonIndex = cancelIndex;
    
    [sheet showInView:self.view];
    
    [[sheet rac_buttonClickedSignal] subscribeNext:^(NSNumber * index) {
        if ([index integerValue] == 0) {
            
        }
    }];
}

@end
