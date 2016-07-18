//
//  PickCarVC.m
//  XiaoMa
//
//  Created by 刘亚威 on 16/4/7.
//  Copyright © 2016年 huika. All rights reserved.
//

#import "PickCarVC.h"
#import "MyCarStore.h"
#import "EditCarVC.h"

@interface PickCarVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UILabel *carNumLabel;
- (IBAction)joinAction:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic, strong) MyCarStore *carStore;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic, assign) NSInteger checkIndex;


@property (nonatomic, strong) UIButton *addCarBtn;

///是否显示底部区域，和.h文件中的一样。这个是loading的时候用来判断
@property (nonatomic)BOOL showBottomView;

@end

@implementation PickCarVC

-(void)dealloc
{
    DebugLog(@"PickCarVC dealloc~~~~");
}

- (void)awakeFromNib
{
    _model = [[MyCarListVModel alloc] init];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpUI];
    [self setupCarStore];
    [[self.carStore getAllCars] send];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setUpUI
{
    self.bottomView.hidden = !(self.isShowBottomView && self.showBottomView);
    self.bottomConstraint.constant = (self.isShowBottomView && self.showBottomView) ? 70 : 0;
}

- (void)setupCarStore
{
    self.carStore = [MyCarStore fetchOrCreateStore];
    
    @weakify(self);
    [self.carStore subscribeWithTarget:self domain:@"cars" receiver:^(CKStore *store, CKEvent *evt) {
        @strongify(self);
        [self reloadDataWithEvent:evt];
    }];
}

- (void)reloadDataWithEvent:(CKEvent *)evt
{
    @weakify(self);
    [[[[evt.signal deliverOn:[RACScheduler mainThreadScheduler]] initially:^{
        
        @strongify(self);
        self.tableView.hidden = YES;
        [self.view hideDefaultEmptyView];
        [self.view startActivityAnimationWithType:GifActivityIndicatorType];
        [self removeEmptyBtn];
    }] finally:^{
        [self.view stopActivityAnimation];
    }] subscribeNext:^(id x) {
        
        @strongify(self);
        self.datasource = [self.carStore.cars allObjects];
        
        if (self.datasource.count == 0) {
            self.carNumLabel.text = @"";
            self.tableView.hidden = YES;
            [self addEmptyBtn];
            self.showBottomView = NO;
            [self setUpUI];
        }
        else {
            [self removeEmptyBtn];
            self.showBottomView = YES;
            [self setUpUI];
            if (self.defaultCar){
                self.checkIndex = [self.datasource indexOfObject:self.defaultCar];
                self.carNumLabel.text = self.defaultCar.licencenumber;
                self.model.selectedCar = self.defaultCar;
            }
            else {
                self.checkIndex = 100;
                self.carNumLabel.text = @"";
            }
            self.tableView.hidden = NO;
        }
        [self.tableView reloadData];
    } error:^(NSError *error) {
        
        @strongify(self);
        [gToast showError:error.domain];
        
        [self.view showImageEmptyViewWithImageName:@"def_failConnect" text:@"获取爱车信息失败，点击重试" tapBlock:^{
            @strongify(self);
            [[self.carStore getAllCars] send];
        }];
    }];
}

#pragma mark TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.datasource.count < 5) {
        return self.datasource.count + 1;
    }
    return self.datasource.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell;
    if (indexPath.row < self.datasource.count) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"CarCell"];
        UIImageView * brandImageV = [cell.contentView viewWithTag:1001];
        UILabel * licensenoL = [cell.contentView viewWithTag:1002];
        UILabel * brandLabel = [cell.contentView viewWithTag:1003];
        UIImageView * checkImageV = [cell.contentView viewWithTag:1004];
        
        HKMyCar *car = [self.datasource safetyObjectAtIndex:indexPath.row];
        
        [brandImageV setImageByUrl:car.brandLogo withType:ImageURLTypeOrigin defImage:@"mins_def" errorImage:@"mins_def"];
        licensenoL.text = car.licencenumber;
        NSString *brandAndSeries = [NSString stringWithFormat:@"%@ %@", car.brand, car.seriesModel.seriesname];
        brandLabel.text = brandAndSeries;
        checkImageV.hidden = self.checkIndex == indexPath.row ? NO : YES;
    }
    else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"AddCarCell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.datasource.count) {
        if (self.isShowBottomView) {
            self.checkIndex = indexPath.row;
            self.model.selectedCar = [self.datasource safetyObjectAtIndex:indexPath.row];
            self.carNumLabel.text = self.model.selectedCar.licencenumber;
            [self.tableView reloadData];
        }
        else {
            HKMyCar *car = [self.datasource safetyObjectAtIndex:indexPath.row];
            self.model.selectedCar = car;
            
            //如果爱车信息不完整
            if (self.model.selectedCar && ![self.model.selectedCar isCarInfoCompleted]) {
                
                HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
                alert.topTitle = @"温馨提示";
                alert.imageName = @"mins_bulb";
                alert.message = @"您的爱车信息不完整，信息不完善的车辆将无法进行洗车，协办等服务，是否现在完善？";
                @weakify(self);
                HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃" color:kGrayTextColor clickBlock:^(id alertVC) {
                    @strongify(self);
                    if (self.model.originVC) {
                        [self.navigationController popToViewController:self.model.originVC animated:YES];
                    }
                    else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
                HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"去完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                    @strongify(self);
                    [MobClick event:@"rp104_9"];
                    EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                    vc.originCar = self.model.selectedCar;
                    vc.model = self.model;
                    [self.navigationController pushViewController:vc animated:YES];
                }];
                alert.actionItems = @[cancel, improve];
                [alert show];
                return;
            }
            
            if (self.finishPickCar) {
                self.finishPickCar(self.model, self.view);
            }
            if (self.model.originVC) {
                [self.navigationController popToViewController:self.model.originVC animated:YES];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    else {
        EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
        [vc.model setFinishBlock:^(HKMyCar *car) {
            self.checkIndex = [self.datasource indexOfObject:car];
            self.carNumLabel.text = car.licencenumber;
            self.model.selectedCar = car;
            [self.tableView reloadData];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (IBAction)joinAction:(id)sender {
    if (self.model.selectedCar) {
        
        //如果爱车信息不完整
        if (self.model.allowAutoChangeSelectedCar && self.model.selectedCar && ![self.model.selectedCar isCarInfoCompleted]) {
            
            HKImageAlertVC *alert = [[HKImageAlertVC alloc] init];
            alert.topTitle = @"温馨提示";
            alert.imageName = @"mins_bulb";
            alert.message = @"您的爱车信息不完整，信息不完善的车辆将无法进行洗车，协办等服务，是否现在完善？";
            @weakify(self);
            HKAlertActionItem *cancel = [HKAlertActionItem itemWithTitle:@"放弃" color:kGrayTextColor clickBlock:^(id alertVC) {
                @strongify(self);
                if (self.model.originVC) {
                    [self.navigationController popToViewController:self.model.originVC animated:YES];
                }
                else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
            HKAlertActionItem *improve = [HKAlertActionItem itemWithTitle:@"去完善" color:HEXCOLOR(@"#f39c12") clickBlock:^(id alertVC) {
                @strongify(self);
                [MobClick event:@"rp104_9"];
                EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
                vc.originCar = self.model.selectedCar;
                vc.model = self.model;
                [self.navigationController pushViewController:vc animated:YES];
            }];
            alert.actionItems = @[cancel, improve];
            [alert show];
            return;
        }
        
        if (self.finishPickCar) {
            self.finishPickCar(self.model, self.view);
        }
    }
    else {
        [gToast showText:@"请先选择爱车"];
    }
}

-(void)removeEmptyBtn
{
    NSArray *subViews = self.view.subviews;
    [self.view hideDefaultEmptyView];
    if ([subViews containsObject:self.btn])
    {
        [self.btn removeFromSuperview];
    }
}

-(void)addEmptyBtn
{
    //暂停动画并且显示缺省页
    @weakify(self)
    [self.view stopActivityAnimation];
    [self.view showEmptyViewWithImageName:@"def_withoutCar" text:@"暂无爱车" centerOffset:-100 tapBlock:nil];
    [self.view addSubview:self.btn];
    const CGFloat top = gAppMgr.deviceInfo.screenSize.height / 2 + 30;
    [self.btn mas_updateConstraints:^(MASConstraintMaker *make) {
        @strongify(self);
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(top);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(50);
    }];
}

-(UIButton *)btn
{
    if (!_addCarBtn)
    {
        _addCarBtn = [[UIButton alloc]init];
        _addCarBtn.backgroundColor = kDefTintColor;
        [_addCarBtn setTitle:@"添加爱车" forState:UIControlStateNormal];
        _addCarBtn.layer.cornerRadius = 5;
        _addCarBtn.layer.masksToBounds = YES;
        @weakify(self);
        [[_addCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(id x) {
            @strongify(self);
            
            EditCarVC *vc = [UIStoryboard vcWithId:@"EditCarVC" inStoryboard:@"Car"];
            [vc.model setFinishBlock:^(HKMyCar *car) {
                self.checkIndex = [self.datasource indexOfObject:car];
                self.carNumLabel.text = car.licencenumber;
                self.model.selectedCar = car;
                [self.tableView reloadData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _addCarBtn;
}

@end
