//
//  LogAlertView.m
//  XiaoNiuShared
//
//  Created by jt on 14-8-5.
//  Copyright (c) 2014年 jiangjunchen. All rights reserved.
//

#import "LogAlertView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LogAlertView

- (void)awakeFromNib
{
    // Initialization code
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.title = [[UILabel alloc] initWithFrame:CGRectZero];
        self.title.text = @"选择要上传的日志";
        self.tableview = [[UITableView alloc] initWithFrame:CGRectZero];
        
        self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.okBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.okBtn setTitle:@"确认" forState:UIControlStateNormal];
        [self.okBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        self.bgView = [[UIView alloc] initWithFrame:CGRectZero];
        self.bgView.backgroundColor = [UIColor lightGrayColor];
        self.bgView.layer.cornerRadius = 5;
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.borderWidth = 10;
        self.bgView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
        
        self.superBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        self.superBtn.backgroundColor = [UIColor clearColor];
        
        
        [self.bgView addSubview:self.title];
        [self.bgView addSubview:self.tableview];
        [self.bgView addSubview:self.cancelBtn];
        [self.bgView addSubview:self.okBtn];
        
        [self.superBtn addSubview:self.bgView];
        
        [self addSubview:self.superBtn];
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 5;
        self.layer.borderWidth = 5;
        self.layer.borderColor = (__bridge CGColorRef)([UIColor lightGrayColor]);
        self.layer.masksToBounds = YES;
        
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.title.frame = CGRectMake(30, 10, 250, 20);
    self.title.textAlignment = NSTextAlignmentCenter;
    
    self.tableview.frame = CGRectMake(10, 40, 280, 160);
    self.tableview.backgroundColor = [UIColor whiteColor];
    self.tableview.layer.cornerRadius = 5;
    self.tableview.layer.masksToBounds = YES;
    self.tableview.layer.borderWidth = 5;
    self.tableview.layer.borderColor = (__bridge CGColorRef)([UIColor redColor]);
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    
    self.cancelBtn.frame = CGRectMake(50, 210, 50, 30);
    self.cancelBtn.layer.borderWidth = 5;
    self.cancelBtn.layer.borderColor = (__bridge CGColorRef)([UIColor redColor]);
    
    self.okBtn.frame = CGRectMake(200, 210, 50, 30);
    self.okBtn.layer.borderWidth = 5;
    self.okBtn.layer.borderColor = (__bridge CGColorRef)([UIColor redColor]);
    
    self.bgView.frame = CGRectMake(10, 100, 300, 250);
    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;
    self.bgView.layer.borderWidth = 10;
    self.bgView.layer.borderColor = (__bridge CGColorRef)([UIColor blackColor]);
    
    self.superBtn.frame = self.frame;
    self.superBtn.backgroundColor = [UIColor clearColor];
    
    [self.tableview reloadData];
}


#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.logArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"logTableViewCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    NSString * obj = [[self.logArray safetyObjectAtIndex:indexPath.row] substringFromIndex:21];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",obj];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectBlock)
    {
        self.selectBlock(indexPath.row);
    }
}


@end
