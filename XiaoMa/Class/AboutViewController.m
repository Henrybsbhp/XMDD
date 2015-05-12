//
//  AboutViewController.m
//  XiaoMa
//
//  Created by jt on 15-5-12.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "AboutViewController.h"
#import "JTTableView.h"

@interface AboutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet JTTableView *tableView;

@property (nonatomic,strong)NSArray * datasource;

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datasource = @[@{@"title":@"去给小马达达评分",@"acton":^(void){
        NSLog(@"aaa");
    }},
                        @{@"title":@"用户服务协议",@"acton":^(void){}},
                        @{@"title":@"版本检测更新",@"acton":^(void){}},
                        @{@"title":@"查看欢迎页",@"acton":^(void){}},
                        @{@"title":@"意见反馈",@"acton":^(void){}},
                        @{@"title":@"客服电话4002313143",@"acton":^(void){}}];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell" forIndexPath:indexPath];
    UILabel * lb = (UILabel *)[cell searchViewWithTag:101];
    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
    lb.text = [dict objectForKey:@"title"];
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSDictionary * dict = [self.datasource safetyObjectAtIndex:indexPath.row];
//    typedef void(^MyBlock)(void);
//    MyBlock area = dict[@"aciont"];
//    area();
}

@end
