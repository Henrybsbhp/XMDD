//
//  MutualInsGrouponCardCell.m
//  XiaoMa
//
//  Created by jiangjunchen on 16/3/9.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "MutualInsGrouponCarsCell.h"
#import "MutualInsConstants.h"

#define kItemWidth      44
#define kMarginTop      16
#define kMarginBottom   5
#define kLabelHeight    16
#define kImgLen         35

@interface MutualInsGrouponCarsCell ()
@property (nonatomic, strong) NSMutableArray *items;
@end
@implementation MutualInsGrouponCarsCell

- (void)setCars:(NSArray *)cars
{
    _cars = cars;
    BOOL overflow = self.items.count < self.cars.count;
    for (NSInteger i=0; i < self.items.count; i++) {
        NSDictionary *info = [self.cars safetyObjectAtIndex:i];
        UIView *view = self.items[i];
        UIImageView *imgV = [view viewWithTag:1001];
        UILabel *label = [view viewWithTag:1002];
        //items的最后一个元素，并且cars还有多余元素
        if (overflow && i == self.items.count-1) {
            label.hidden = YES;
            imgV.hidden = NO;
            imgV.image = [UIImage imageNamed:@"mins_more"];
        }
        else if (info) {
            label.hidden = NO;
            imgV.hidden = NO;
            label.text = info[@"title"];
            [imgV setImageByUrl:info[@"img"] withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        }
        else {
            label.hidden = YES;
            imgV.image = nil;
            imgV.hidden = YES;
        }
    }
}
- (void)setupWithCellBounds:(CGRect)bounds
{
    if (self.items) {
        return;
    }
    self.items = [NSMutableArray array];
    
    NSInteger count = floor(bounds.size.width / kItemWidth);
    for (NSInteger i = 0; i < count; i++) {
        UIView *itemView = [self createItemViewWithBounds:bounds atIndex:i];
        [self.items addObject:itemView];
        [self addSubview:itemView];
    }
}

#pragma mark - Action
- (void)actionItemClick:(UIButton *)sender
{
    NSInteger index = sender.tag;
    if (self.carDidSelectedBlock) {
        NSDictionary *info = [self.cars safetyObjectAtIndex:index];
        if (info) {
            self.carDidSelectedBlock(index+1 < self.items.count ? info : nil);
        }
    }
}

#pragma mark - Util
- (UIView *)createItemViewWithBounds:(CGRect)bounds atIndex:(NSInteger)index
{
    NSInteger count = floor(bounds.size.width / kItemWidth);
    CGFloat spacing = ceil((bounds.size.width - count*kItemWidth)/(1 + count));
    CGRect rect = CGRectMake(spacing*(1+index)+kItemWidth*index, kMarginTop,
                             kItemWidth, bounds.size.height - kMarginBottom - kMarginTop);

    UIView *view = [[UIView alloc] initWithFrame:rect];

    rect.origin = CGPointZero;
    UIButton *tapBtn = [[UIButton alloc] initWithFrame:rect];
    tapBtn.tag = index;
    tapBtn.backgroundColor = [UIColor clearColor];
    [tapBtn addTarget:self action:@selector(actionItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    rect = CGRectMake(floor((rect.size.width-kImgLen)/2), floor((rect.size.height-kLabelHeight-kImgLen)/2), kImgLen, kImgLen);
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:rect];
    imgView.tag = 1001;

    rect = CGRectMake(0, view.frame.size.height - kLabelHeight, kItemWidth, kLabelHeight);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = MutInsTextGrayColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.minimumScaleFactor = 0.7;
    label.adjustsFontSizeToFitWidth = YES;
    label.tag = 1002;
    
    [view addSubview:imgView];
    [view addSubview:label];
    [view addSubview:tapBtn];
    
    return view;
}
@end

