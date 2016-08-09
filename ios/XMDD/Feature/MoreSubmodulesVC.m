//
//  MoreSubmodulesVC.m
//  XiaoMa
//
//  Created by fuqi on 16/6/24.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MoreSubmodulesVC.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"
#import "UIView+HKLine.h"

#import "HomePageModuleModel.h"


#define SubModuleViewTag 20101

@interface MoreSubmodulesVC ()

@property (nonatomic,strong)UIScrollView * scrollView;
@property (nonatomic,strong)UIView * containView;

@property (nonatomic,strong)HomePageModuleModel * moduleModel;

@property (nonatomic,strong)NSArray * submoduleArray;
@property (nonatomic)NSInteger numOfColumn;
@property (nonatomic)NSInteger numOfRow;
@property (nonatomic)CGFloat squareWidth;
@property (nonatomic)CGFloat squareHeight;

@end

@implementation MoreSubmodulesVC

- (void)dealloc
{
    DebugLog(@"MoreSubmodulesVC dealloc");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.submoduleArray = gAppMgr.homePicModel.moreItemArray;
    self.numOfColumn = 3;
    self.numOfRow = self.submoduleArray.count / 3 + ((self.submoduleArray.count % 3) > 0 ? 1 : 0);
    self.squareWidth = gAppMgr.deviceInfo.screenSize.width / (CGFloat)self.numOfColumn;
    self.squareHeight = 208.0f / 250.0f * self.squareWidth;
    
    [self setupUI];
    [self setupModuleMode];
    [self drawLine];
}

- (void)setupUI
{
    self.navigationItem.title = @"更多";
    self.view.backgroundColor = kBackgroundColor;
    
    [self setupScrollView];
}

- (void)setupScrollView
{
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
    CGFloat squaresHeight = self.numOfRow * self.squareHeight;
    scrollView.contentSize = CGSizeMake(gAppMgr.deviceInfo.screenSize.width, MAX(CGRectGetHeight(self.view.frame), squaresHeight));
    scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView = scrollView;
    
    UIView * containView = [[UIView alloc] init];
    containView.frame = CGRectMake(0, 0, gAppMgr.deviceInfo.screenSize.width,squaresHeight);
    containView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:containView];
    self.containView = containView;
}

- (void)setupModuleMode
{
    self.moduleModel.moduleArray = self.submoduleArray;
    self.moduleModel.numOfColumn = self.numOfColumn;
    
    [self.moduleModel setupSquaresViewWithContainView:self.containView andItemWith:self.squareWidth andItemHeigth:self.squareHeight];
}


- (void)drawLine
{
    [self.containView drawLineWithDirection:CKViewBorderDirectionLeft withEdge:UIEdgeInsetsMake(0, self.squareWidth, 0, 0)];
    [self.containView drawLineWithDirection:CKViewBorderDirectionLeft withEdge:UIEdgeInsetsMake(0, self.squareWidth * 2, 0, 0)];
    
    
    
    for (NSInteger i = 0; i < self.numOfRow ; i++)
    {
        [self.containView drawLineWithDirection:CKViewBorderDirectionTop withEdge:UIEdgeInsetsMake(self.squareHeight * (i+1), 0, 0, 0)];
    }
}



#pragma mark - Lazy
- (HomePageModuleModel *)moduleModel
{
    if (!_moduleModel)
    {
        _moduleModel = [[HomePageModuleModel alloc] init];
    }
    return _moduleModel;
}

@end
