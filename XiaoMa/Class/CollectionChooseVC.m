//
//  CollectionChooseVC.m
//  XiaoMa
//
//  Created by jt on 15/8/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CollectionChooseVC.h"

@interface CollectionChooseVC()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation CollectionChooseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    DebugLog(@"CollectionChooseVC dealloc");
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupNavigationBar
{
    UIBarButtonItem *back = [UIBarButtonItem backBarButtonItemWithTarget:self action:@selector(actionBack:)];
    self.navigationItem.leftBarButtonItem = back;
}

- (void)actionBack:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - collectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger num = self.datasource.count / 3 + ((self.datasource.count % 3) ? 1 : 0);
    return num;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num;
    NSInteger numOfSections = self.datasource.count / 3 + ((self.datasource.count % 3) ? 1 : 0);
    if (section < numOfSections - 1)
    {
        num = 3;
    }
    else
    {
        num = self.datasource.count % 3 ? self.datasource.count % 3 : 3;
    }
    return num;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = floor((self.view.frame.size.width - 40) / 3.0);
    CGFloat height = width * 3 / 8;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    UIView * view = (UILabel *)[cell searchViewWithTag:101];
    UILabel * titleLabel = (UILabel *)[cell searchViewWithTag:20101];
    
    NSDictionary * d = [self.datasource safetyObjectAtIndex:indexPath.section * 3 + indexPath.row];
    NSString * key = [d.allKeys safetyObjectAtIndex:0];
    NSString * value = [d objectForKey:key];
    titleLabel.text = [NSString stringWithFormat:@"%@%@",key,value];
    view.borderWidth = 0.5f;
    view.borderColor = [UIColor lightGrayColor];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.section * 3 + indexPath.row;
    NSString * t = [self.datasource safetyObjectAtIndex:index];
    if (self.selectAction)
    {
        self.selectAction(t);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end
