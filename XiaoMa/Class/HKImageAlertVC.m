//
//  HKImageAlertVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKImageAlertVC.h"
#import "NSString+RectSize.h"

#define kImageHeight    100
#define kInnerSpacing   14
#define kTopTitleheight 20
#define kAlertWidth     280

@interface HKImageAlertVC ()

@end

@implementation HKImageAlertVC

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.contentInsets = UIEdgeInsetsMake(35, 25, 35, 25);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showWithActionHandler:(void(^)(NSInteger index, id alertVC))actionHandler {
    
    CGRect rect = CGRectMake(0, 0, kAlertWidth, kImageHeight);
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:rect];
    imageV.image = [UIImage imageNamed:self.imageName];
    
    rect.origin.y = rect.size.height + self.contentInsets.top;
    rect.size.height = kTopTitleheight;
    UILabel *titleL = [[UILabel alloc] initWithFrame:rect];
    titleL.textAlignment = NSTextAlignmentCenter;
    titleL.font = [UIFont systemFontOfSize:16];
    titleL.textColor = [UIColor darkTextColor];
    titleL.text = self.topTitle;
    
    rect.origin = CGPointMake(self.contentInsets.left, rect.origin.y = rect.origin.y + rect.size.height + kInnerSpacing);
    rect.size.width = kAlertWidth - self.contentInsets.left - self.contentInsets.right;
    CGSize size = [self.message labelSizeWithWidth:rect.size.width
                                              font:[UIFont systemFontOfSize:14]];
    rect.size.height = ceil(size.height);
    
    UILabel *messageL = [[UILabel alloc] initWithFrame:rect];
    messageL.lineBreakMode = NSLineBreakByWordWrapping;
    messageL.font = [UIFont systemFontOfSize:14];
    messageL.textAlignment = NSTextAlignmentCenter;
    messageL.textColor = HEXCOLOR(@"#888888");
    messageL.numberOfLines = 0;
    messageL.text = self.message;
    
    rect = CGRectMake(0, 0, kAlertWidth, rect.origin.y + rect.size.height + self.contentInsets.bottom);
    UIView *contentView = [[UIView alloc] initWithFrame:rect];
    
    [contentView addSubview:imageV];
    [contentView addSubview:titleL];
    [contentView addSubview:messageL];
    self.contentView = contentView;
    
    [super showWithActionHandler:actionHandler];
}

+(HKImageAlertVC *)alertWithTopTitle:(NSString *)topTitle ImageName:(NSString *)imageName Message:(NSString *)message ActionItems:(NSArray *)actionItems
{
    HKImageAlertVC *alert = [[HKImageAlertVC alloc]init];
    alert.topTitle = topTitle;
    alert.imageName = imageName;
    alert.message = message;
    alert.actionItems = actionItems;
    return alert;
}

@end
