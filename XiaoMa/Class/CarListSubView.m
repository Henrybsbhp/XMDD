//
//  CarListSubView.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/9/2.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "CarListSubView.h"
#import "DashLine.h"

@implementation CarListSubView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];

    //手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
    [self addGestureRecognizer:tap];
    
    @weakify(self);
    //背景
    UIImageView *bgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    bgV.tag = 10;
    [self addSubview:bgV];
    [bgV mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.edges.equalTo(self);
    }];
    
    //顶部视图
    [self createHeaderView];
    
    //分割线
    DashLine *line = [[DashLine alloc] initWithFrame:CGRectZero];
//    line.lineColor = HEXCOLOR(@"#e3e3e3");
    CGFloat* lengths = malloc(sizeof(CGFloat)*2);
    lengths[0] = 5;
    lengths[1] = 2;
    line.dashLengths = lengths;
    [self addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self).offset(49);
        make.height.mas_equalTo(1);
        make.left.equalTo(self).offset(7);
        make.right.equalTo(self).offset(-7);
    }];
    
    //内容
    for (int i = 0; i < 7; i++) {
        [self createCellAtIndex:i];
    }
    
    //占位视图
    UIView *placeholdV = [[UIView alloc] initWithFrame:CGRectZero];
    placeholdV.backgroundColor = [UIColor clearColor];
    [self addSubview:placeholdV];
    [placeholdV mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        UIView *lastCell = [self viewWithTag:106];
        make.top.equalTo(lastCell.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(lastCell).multipliedBy(3.0/5);
    }];
    
    //底部视图
    [self createBottomViewWithPlaceholdView:placeholdV];
}

- (void)createHeaderView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    view.tag = 200;
    [self addSubview:view];
    @weakify(self);
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self);
        make.left.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
        make.height.mas_equalTo(45);
    }];
    
    //状态条
    UIImageView *barV = [[UIImageView alloc] initWithFrame:CGRectZero];
    barV.tag = 2001;
    [view addSubview:barV];

    //汽车商标
//    UIImageView *logoV = [[UIImageView alloc] initWithFrame:CGRectZero];
//    logoV.tag = 2002;
//    [view addSubview:logoV];
//    self.logoView = logoV;
    
    //车牌
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.tag = 2003;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    [view addSubview:label];
    self.licenceNumberLabel = label;
    
    [self createMarkViewWithContainer:view];

    [barV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.height.mas_equalTo(2.5);
        make.left.equalTo(view);
        make.right.equalTo(label.mas_right);
    }];
    
//    [logoV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.size.mas_equalTo(CGSizeMake(25, 25));
//        make.centerY.equalTo(label.mas_centerY);
//        make.left.equalTo(barV.mas_left);
//    }];
    
    [label setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(logoV.mas_right).offset(5);
        make.left.equalTo(barV.mas_left);
        make.height.mas_equalTo(30);
        make.top.equalTo(barV.mas_bottom).offset(4);
    }];
}

- (void)createMarkViewWithContainer:(UIView *)container
{
    UIView *markV = [[UIView alloc] initWithFrame:CGRectZero];
    markV.tag = 2004;
    [container addSubview:markV];
    self.markView = markV;
    
    UIImageView *bgV = [[UIImageView alloc] initWithFrame:CGRectZero];
    bgV.tag = 20041;
    [markV addSubview:bgV];
    
    UILabel *defL = [[UILabel alloc] initWithFrame:CGRectZero];
    defL.tag = 20042;
    defL.textColor = [UIColor whiteColor];
    defL.backgroundColor = [UIColor clearColor];
    defL.font = [UIFont boldSystemFontOfSize:13];
    defL.textAlignment = NSTextAlignmentCenter;
    defL.text = @"默认";
    [markV addSubview:defL];

    [markV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 33));
        make.top.equalTo(container);
        make.right.equalTo(container).offset(-4);
    }];
    
    [bgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(markV);
    }];
    
    [defL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(markV);
        make.centerY.equalTo(markV).offset(-3);
    }];
}

- (void)createCellAtIndex:(NSInteger)index
{
    NSInteger tag = index+100;
    UIView *cell = [[UIView alloc] initWithFrame:CGRectZero];
    cell.tag = tag;
    cell.backgroundColor = [UIColor clearColor];
    [self addSubview:cell];
    @weakify(self);
    [cell mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        if (index == 0) {
            make.top.equalTo(self).offset(58);
        }
        else {
            UIView *prevCell = [self viewWithTag:tag-1];
            make.top.equalTo(prevCell.mas_bottom).offset(0);
            make.height.equalTo(prevCell);
        }
        make.left.equalTo(self).offset(14);
        make.right.equalTo(self).offset(-14);
    }];
    
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectZero];
    titleL.tag = tag*10+1;
    titleL.font = [UIFont systemFontOfSize:15];
    titleL.backgroundColor = [UIColor clearColor];
    titleL.textColor = HEXCOLOR(@"#555555");
    //[titleL setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

    UILabel *valueL = [[UILabel alloc] initWithFrame:CGRectZero];
    valueL.tag = tag*10+2;
    valueL.backgroundColor = [UIColor clearColor];
    valueL.font = [UIFont systemFontOfSize:15];
    valueL.textAlignment = NSTextAlignmentRight;
    valueL.textColor = HEXCOLOR(@"#999999");
    [valueL setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [cell addSubview:titleL];
    [cell addSubview:valueL];
    
    [titleL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cell);
        make.top.equalTo(cell);
        make.bottom.equalTo(cell);
    }];
    
    [valueL mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleL.mas_right);
        make.top.equalTo(cell);
        make.bottom.equalTo(cell);
        make.right.equalTo(cell);
    }];
}

- (void)createBottomViewWithPlaceholdView:(UIView *)pv
{
    UIView *bottomV1 = [[UIView alloc] initWithFrame:CGRectZero];
    bottomV1.backgroundColor = [UIColor clearColor];
    bottomV1.tag = 301;
    [self addSubview:bottomV1];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectZero];
    button1.tag = 3011;
    button1.layer.cornerRadius = 17.5;
    button1.layer.masksToBounds = YES;
    button1.backgroundColor = [UIColor whiteColor];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button1.titleLabel.font = [UIFont boldSystemFontOfSize:19];
    [button1 setTitle:@"一键上传" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(actionBottomButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [bottomV1 addSubview:button1];
    
    UILabel *textL1 = [[UILabel alloc] initWithFrame:CGRectZero];
    textL1.tag = 3012;
    textL1.backgroundColor = [UIColor clearColor];
    textL1.textColor = [UIColor whiteColor];
    textL1.font = [UIFont systemFontOfSize:13];
    textL1.textAlignment = NSTextAlignmentCenter;
    textL1.numberOfLines = 0;
    [bottomV1 addSubview:textL1];
    
    @weakify(self);
    [bottomV1 mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(pv.mas_bottom);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(84);
    }];
    
    [button1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(130, 35));
        make.top.equalTo(bottomV1).offset(9);
        make.centerX.equalTo(bottomV1);
    }];
    
    [textL1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button1.mas_bottom).offset(2);
        make.left.equalTo(bottomV1).offset(18);
        make.right.equalTo(bottomV1).offset(-18);
        make.bottom.equalTo(bottomV1).offset(-2);
    }];

    
    UIView *bottomV2 = [[UIView alloc] initWithFrame:CGRectZero];
    bottomV2.backgroundColor = [UIColor clearColor];
    bottomV2.hidden = YES;
    bottomV2.tag = 302;
    [self addSubview:bottomV2];
    
    UILabel *textL2 = [[UILabel alloc] initWithFrame:CGRectZero];
    textL2.tag = 3021;
    textL2.backgroundColor = [UIColor clearColor];
    textL2.textAlignment = NSTextAlignmentCenter;
    textL2.numberOfLines = 0;
    textL2.textColor = [UIColor whiteColor];
    textL2.font = [UIFont boldSystemFontOfSize:17];
    [bottomV2 addSubview:textL2];
    
    [bottomV2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(bottomV1);
    }];
    
    [textL2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomV2).offset(10);
        make.bottom.equalTo(bottomV2).offset(-10);
        make.left.equalTo(bottomV2).offset(10);
        make.right.equalTo(bottomV2).offset(-10);
    }];
}

#pragma mark - Action
- (void)actionTap:(id)sender
{
    if (self.backgroundClickBlock) {
        self.backgroundClickBlock(self);
    }
}

- (void)actionBottomButtonClick:(id)sender
{
    if (self.bottomButtonClickBlock) {
        self.bottomButtonClickBlock(sender, self);
    }
}
#pragma mark - Public
- (void)setCarTintColorType:(HKCarTintColorType)colorType
{
    UIColor *color = [HKMyCar tintColorForColorType:colorType];
    
    UIImageView *bgV = (UIImageView *)[self viewWithTag:10];
    UIImage *bg = [UIImage imageNamed:[NSString stringWithFormat:@"mec_bg%d",(int)colorType]];
    bgV.image = [bg resizableImageWithCapInsets:UIEdgeInsetsMake(55, 10, 85, 10)];
    
    UIImageView *topBarV = (UIImageView *)[self viewWithTag:2001];
    topBarV.image = [UIImage imageNamed:[NSString stringWithFormat:@"mec_bar%d",(int)colorType]];

    self.licenceNumberLabel.textColor = color;
    
    UIImageView *markBgV = (UIImageView *)[self viewWithTag:20041];
    markBgV.image = [UIImage imageNamed:[NSString stringWithFormat:@"mec_mark%d",(int)colorType]];
    
    UIButton *bottomB = (UIButton *)[self viewWithTag:3011];
    [bottomB setTitleColor:color forState:UIControlStateNormal];
}

- (void)setCellTitle:(NSString *)title withValue:(NSString *)value atIndex:(NSInteger)index
{
    NSInteger tag = 100+index;
    UIView *cell = [self viewWithTag:100+index];
    UILabel *titleL = (UILabel *)[cell viewWithTag:tag*10+1];
    UILabel *valueL = (UILabel *)[cell viewWithTag:tag*10+2];
    titleL.text = title;
    valueL.text = value;
}

- (void)setShowBottomButton:(BOOL)show withText:(NSString *)text
{
    UIView *view1 = [self viewWithTag:301];
    UIView *view2 = [self viewWithTag:302];
    if (show) {
        view1.hidden = NO;
        view2.hidden = YES;
        UILabel *label1 = (UILabel *)[view1 viewWithTag:3012];
        label1.text = text;
    }
    else {
        view1.hidden = YES;
        view2.hidden = NO;
        UILabel *label2 = (UILabel *)[view2 viewWithTag:3021];
        label2.text = text;
    }
}

@end
