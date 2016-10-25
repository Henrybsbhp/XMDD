//
//  HomePageModuleModel.m
//  XMDD
//
//  Created by fuqi on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "HomePageModuleModel.h"
#import "FLAnimatedImageView.h"
#import "HomePicModel.h"
#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "GetSystemHomeModuleOp.h"
#import "GetSystemHomeModuleNoLoginOp.h"

#define SubModuleViewTag 20101

@interface HomePageModuleModel ()

// 九宫格按钮的dispoable数据，控制点击事件释放
@property (nonatomic, strong)NSMutableArray * disposableArray;
@property (nonatomic)CGFloat itemWidth;
@property (nonatomic)CGFloat itemHeight;

@end

@implementation HomePageModuleModel

- (void)refreshSquareView:(UIView *)containView
{
    for (RACDisposable * disposable in self.disposableArray)
    {
        [disposable dispose];
    }
    [self.disposableArray removeAllObjects];
    
    for (NSInteger i = 0; i < self.moduleArray.count; i++)
    {
        HomeItem *item = [self.moduleArray safetyObjectAtIndex:i];
        NSInteger itemTag = 20101 + i;
        FLAnimatedImageView * itemView = (FLAnimatedImageView *)[containView searchViewWithTag:itemTag];
        
        if (itemView)
        {
            [self refreshExistItemView:itemView andItem:item andIndex:i];
        }
        else
        {
            [self mainButtonWithSubmudule:item
                                    index:i
                              inContainer:containView
                                    width:self.itemWidth
                                   height:self.itemHeight];
        }
        
    }
    /// 如果少于制定个数，把多余的隐藏
    for (UIView * view in containView.subviews)
    {
        if ([view isKindOfClass:[FLAnimatedImageView class]])
        {
            NSInteger itemTag = view.tag;
            if ((itemTag - 20101) >= self.moduleArray.count)
            {
                view.hidden = YES;
            }
        }
    }
}

- (void)setupSquaresViewWithContainView:(UIView *)containView andItemWith:(CGFloat)width andItemHeigth:(CGFloat)height
{
    self.itemWidth = width;
    self.itemHeight = height;
    for (NSInteger i = 0; i < self.moduleArray.count; i++)
    {
        HomeItem *item = [self.moduleArray safetyObjectAtIndex:i];
        
        [self mainButtonWithSubmudule:item index:i inContainer:containView width:width height:height];
    }
}

- (UIImageView *)mainButtonWithSubmudule:(HomeItem *)item index:(NSInteger)index inContainer:(UIView *)container width:(CGFloat)width height:(CGFloat)height
{
    NSInteger tag = 20101;
    FLAnimatedImageView * itemView = [self functionalButtonWithImageName:item.defaultImageName action:nil inContainer:container andPicUrl:item.homeItemPicUrl];
    itemView.userInteractionEnabled = YES;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    [itemView addGestureRecognizer:tapGesture];
    itemView.tag = tag + index;
    
    NSInteger quotient = index / self.numOfColumn;
    NSInteger remiainder = index % self.numOfColumn;
    
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        make.top.equalTo(container).offset(height * quotient);
        make.left.equalTo(container).offset(width * remiainder);
    }];
    
    NSInteger iconTag = 2010101 + index;
    UIImageView * iconImageView = [[UIImageView alloc] init];
    iconImageView.tag = iconTag;
    [itemView addSubview:iconImageView];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        CGFloat width = 30 * gAppMgr.deviceInfo.screenSize.width / 375;
        CGFloat height = width * 14 / 30;
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
        make.top.equalTo(itemView).offset(6);
        make.right.equalTo(itemView).offset(-6);
    }];
    
    BOOL isNewFlag = ((![gAppMgr getElementReadStatus:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]]) && item.isNewFlag);
    BOOL isHotFlag = item.isHotFlag;
    NSString * iconImageName = isHotFlag ? @"hp_hot_icon_330" : @"hp_new_icon_330";
    iconImageView.image = [UIImage imageNamed:iconImageName];
    iconImageView.hidden = (!isNewFlag) && (!isHotFlag);
    
    RACDisposable * disposable = [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        
        [self tapGestureSubscribeWith:item andIconImageView:iconImageView andIndex:index];
    }];
    
    [self.disposableArray safetyAddObject:disposable];
    
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

- (void)tapGestureSubscribeWith:(HomeItem *)item andIconImageView:(UIImageView *)iconImageView andIndex:(NSInteger)i
{
    
    if (self.mobBaseEvent.length && self.mobBaseKey.length) {
        NSString * eventstr = [NSString stringWithFormat:@"fun_%ld", (long)i];
        [MobClick event:self.mobBaseEvent attributes:@{self.mobBaseKey:eventstr}];
    }
    else
    {
        DebugLog(@"这个页面的mobBaseEvent,mobBaseKey为空,请务必补充");
    }
    
    [self jumpToViewControllerByUrl:item.homeItemRedirect];
    
    // 把new标签设置回去
    if (![gAppMgr getElementReadStatus:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]] && item.isNewFlag)
    {
        [gAppMgr saveElementReaded:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]];
        /// 是否展示根据hot标记
        BOOL isNewFlag = NO;
        BOOL isHotFlag = item.isHotFlag;
        NSString * iconImageName = isHotFlag ? @"hp_hot_icon_330" : @"hp_new_icon_330";
        iconImageView.image = [UIImage imageNamed:iconImageName];
        iconImageView.hidden = (!isNewFlag) && (!isHotFlag);
    }
}

- (void)jumpToViewControllerByUrl:(NSString *)url
{
    [gAppMgr.navModel pushToViewControllerByUrl:url];
}

- (void)refreshExistItemView:(FLAnimatedImageView *)itemView andItem:(HomeItem *)item andIndex:(NSInteger)i
{
    itemView.hidden = NO;
    NSInteger iconNewTag = 2010101 + i;
    UIImageView * iconImageView = (UIImageView *)[itemView searchViewWithTag:iconNewTag];
    BOOL isNewFlag = ((![gAppMgr getElementReadStatus:[NSString stringWithFormat:@"%@%@",HomeSubmuduleReadedKey,item.homeItemId]]) && item.isNewFlag);
    BOOL isHotFlag = item.isHotFlag;
    NSString * iconImageName = isHotFlag ? @"hp_hot_icon_330" : @"hp_new_icon_330";
    iconImageView.image = [UIImage imageNamed:iconImageName];
    iconImageView.hidden = (!isNewFlag) && (!isHotFlag);
    
    [self requestHomePicWithBtn:itemView andUrl:item.homeItemPicUrl andDefaultPic:item.defaultImageName errPic:item.defaultImageName];
    
    //先移除手势
    for (UIGestureRecognizer *recognizer in itemView.gestureRecognizers) {
        [itemView removeGestureRecognizer:recognizer];
    }
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] init];
    RACDisposable * disposable = [[tapGesture rac_gestureSignal] subscribeNext:^(id x) {
        
        [self tapGestureSubscribeWith:item andIconImageView:iconImageView andIndex:i];
    }];
    [itemView addGestureRecognizer:tapGesture];
    [self.disposableArray safetyAddObject:disposable];
}


@end
