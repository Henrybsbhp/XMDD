//
//  CarwashShopListVC.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/10.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "CarwashShopListVC.h"
#import "HorizontalScrollTabView.h"
#import "ShopListVC.h"

@interface CarwashShopListVC ()
@property (nonatomic, strong) HorizontalScrollTabView *headerTabView;
@property (nonatomic, strong) CKList *childTableVCList;
@end
@implementation CarwashShopListVC

- (void)dealloc {
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kBackgroundColor;
    self.childTableVCList = [CKList list];
    [self setupNavigationBar];
    [self setupHeaderTabView];
    CKAsyncMainQueue(^{
        [self showShopListWithServiceType:self.serviceType];
    });
}

- (void)setupNavigationBar {
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_search_300"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(actionSearch:)];
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_local_300"]
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(actionMap:)];
    self.navigationItem.rightBarButtonItems = @[mapItem, searchItem];
    self.navigationItem.title = @"洗车";
}

- (void)setupHeaderTabView {
    _headerTabView = [[HorizontalScrollTabView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
    _headerTabView.scrollTipBarColor = kDefTintColor;
    _headerTabView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_headerTabView];
    
    HorizontalScrollTabItem *item1 = [HorizontalScrollTabItem itemWithTitle:@"普洗" normalColor:kDarkTextColor
                                                              selectedColor:kDefTintColor];
    HorizontalScrollTabItem *item2 = [HorizontalScrollTabItem itemWithTitle:@"精洗" normalColor:kDarkTextColor
                                                              selectedColor:kDefTintColor];
    _headerTabView.items = @[item1, item2];

    @weakify(self);
    [_headerTabView setTabBlock:^(NSInteger index) {
        @strongify(self);
        [self showShopListWithServiceType:[self serviceTypeAtIndex:index]];
    }];
    
    [_headerTabView reloadDataWithBoundsSize:CGSizeMake(ScreenWidth, 45)
                            andSelectedIndex:[self indexForServiceType:self.serviceType]];
}


#pragma mark - Action 
- (void)actionSearch:(id)sender {
    ShopListVC *childVC = [self childVCAtIndex:self.headerTabView.selectedIndex];
    [childVC actionSearch:sender];
}

- (void)actionMap:(id)sender {
    ShopListVC *childVC = [self childVCAtIndex:self.headerTabView.selectedIndex];
    [childVC actionMap:sender];
}

- (void)showShopListWithServiceType:(ShopServiceType)type {
    ShopListVC *childVC = self.childTableVCList[@(type)];
    if (!childVC) {
        childVC = [[ShopListVC alloc] init];
        [self addChildViewController:childVC];
        self.childTableVCList[@(type)] = childVC;
        childVC.serviceType = type;
        childVC.coupon = self.coupon;
        [self.view addSubview:childVC.view];
        childVC.view.frame = CGRectMake(0, 45, ScreenWidth, self.view.frame.size.height - 45);
    }
    [self.view bringSubviewToFront:childVC.view];
}

#pragma mark - Util
- (ShopListVC *)childVCAtIndex:(NSInteger)index {
    ShopServiceType type = [self serviceTypeAtIndex:self.headerTabView.selectedIndex];
    return self.childTableVCList[@(type)];
}

- (NSInteger)indexForServiceType:(ShopServiceType)type {
    return type == ShopServiceCarwashWithHeart ? 1 : 0;
}

- (ShopServiceType)serviceTypeAtIndex:(NSInteger)index {
    return index == 0 ? ShopServiceCarWash : ShopServiceCarwashWithHeart;
}

@end
