//
//  ChooseBankVC.m
//  XiaoMa
//
//  Created by RockyYe on 16/3/18.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsChooseBankVC.h"

@interface MutualInsChooseBankVC ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation MutualInsChooseBankVC

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView.refreshView addTarget:self action:@selector(reloadData) forControlEvents:UIControlEventValueChanged];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.bankName)
    {
        self.bankName([self.datasource safetyObjectAtIndex:indexPath.row]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LabelCell" forIndexPath:indexPath];
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:1001];
    label.text = [self.datasource safetyObjectAtIndex:indexPath.row];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = (self.view.bounds.size.width - 45 ) / 2;
    CGFloat height = 60;
    return CGSizeMake(width, height);
}

#pragma mark Network

-(void)reloadData
{
    //    @写op 请求数据
}

#pragma mark LazyLoad

-(NSArray *)datasource
{
    if (!_datasource)
    {
//        _datasource = [[NSArray alloc]init];
        _datasource = @[@"中国建设银行",@"中国工商银行",@"中国银行",@"中国农业银行",@"中信实业银行",@"交通银行",@"杭州银行",@"华夏银行",@"中国民生银行",@"民泰银行"];
    }
    return _datasource;
}

@end
