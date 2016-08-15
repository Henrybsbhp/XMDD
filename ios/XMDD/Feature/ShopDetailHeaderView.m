//
//  ShopDetailHeaderView.m
//  XMDD
//
//  Created by jiangjunchen on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "ShopDetailHeaderView.h"
#import "CKLine.h"
#import "SDPhotoBrowser.h"

#define kBottomBarBgColor  [[UIColor blackColor] colorWithAlpha:0.4]
#define kBottomBarTextColor [[UIColor whiteColor] colorWithAlpha:0.8]
#define kBottomBarHeight    22

@interface ShopDetailHeaderView ()<SDPhotoBrowserDelegate>

@property (nonatomic, strong) UILabel *numberLabel;
@end
@implementation ShopDetailHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self __commonInit];
    }
    return self;
}

- (void)__commonInit {
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionShowPhotos:)];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    _imageView.clipsToBounds = YES;
    [_imageView addGestureRecognizer:self.tapGesture];
    [self addSubview:_imageView];
    
    UIImageView *maskView = [[UIImageView alloc] initWithFrame:CGRectZero];
    maskView.image = [UIImage imageNamed:@"shop_imgmask"];
    [self addSubview:maskView];
    
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _numberLabel.backgroundColor = kBottomBarBgColor;
    _numberLabel.textColor = kBottomBarTextColor;
    _numberLabel.font = [UIFont systemFontOfSize:13];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.text = @"0张";
    [self addSubview:_numberLabel];

    [self setupTrottingView];
    
    @weakify(self);
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
    }];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.imageView);
    }];
    
    [_numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(52);
        make.height.mas_equalTo(kBottomBarHeight);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
}

- (void)setupTrottingView {
    _trottingContainerView = [[UIView alloc] initWithFrame:CGRectZero];
    _trottingContainerView.backgroundColor = kBottomBarBgColor;
    [self addSubview:_trottingContainerView];
    
    _trottingView = [[CBAutoScrollLabel alloc] initWithFrame:CGRectZero];
    _trottingView.textColor = kBottomBarTextColor;
    _trottingView.font = [UIFont systemFontOfSize:13];
    _trottingView.backgroundColor = [UIColor clearColor];
    _trottingView.labelSpacing = 30;
    _trottingView.scrollSpeed = 30;
    _trottingView.fadeLength = 5.f;
    [_trottingContainerView addSubview:_trottingView];
    [_trottingView observeApplicationNotifications];
    
    CKLine *line = [[CKLine alloc] initWithFrame:CGRectZero];
    line.lineOptions = CKLineOptionNone;
    line.lineColor = kBottomBarTextColor;
    line.lineAlignment = CKLineAlignmentVerticalRight;
    [_trottingContainerView addSubview:line];
    
    @weakify(self);
    [_trottingContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.height.mas_equalTo(kBottomBarHeight);
        make.left.equalTo(self);
        make.right.equalTo(self.numberLabel.mas_left);
        make.bottom.equalTo(self);
    }];
    
    [_trottingView mas_makeConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.left.equalTo(self.trottingContainerView).offset(5);
        make.right.equalTo(self.trottingContainerView).offset(-5);
        make.top.equalTo(self.trottingContainerView);
        make.bottom.equalTo(self.trottingContainerView);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.top.equalTo(self.trottingContainerView).offset(5);
        make.bottom.equalTo(self.trottingContainerView).offset(-5);
        make.right.equalTo(self.trottingContainerView);
    }];
   
}

#pragma mark - Observer
#pragma mark - Setter 
- (void)setPicURLArray:(NSArray *)picURLArray {
    _picURLArray = picURLArray;
    [_imageView setImageByUrl:[picURLArray safetyObjectAtIndex:0]
                     withType:ImageURLTypeMedium
                     defImage:@"cm_shop" errorImage:@"cm_shop"];
    _numberLabel.text = [NSString stringWithFormat:@"%ld张", (long)(self.picURLArray.count)];
}
#pragma mark - Action
- (void)actionShowPhotos:(UITapGestureRecognizer *)tap {
    if (_picURLArray.count > 0) {
        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.sourceImagesContainerView = self;// 原图的容器
        browser.imageCount = _picURLArray.count; // 图片总数
        browser.currentImageIndex = 0;
        browser.delegate = self;
        browser.sourceImagesContainerViewContentMode = sourceImagesContainerViewContentFill;
        [browser show];
    }
}

#pragma mark - SDPhotoBrowserDelegate
// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if (index == 0) {
        NSString *strurl = [gMediaMgr urlWith:[_picURLArray safetyObjectAtIndex:0] imageType:ImageURLTypeMedium];
        UIImage *cachedImg = [gMediaMgr imageFromMemoryCacheForUrl:strurl];
        return cachedImg ? cachedImg : [UIImage imageNamed:@"cm_shop"];
    }
    return [UIImage imageNamed:@"cm_shop"];
}


// 返回高质量图片的url
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    return [NSURL URLWithString:[gMediaMgr urlWith:[_picURLArray safetyObjectAtIndex:index] imageType:ImageURLTypeMedium]];
}

@end
