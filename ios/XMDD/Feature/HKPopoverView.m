//
//  HKPopoverView.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HKPopoverView.h"
#import "HKTableViewCell.h"

#define kCellHeight         45
#define kTopMargin          7

@interface HKPopoverView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, strong) UIButton *dismissButton;
@end

@implementation HKPopoverView

- (instancetype)initWithMaxWithContentSize:(CGSize)size items:(NSArray *)items
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _items = items;
        _dismissButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _dismissButton.backgroundColor = [UIColor clearColor];
        [_dismissButton addTarget:self action:@selector(actionDismiss:) forControlEvents:UIControlEventTouchUpInside];
        
        self.alpha = 0;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        CGRect rect = CGRectMake(0, 0, size.width, MIN(size.height, items.count*kCellHeight + kTopMargin));
        self.frame = rect;

        self.bgView = [[UIImageView alloc] initWithFrame:rect];
        self.bgView.image = [[UIImage imageNamed:@"mins_pop_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 5, 5, 24)];
        [self addSubview:self.bgView];

        //tableView
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopMargin, size.width, size.height - kTopMargin)];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.delegate = self;
        tableView.dataSource = self;
        if (rect.size.height < size.height) {
            tableView.scrollEnabled = NO;
        }
        [self addSubview:tableView];
        self.tableView = tableView;
    }
    return self;
}

- (void)showAtAnchorPoint:(CGPoint)point inView:(UIView *)view dismissTargetView:(UIView *)view2 animated:(BOOL)animated
{
    CGRect rect = self.frame;
    rect.origin.x = point.x - rect.size.width + 15;
    rect.origin.y = point.y;
    self.frame = rect;
    [view addSubview:self];
    if (view2) {
        self.dismissButton.frame = view2.bounds;
        [view2 addSubview:self.dismissButton];
    }
    if (animated) {
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
        }];
    }
    else {
        self.alpha = 1;
        [view addSubview:self];
    }
    _isActivated = YES;
}

- (void)dismissWithAnimated:(BOOL)animated
{
    if (!self.isActivated) {
        return;
    }
    _isActivated = NO;
    if (animated) {
        self.tableView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self.dismissButton removeFromSuperview];
            [self removeFromSuperview];
            self.tableView.userInteractionEnabled = YES;
        }];
    }
    else {
        self.alpha = 0;
        [self.dismissButton removeFromSuperview];
        [self removeFromSuperview];
    }
    if (self.didDismissedBlock) {
        self.didDismissedBlock(animated);
    }
}

- (void)actionDismiss:(id)sender
{
    [self dismissWithAnimated:YES];
}

#pragma mark - UITableViewDelegate and datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.didSelectedBlock) {
        self.didSelectedBlock(indexPath.row);
    }
    [self dismissWithAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        
        cell = [[HKTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *imageV = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageV.contentMode = UIViewContentModeCenter;
        imageV.tag = 1001;
        [cell.contentView addSubview:imageV];
        
        UILabel *textL = [[UILabel alloc] initWithFrame:CGRectZero];
        textL.tag = 1002;
        textL.font = [UIFont systemFontOfSize:14];
        textL.textColor = [UIColor darkTextColor];
        [cell.contentView addSubview:textL];
        
        UIView *contentV = cell.contentView;
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.left.equalTo(contentV).offset(14);
            make.centerY.equalTo(contentV.mas_centerY);
        }];
        
        [textL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(imageV.mas_right).offset(10);
            make.top.equalTo(contentV);
            make.bottom.equalTo(contentV);
            make.right.equalTo(contentV).offset(-14);
        }];
    }

    UIImageView *imageV = [cell.contentView viewWithTag:1001];
    UILabel *textL = [cell.contentView viewWithTag:1002];
    HKPopoverViewItem *item = [self.items safetyObjectAtIndex:indexPath.row];

    imageV.image = item.imageName ? [UIImage imageNamed:item.imageName] : nil;
    textL.text = item.title;
    
    //最后一行隐藏分割线
    if (indexPath.row == MAX(0, self.items.count-1)) {
        [cell removeAllBorderLines];
    }
    else {
        [cell addOrUpdateBorderLineWithAlignment:CKLineAlignmentHorizontalBottom insets:UIEdgeInsetsMake(0, 10, 0, 10)];
    }
    return cell;
}


@end

@implementation HKPopoverViewItem

+ (instancetype)itemWithTitle:(NSString *)title imageName:(NSString *)imgname
{
    HKPopoverViewItem *item = [[HKPopoverViewItem alloc] init];
    item.title = title;
    item.imageName = imgname;
    return item;
}

@end