//
//  MyInfoViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-11.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "MyInfoViewController.h"
#import "JTTableView.h"

@interface MyInfoViewController ()

@property (nonatomic,strong) UIImage * avatar;
@property (nonatomic, strong) UIActionSheet *sexSheet;
@property (nonatomic, strong) UIActionSheet *photoSheet;

@property (nonatomic)NSInteger sex;
@property (nonatomic,strong)NSDate * birthday;


@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [SVProgressHUD dismiss];
}

-(void)dealloc
{
    DebugLog(@"MyInfoViewController dealloc");
}





@end
