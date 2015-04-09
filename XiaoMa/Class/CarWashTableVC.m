//
//  CarWashTableVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarWashTableVC.h"
#import <Masonry.h>
#import "XiaoMa.h"
#import "JTRatingView.h"
#import "SYPaginator.h"
#import "UIView+Layer.h"
#import "ShopDetailVC.h"

@interface CarWashTableVC ()<SYPaginatorViewDataSource, SYPaginatorViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (nonatomic, strong) SYPaginatorView *adView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation CarWashTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSearchView];
    [self setupADView];
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSearchView
{
    UIImage *bg = [UIImage imageNamed:@"nb_search_bg"];
    bg = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    self.searchField.background = bg;
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imgV.image = [UIImage imageNamed:@"nb_search"];
    imgV.contentMode = UIViewContentModeCenter;
    self.searchField.leftView = imgV;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)setupADView
{
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 360.0f/1242.0f*width;
    SYPaginatorView *adView = [[SYPaginatorView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    adView.delegate = self;
    adView.dataSource = self;
    adView.pageGapWidth = 0;
    [self.headerView addSubview:adView];
    self.adView = adView;
    [adView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerView);
        make.right.equalTo(self.headerView);
        make.top.equalTo(self.searchView.mas_bottom);
        make.height.mas_equalTo(height);
    }];
    self.adView.currentPageIndex = 0;
    
    CGRect rect = self.headerView.frame;
    rect.size.height += height;
    self.headerView.frame = rect;
}

- (void)reloadDatasource
{
    self.datasource = @[@{@"title":@"神州洗车",@"logo":@"tmp_ad",@"rating":@4.0,@"addr":@"西湖区黄龙路1号沃尔玛超市二楼",
                          @"distance":@0.77,@"integral":@10000,@"oldPrice":@35,@"newPrice":@20},
                        @{@"title":@"兴旺洗车冲洗店",@"logo":@"tmp_ad1",@"rating":@3.0,@"addr":@"河东路23号河东社区附近",
                          @"distance":@0.98,@"integral":@20000,@"oldPrice":@35,@"newPrice":@20},
                        @{@"title":@"小小洗车",@"logo":@"tmp_ad",@"rating":@3.0,@"addr":@"文三路232",
                          @"distance":@0.98,@"integral":@15000,@"oldPrice":@30,@"newPrice":@15},
                        @{@"title":@"同福汽车美容",@"logo":@"tmp_ad1",@"rating":@3.0,@"addr":@"上塘路绍兴路口",
                          @"distance":@0.98,@"integral":@10000,@"oldPrice":@40,@"newPrice":@23},
                        @{@"title":@"洛门洗车装潢",@"logo":@"tmp_ad",@"rating":@3.0,@"addr":@"文一路物美超市附近",
                          @"distance":@0.98,@"integral":@10000,@"oldPrice":@20,@"newPrice":@15}];
    [self.tableView reloadData];
}
#pragma mark - Action
- (IBAction)actionMap:(id)sender
{
    
}


#pragma mark - SYPaginatorViewDelegate
- (NSInteger)numberOfPagesForPaginatorView:(SYPaginatorView *)paginatorView
{
    return 3;
}

- (SYPageView *)paginatorView:(SYPaginatorView *)paginatorView viewForPageAtIndex:(NSInteger)pageIndex
{
    SYPageView *pageView = [paginatorView dequeueReusablePageWithIdentifier:@"pageView"];
    if (!pageView) {
        pageView = [[SYPageView alloc] initWithReuseIdentifier:@"pageView"];
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:pageView.bounds];
        imgV.autoresizingMask = UIViewAutoresizingFlexibleAll;
        imgV.tag = 1001;
        [pageView addSubview:imgV];
    }
    UIImageView *imgV = (UIImageView *)[pageView viewWithTag:1001];
    imgV.image = [UIImage imageNamed:@"tmp_ad1"];
    return pageView;
}

- (void)paginatorView:(SYPaginatorView *)paginatorView didScrollToPageAtIndex:(NSInteger)pageIndex
{
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShopCell" forIndexPath:indexPath];
    NSDictionary *item = [self.datasource safetyObjectAtIndex:indexPath.row];
    //row 0
    UIImageView *logoV = (UIImageView *)[cell.contentView viewWithTag:1001];
    UILabel *titleL = (UILabel *)[cell.contentView viewWithTag:1002];
    JTRatingView *ratingV = (JTRatingView *)[cell.contentView viewWithTag:1003];
    UILabel *ratingL = (UILabel *)[cell.contentView viewWithTag:1004];
    UILabel *addrL = (UILabel *)[cell.contentView viewWithTag:1005];
    UILabel *distantL = (UILabel *)[cell.contentView viewWithTag:1006];
    logoV.image = [UIImage imageNamed:item[@"logo"]];
    titleL.text = item[@"title"];
    ratingV.ratingValue = [item[@"rating"] floatValue];
    ratingL.text = [NSString stringWithFormat:@"%@分", item[@"rating"]];
    addrL.text = item[@"addr"];
    distantL.text = [NSString stringWithFormat:@"%@km", item[@"distance"]];
    //row 1
    UILabel *washTypeL = (UILabel *)[cell.contentView viewWithTag:2001];
    UILabel *integralL = (UILabel *)[cell.contentView viewWithTag:2002];
    UILabel *priceL = (UILabel *)[cell.contentView viewWithTag:2003];
    washTypeL.text = @"普洗：普通车";
    integralL.text = [NSString stringWithFormat:@"%@分", item[@"integral"]];
    priceL.attributedText = [self priceStringWithOldPrice:item[@"oldPrice"] curPrice:item[@"newPrice"]];
    //row 2
    UIButton *guideB = (UIButton *)[cell.contentView viewWithTag:3001];
    UIButton *phoneB = (UIButton *)[cell.contentView viewWithTag:3002];
    

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger mask = indexPath.row == 0 ? CKViewBorderDirectionBottom : CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
    [cell.contentView setBorderLineColor:HEXCOLOR(@"#e0e0e0") forDirectionMask:mask];
    [cell.contentView setBorderLineInsets:UIEdgeInsetsMake(0, 0, 8, 0) forDirectionMask:mask];
    [cell.contentView showBorderLineWithDirectionMask:mask];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShopDetailVC *vc = [UIStoryboard vcWithId:@"ShopDetailVC" inStoryboard:@"Carwash"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - Utility
- (NSAttributedString *)priceStringWithOldPrice:(NSNumber *)price1 curPrice:(NSNumber *)price2
{
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],
                            NSForegroundColorAttributeName:[UIColor lightGrayColor],
                            NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle)};
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"￥%@", price1] attributes:attr1];
    
    NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:18],
                            NSForegroundColorAttributeName:HEXCOLOR(@"#f93a00")};
    NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" ￥%@", price2] attributes:attr2];
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    [str appendAttributedString:attrStr1];
    [str appendAttributedString:attrStr2];
    return str;
}

@end
