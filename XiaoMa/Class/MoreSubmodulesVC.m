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


#define SubModuleViewTag 20101

@interface MoreSubmodulesVC ()

@property (nonatomic,strong)UIScrollView * scrollView;
@property (nonatomic,strong)NSArray * submoduleArray;

// 九宫格按钮的dispoable数据，控制点击事件释放
@property (nonatomic, strong)NSMutableArray * disposableArray;

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
    self.submoduleArray = gAppMgr.homePicModel.moreItemArray;
    self.numOfRow = 3;
    self.squareWidth = gAppMgr.deviceInfo.screenSize.width / (CGFloat)self.numOfRow;
    self.squareHeight = 208.0f / 250.0f * self.squareWidth;
    
    [self setupUI];
}

- (void)setupUI
{
    self.navigationItem.title = @"更多";
    
    self.view.backgroundColor = kBackgroundColor;
    [self setupScrollView];
    [self setupSquaresView];
    
    [self drawLine];
}

- (void)setupScrollView
{
    UIScrollView * scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:scrollView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.bottom.left.right.equalTo(self.view);
    }];
    
    NSInteger numOfRow = self.submoduleArray.count / 3 + 1;
    CGFloat squaresHeight = numOfRow * self.squareHeight;
    scrollView.contentSize = CGSizeMake(gAppMgr.deviceInfo.screenSize.width, MAX(CGRectGetHeight(self.view.frame), squaresHeight));
    
    self.scrollView = scrollView;
}

- (void)setupSquaresView
{
    for (NSInteger i = 0; i < self.submoduleArray.count; i++)
    {
        HomeItem *item = [self.submoduleArray safetyObjectAtIndex:i];
        
        [self mainButtonWithSubmudule:item index:i inContainer:self.scrollView width:self.squareWidth height:self.squareHeight];
    }
}

- (UIImageView *)mainButtonWithSubmudule:(HomeItem *)item index:(NSInteger)index inContainer:(UIView *)container width:(CGFloat)width height:(CGFloat)height
{
    NSInteger tag = SubModuleViewTag;
    FLAnimatedImageView * itemView = [self functionalButtonWithImageName:item.defaultImageName action:nil inContainer:container andPicUrl:item.homeItemPicUrl];
    itemView.userInteractionEnabled = YES;
    itemView.tag = tag + index;
    
    NSInteger quotient = index / self.numOfRow;
    NSInteger remiainder = index % self.numOfRow;
    
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        make.top.equalTo(container).offset(height * quotient);
        make.left.equalTo(container).offset(width * remiainder);
    }];
    
    NSInteger iconTag = 2010101 + index;
    UIImageView * iconNewImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hp_new_icon"]];
    iconNewImageV.tag = iconTag;
    [itemView addSubview:iconNewImageV];
    
    [iconNewImageV mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(40);
        make.top.equalTo(itemView);
        make.right.equalTo(itemView);
    }];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    [itemView addGestureRecognizer:tapGesture];
    
    @weakify(self)
    RACDisposable * disposable = [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        
        @strongify(self)
        [self jumpToViewControllerByUrl:item.homeItemRedirect];
        
        // 把new标签设置回去
        if (![gAppMgr getElementReadStatus:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]] && item.isNewFlag)
        {
            [gAppMgr saveElementReaded:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]];
            iconNewImageV.hidden = YES;
        }
    }];
    
    [self.disposableArray safetyAddObject:disposable];
    
    BOOL isnewflag = (![gAppMgr getElementReadStatus:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]]) && item.isNewFlag;
    iconNewImageV.hidden = !isnewflag;
    
    return itemView;
}

- (FLAnimatedImageView *)functionalButtonWithImageName:(NSString *)imgName action:(SEL)action inContainer:(UIView *)container andPicUrl:(NSString *)picUrl
{
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [container addSubview:imageView];
    
    if (picUrl)
    {
        [self requestHomePicWithBtn:imageView andUrl:picUrl andDefaultPic:imgName errPic:imgName];
    }
    else
    {
        UIImage *img = [UIImage imageNamed:imgName];
        [imageView setImage:img];
    }
    return imageView;
}

- (void)requestHomePicWithBtn:(FLAnimatedImageView *)imageView andUrl:(NSString *)url andDefaultPic:(NSString *)pic1 errPic:(NSString *)pic2
{
    if (![url hasSuffix:@"gif"])
    {
        [[gMediaMgr rac_getImageByUrl:url withType:ImageURLTypeOrigin defaultPic:pic1 errorPic:pic2] subscribeNext:^(id x) {
            
            if (![x isKindOfClass:[UIImage class]])
                return ;
            
            [UIView transitionWithView:imageView
                              duration:1.0
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                
                                [imageView setImage:x];
                                imageView.alpha = 1.0;
                            } completion:nil];
            
        }];
    }
    else
    {
        [[gMediaMgr rac_getGifImageDataByUrl:url defaultPic:pic1 errorPic:pic2] subscribeNext:^(id x) {
            
            if ([x isKindOfClass:[NSData class]])
            {
                FLAnimatedImage * animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:x];
                [UIView transitionWithView:imageView
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    
                                    imageView.animatedImage = animatedImage;
                                    imageView.alpha = 1.0;
                                } completion:nil];
                //                imageView.animatedImage = animatedImage;
            }
            else if ([x isKindOfClass:[UIImage class]])
            {
                [UIView transitionWithView:imageView
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionCrossDissolve
                                animations:^{
                                    
                                    [imageView setImage:x];
                                    imageView.alpha = 1.0;
                                } completion:nil];
            }
        }];
    }
}



- (void)jumpToViewControllerByUrl:(NSString *)url
{
    [gAppMgr.navModel pushToViewControllerByUrl:url];
}

- (void)drawLine
{
    for (UIView * view in self.scrollView.subviews)
    {
        if ([view isKindOfClass:[FLAnimatedImageView class]])
        {
            FLAnimatedImageView *  flAnimatedImageView = (FLAnimatedImageView *)view;
            NSInteger tag = flAnimatedImageView.tag;
            if ((tag - SubModuleViewTag) % self.numOfRow != self.numOfRow - 1)
            {
                
                [flAnimatedImageView drawLineWithDirection:CKViewBorderDirectionRight withEdge:UIEdgeInsetsZero];
            }
            if ((tag - SubModuleViewTag) < (self.submoduleArray.count - self.numOfRow))
            {
                [flAnimatedImageView drawLineWithDirection:CKViewBorderDirectionBottom withEdge:UIEdgeInsetsZero];
            }
        }
    }
}



@end
