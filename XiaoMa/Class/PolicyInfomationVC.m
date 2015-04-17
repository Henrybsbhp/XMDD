//
//  PolicyInfomationVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/13.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PolicyInfomationVC.h"
#import "XiaoMa.h"
#import "UIView+Layer.h"
#import <Masonry.h>

@interface PolicyInfomationVC ()
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSArray *datasource;
@end

@implementation PolicyInfomationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self reloadDatasource];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    for (UILabel *label in self.containerView.subviews) {
        [label layoutBorderLineIfNeeded];
    }
}

- (void)reloadDatasource
{
    NSArray *group1 = @[@[@"被保险人", @"李美美"],
                      @[@"车牌号码", @"浙A12345"],
                      @[@"证件号码", @"33013224354323425"],
                      @[@"保险公司", @"人保"],
                      @[@"保险期限", @"2013.01.01-2016.01.01"],
                      @[@"保费总额", @"￥4500"]];
    group1.customTag = 1;
    NSArray *group2 = @[@[@"承保险种", @"保险金额/责任限额（元）"],
                       @[@"机动车车损险", @"359,555.00"],
                       @[@"车上乘客责任险", @"10,000.00/座*4座"],
                       @[@"第三者责任保险", @"500,000.00"],
                       @[@"不计免赔率", @"10,000.00/座*1座"],
                       @[@"交强险", @"950.00"],
                       @[@"车船税",@"360.00"]];
    group2.customTag = 2;
    self.datasource = @[group1, group2];
    [self refreshScrollView];
}

- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    UIView *container = [UIView new];
    [self.scrollView addSubview:container];
    @weakify(self);
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self.scrollView);
        make.left.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    UIView *upperView = container;
    for (NSArray *group in self.datasource) {
        if (group.customTag == 1) {
            upperView = [self layoutTag1Group:group withContainer:container upperView:upperView];
        }
        if (group.customTag == 2) {
            upperView = [self layoutTag2Group:group withContainer:container upperView:upperView];
        }
    }
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(upperView).offset(10);
    }];
    self.containerView = container;
}

- (UIView *)layoutTag1Group:(NSArray *)group withContainer:(UIView *)container upperView:(UIView *)upperView
{
    for (NSArray *item in group) {
        UILabel *leftL = [UILabel new];
        leftL.font = [UIFont systemFontOfSize:14];
        leftL.text = [NSString stringWithFormat:@"%@: ", [item safetyObjectAtIndex:0]];
        UILabel *rightL = [UILabel new];
        rightL.font = [UIFont systemFontOfSize:14];
        rightL.text = [item safetyObjectAtIndex:1];
        [container addSubview:leftL];
        [container addSubview:rightL];
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            if ([upperView isEqual:container]) {
                make.top.equalTo(upperView.mas_top).offset(14);
            }
            else {
                make.top.equalTo(upperView.mas_bottom).offset(10);
            }
            make.left.equalTo(container).offset(12);
        }];
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftL);
            make.left.equalTo(leftL.mas_right).offset(0);
            make.right.equalTo(container.mas_right).offset(-12);
        }];
        upperView = leftL;
    }
    return upperView;
}

- (UIView *)layoutTag2Group:(NSArray *)group withContainer:(UIView *)container upperView:(UIView *)upperView
{
    for (int i = 0; i < group.count; i++) {
        NSArray *item = [group objectAtIndex:i];
        NSInteger lineMask;
        UILabel *leftL = [[UILabel alloc] initWithFrame:CGRectZero];
        leftL.font = [UIFont systemFontOfSize:14];
        leftL.textAlignment = NSTextAlignmentCenter;
        leftL.textColor = [UIColor darkGrayColor];
        leftL.text = [item safetyObjectAtIndex:0];
        if (i == 0) {
            leftL.backgroundColor = HEXCOLOR(@"#eaeaea");
            lineMask = CKViewBorderDirectionTop | CKViewBorderDirectionLeft |
            CKViewBorderDirectionBottom | CKViewBorderDirectionRight;
        }
        else {
            leftL.backgroundColor = HEXCOLOR(@"#f7f7f7");
            lineMask = CKViewBorderDirectionLeft | CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
        }
        [leftL setBorderLineColor:kDefLineColor forDirectionMask:lineMask];
        [leftL showBorderLineWithDirectionMask:lineMask];
        [container addSubview:leftL];
        [leftL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(upperView.mas_bottom).offset(i == 0 ? 14 : 0);
            make.left.equalTo(container).offset(12);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(126);
        }];
        
        UILabel *rightL = [[UILabel alloc] initWithFrame:CGRectZero];
        rightL.font = [UIFont systemFontOfSize:14];
        rightL.textAlignment = NSTextAlignmentCenter;
        rightL.textColor = [UIColor darkGrayColor];
        rightL.text = [item safetyObjectAtIndex:1];
        if (i == 0) {
            rightL.backgroundColor = HEXCOLOR(@"#eaeaea");
            lineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom | CKViewBorderDirectionTop;
        }
        else {
            rightL.backgroundColor = HEXCOLOR(@"#f7f7f7");
            lineMask = CKViewBorderDirectionRight | CKViewBorderDirectionBottom;
        }
        [rightL setBorderLineColor:kDefLineColor forDirectionMask:lineMask];
        [rightL showBorderLineWithDirectionMask:lineMask];
        [container addSubview:rightL];
        [rightL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(leftL);
            make.left.equalTo(leftL.mas_right);
            make.height.mas_equalTo(30);
            make.right.equalTo(container).offset(-12);
        }];
        upperView = leftL;
    }
    return upperView;
}


#pragma mark - Action
- (IBAction)actionNext:(id)sender
{
    
}


@end
