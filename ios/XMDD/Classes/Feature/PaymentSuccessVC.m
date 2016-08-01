//
//  PaymentSuccessVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/4/9.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import "PaymentSuccessVC.h"
#import "Xmdd.h"
#import "HKServiceOrder.h"
#import "SocialShareViewController.h"
#import "JTRatingView.h"
#import "SystemFastrateGetOp.h"
#import "SubmitCommentOp.h"
#import "ShopDetailVC.h"
#import "NSDate+DateForText.h"
#import "GetShareButtonOpV2.h"
#import "ShareResponeManager.h"
#import "GasVC.h"
#import "GuideStore.h"
#import "PayForWashCarVC.h"


@interface PaymentSuccessVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *recommendBtn;
@property (weak, nonatomic) IBOutlet JTRatingView *ratingView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, assign) BOOL isTextViewEdit;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *commentLb;
@property (weak, nonatomic) IBOutlet UIImageView *shopImageView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLb;
@property (weak, nonatomic) IBOutlet UILabel *serviceLb;
@property (weak, nonatomic) IBOutlet UILabel *dateLb;
@property (weak, nonatomic) IBOutlet UILabel *priceLb;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *gasCouponBtn;
@property (weak, nonatomic) IBOutlet UILabel *gasCouponLb;
@property (weak, nonatomic) IBOutlet UIView *topView;


@property (nonatomic,strong)NSArray * currentRateTemplate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offsetY1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offsetY2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offsetY3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offsetY4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *offset5;


@property (nonatomic, strong) GuideStore *guideStore;

@end

@implementation PaymentSuccessVC

- (void)dealloc
{
    DebugLog(@"PaymentSuccessVC dealloc");
}

- (void)awakeFromNib {
    self.router.disableInteractivePopGestureRecognizer = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self setupStaticInfo];
    [self setupGuideStore];

    CKAsyncMainQueue(^{
        
        [self changeCollectionHeight];
        [self changeOffset];
        [self setupRateView];
        [self setupTextView];
        [self setupUI:self.commentStatus];
        [self setupNavigationBar];
        
        [self.infoView mas_updateConstraints:^(MASConstraintMaker *make) {
           
            make.width.mas_equalTo(gAppMgr.deviceInfo.screenSize.width);
        }];
    });
    
    
    [self requestCommentlist];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


- (void)actionBack:(id)sender
{
    if (self.originVC) {
        if ([self.originVC isKindOfClass:[ShopDetailVC class]])
        {
            ShopDetailVC * vc = (ShopDetailVC *)self.originVC;
            vc.needRequestShopComments = YES;
            vc.needPopToFirstCarwashTableVC = YES;
        }
        [self.navigationController popToViewController:self.originVC animated:YES];
    }
    else {
        [super actionBack:sender];
//        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)shareAction:(id)sender {
    
    GetShareButtonOpV2 * op = [GetShareButtonOpV2 operation];
    op.pagePosition = ShareSceneCarwash;
    [[op rac_postRequest] subscribeNext:^(GetShareButtonOpV2 * op) {
        
        SocialShareViewController * vc = [commonStoryboard instantiateViewControllerWithIdentifier:@"SocialShareViewController"];
        vc.sceneType = ShareSceneCarwash;    //页面位置
        vc.btnTypeArr = op.rsp_shareBtns; //分享渠道数组
        
        MZFormSheetController *sheet = [[MZFormSheetController alloc] initWithSize:CGSizeMake(290, 200) viewController:vc];
        sheet.shouldCenterVertically = YES;
        [sheet presentAnimated:YES completionHandler:nil];
        
        [[vc.cancelBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [MobClick event:@"rp110_7"];
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        [vc setClickAction:^{
            [sheet dismissAnimated:YES completionHandler:nil];
        }];
        
    } error:^(NSError *error) {
        [gToast showError:@"分享信息拉取失败，请重试"];
    }];
}
- (IBAction)commentAction:(id)sender {
    [MobClick event:@"rp110_12"];
    
    SubmitCommentOp * op = [SubmitCommentOp operation];
    NSString * withoutSpace= [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSArray * selected = [self.currentRateTemplate arrayByFilteringOperator:^BOOL(NSString * obj) {
        
        return obj.customTag;
    }];
    NSMutableArray * array = [NSMutableArray array];
    for (NSDictionary * dict in selected)
    {
        NSString * sid = [NSString stringWithFormat:@"%@",dict[@"id"]];
        [array addObject:sid];
    }
    NSString * ids = [array componentsJoinedByString:@","];
    
    op.req_orderid = self.order.orderid;
    op.req_rating = round(self.ratingView.ratingValue);
    op.req_comment = withoutSpace;
    op.req_ids = ids;
    [[[op rac_postRequest] initially:^{
        
        [gToast showingWithText:@"提交中…"];
    }] subscribeNext:^(SubmitCommentOp *rspOp) {
        
        [gToast showSuccess:@"评价成功!"];
        self.subLabel.text = @"评价成功!";
        self.currentRateTemplate = selected;
        [self setupUI:Commented];
        self.order.ratetime = [NSDate date];
        self.order.comment = rspOp.req_comment;
        self.order.rating = rspOp.req_rating;
        self.order.ratetime = [NSDate date];
        self.collectionView.userInteractionEnabled = NO;
        self.ratingView.userInteractionEnabled = NO;

        if (self.commentSuccess)
        {
            [self commentSuccess];
        }
    } error:^(NSError *error) {
        [gToast showError:error.domain];
        
        [self setupUI:CommentError];
        self.collectionView.userInteractionEnabled = YES;
        self.ratingView.userInteractionEnabled = YES;
    }];
}


- (void)setupRateView
{
    @weakify(self)
    [[self.ratingView rac_subject] subscribeNext:^(NSNumber * number) {
        
        @strongify(self)
        NSInteger i = [number integerValue] - 1;
        self.currentRateTemplate = [gAppMgr.commentList safetyObjectAtIndex:i];
        [self changeCollectionHeight];
        [self.collectionView reloadData];
        
        [self setupUI:Commenting];
    }];
}

- (void)setupTextView
{
    self.textView.delegate = self;
    self.isTextViewEdit = NO; //输入框获取焦点的代理方法会执行两次
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.isTextViewEdit) {
        [MobClick event:@"rp110_11"];
        self.isTextViewEdit = !self.isTextViewEdit;
    }
}

- (void)setupUI:(CommentStatus)status
{
    NSInteger num = self.currentRateTemplate.count / 2 + (self.currentRateTemplate.count % 2);
    CGFloat collectionViewheight = 25 * num + 5 * (num + 1);
    CGFloat height =   280 + collectionViewheight;
    height = MAX(height, gAppMgr.deviceInfo.screenSize.height);
    CGSize scrollViewSize = CGSizeMake(gAppMgr.deviceInfo.screenSize.width, height);
    self.scrollView.contentSize = scrollViewSize;

    switch (status) {
        case BeforeComment:
        {
            self.commentLb.hidden = NO;
            self.commentLb.text = @"您的任何评价都将成为我们前进的动力";
            self.textView.hidden = YES;
            self.commentBtn.hidden = YES;
            self.recommendBtn.hidden = !gAppMgr.canShareFlag;
            self.collectionView.hidden = YES;
            break;
        }
        case Commenting:
        {
            self.commentLb.hidden = YES;
            self.textView.hidden = NO;
            self.commentBtn.hidden = NO;
            self.recommendBtn.hidden = YES;
            self.collectionView.hidden = NO;
            break;
        }
        case CommentError:
        {
            self.commentLb.hidden = YES;
            self.textView.hidden = NO;
            self.commentBtn.hidden = NO;
            self.recommendBtn.hidden = YES;
            self.collectionView.hidden = NO;
            break;
        }
        default:
        {
            self.commentLb.hidden = NO;
            self.commentLb.text = self.textView.text;
            self.textView.hidden = YES;
            self.commentBtn.hidden = YES;
            self.recommendBtn.hidden = !gAppMgr.canShareFlag;
            self.collectionView.hidden = !self.currentRateTemplate.count;
            CGFloat height = [self changeCollectionHeight];
            self.offset5.constant = height + 12;
            [self.collectionView reloadData];
            break;
        }
    }
}

- (void)setupNavigationBar
{
    UIViewController * lastVC = [self.navigationController.viewControllers safetyObjectAtIndex:self.navigationController.viewControllers.count - 2];
    BOOL flag = [lastVC isKindOfClass:[PayForWashCarVC class]];
    self.navigationItem.title = flag ? @"支付成功":@"订单评价";
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"首页" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(popToHomePage)];
    [right setTitleTextAttributes:@{
                                    NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:14.0]
                                    } forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = right;
}

- (void)setupStaticInfo
{
    [self.shopImageView setImageByUrl:[self.order.shop.picArray safetyObjectAtIndex:0]
                             withType:ImageURLTypeThumbnail defImage:@"cm_shop" errorImage:@"cm_shop"];
    self.shopNameLb.text = self.order.shop.shopName;
    self.serviceLb.text = self.order.servicename;
    self.dateLb.text = [[NSDate date] dateFormatForYYYYMMddHHmm];
    self.priceLb.attributedText = [self priceStringWithPrice:@(self.order.fee)];
    
    self.topViewConstraint.constant = self.order.gasCouponAmount > 0 ? 70 : 0;
    self.topView.hidden = !self.order.gasCouponAmount;
    
    self.gasCouponLb.text = [NSString stringWithFormat:@"加油券%@元",[NSString formatForPrice:self.order.gasCouponAmount]];
    self.gasCouponBtn.layer.borderColor = [UIColor colorWithHex:@"#35cb26" alpha:1.0f].CGColor;
    self.gasCouponBtn.layer.borderWidth = 0.5;
    [self.gasCouponBtn makeCornerRadius:2.0f];
    @weakify(self)
    [[self.gasCouponBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        
        [MobClick event:@"rp110_13"];
        @strongify(self)
        [self jumpToGas];
    }];
}

#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger num = self.currentRateTemplate.count / 2 + (self.currentRateTemplate.count % 2);
    return num;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num;
    NSInteger numOfSections = self.currentRateTemplate.count / 2 + (self.currentRateTemplate.count % 2);
    if (section < numOfSections - 1)
    {
        num = 2;
    }
    else
    {
        num = self.currentRateTemplate.count % 2 ? self.currentRateTemplate.count % 2 : 2;
    }
    return num;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = floor((self.view.frame.size.width - 80) / 2);
    CGFloat height = 25.0f / 120.0f  * width;
    return CGSizeMake(width, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    UIImageView * imgV = (UIImageView *)[cell searchViewWithTag:20101];
    UILabel * lb = (UILabel *)[cell searchViewWithTag:20102];
    
    NSDictionary * d = [self.currentRateTemplate safetyObjectAtIndex:indexPath.section * 2 + indexPath.row];
    lb.text = d[[d.allKeys safetyObjectAtIndex:0]];
    
    imgV.image = d.customTag ? [UIImage imageNamed:@"gouzi_orange"]:[UIImage imageNamed:@"gouzi_gray"];
    lb.textColor = d.customTag ? [UIColor colorWithHex:@"#ffa800" alpha:1.0f]:[UIColor darkGrayColor];
    if (d.customTag)
    {
        cell.contentView.layer.borderWidth = 0.5f;
        cell.contentView.layer.borderColor = [UIColor colorWithHex:@"#ffa800" alpha:1.0f].CGColor;
        cell.contentView.layer.cornerRadius = 4.0;
        cell.contentView.layer.masksToBounds = YES;
    }
    else
    {
        cell.contentView.layer.borderWidth = 0;
        cell.contentView.layer.masksToBounds = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [MobClick event:@"rp110_10"];
    NSDictionary * d = [self.currentRateTemplate safetyObjectAtIndex:indexPath.section * 2 + indexPath.row];
//    NSString * s = d[[d.allKeys safetyObjectAtIndex:0]];
    d.customTag =  !d.customTag;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    
    
}


#pragma mark - Utility
- (CGFloat)changeCollectionHeight
{
    CGFloat width = floor((self.view.frame.size.width - 80) / 2);
    CGFloat itemHeight = 25.0f / 120.0f * width;
    NSInteger num = self.currentRateTemplate.count / 2 + (self.currentRateTemplate.count % 2);
    CGFloat height = itemHeight * num + 5 * (num + 1);
    self.heightConstraint.constant = height;
    
    CGSize size = self.collectionView.contentSize;
    size.height = height;
    size.width = gAppMgr.deviceInfo.screenSize.width;
    self.collectionView.contentSize = size;

    return height;
}

- (void)changeOffset
{
    CGFloat deviceHeight = gAppMgr.deviceInfo.screenSize.height;
    CGFloat radio = deviceHeight / 480 * 2;
    self.offsetY1.constant =  self.offsetY1.constant * radio;
    self.offsetY2.constant =  self.offsetY2.constant * radio;
//    self.offsetY3.constant =  self.offsetY3.constant * radio;
//    self.offsetY4.constant =  self.offsetY4.constant * radio;
}

- (void)requestCommentlist
{
    if (gAppMgr.commentList.count)
    {
        for (NSArray * template in gAppMgr.commentList)
        {
            for (NSObject * obj in template)
            {
                obj.customTag = NO;
            }
        }
        return;
    }
    SystemFastrateGetOp * op = [SystemFastrateGetOp operation];
    [[op rac_postRequest] subscribeNext:^(SystemFastrateGetOp * op) {
        
        gAppMgr.commentList = op.rsp_commentlist;
    }];
}

- (void)searchKeyword
{
    NSString * s = self.textView.text;
    for (NSInteger i = 0; i < self.currentRateTemplate.count ; i++)
    {
        NSDictionary * d = [self.currentRateTemplate safetyObjectAtIndex:i];
        NSString * content = d[[d.allKeys safetyObjectAtIndex:0]];
        d.customTag = [s containsString:content];
        
        
        NSInteger section = i / 2;
        NSInteger row = i % 2;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
}

- (NSAttributedString *)priceStringWithPrice:(NSNumber *)price1
{
    NSMutableAttributedString *str = [NSMutableAttributedString attributedString];
    NSDictionary *attr1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    NSString * p = @"￥";
    NSAttributedString *attrStr1 = [[NSAttributedString alloc] initWithString:p attributes:attr1];
    [str appendAttributedString:attrStr1];
    
    if (price1) {
        NSDictionary *attr2 = @{NSFontAttributeName:[UIFont systemFontOfSize:30]};
        NSString * p = [NSString stringWithFormat:@"%@", [NSString formatForPrice:[price1 floatValue]]];
        NSAttributedString *attrStr2 = [[NSAttributedString alloc] initWithString:p attributes:attr2];
        [str appendAttributedString:attrStr2];
    }
    return str;
}


- (void)popToHomePage
{
    [self.tabBarController setSelectedIndex:0];
    UIViewController * firstTabVC = [self.tabBarController.viewControllers safetyObjectAtIndex:0];
    [self.tabBarController.delegate tabBarController:self.tabBarController didSelectViewController:firstTabVC];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)jumpToGas
{
    GasVC *vc = [UIStoryboard vcWithId:@"GasVC" inStoryboard:@"Gas"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setupGuideStore
{
    // 新手未登录，一键洗车，商户详情，登录，普洗完成，回到首页 不弹出引导。
    self.guideStore = [GuideStore fetchOrCreateStore];
    [self.guideStore setNewbieGuideAlertAppeared];
}


@end
