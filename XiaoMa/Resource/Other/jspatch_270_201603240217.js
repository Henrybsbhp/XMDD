require('JPEngine').addExtensions(['JPMacroSupport'])


defineClass('InsCheckResultsVC',{

    tableView_cellForRowAtIndexPath: function(tableView, indexPath) {
    	var data = self.datasource().safetyObjectAtIndex(indexPath.section()).safetyObjectAtIndex(indexPath.row());
    	var cell = tableView.dequeueReusableCellWithIdentifier_forIndexPath(data.cellID(),indexPath);
    	if (data.cellID().equalByCaseInsensitive("Uppon"))
    	{
            self.resetUpponCell_forData_atIndexPath(cell,data,indexPath);
        }
    	else if (data.cellID().equalByCaseInsensitive("Down"))
    	{
            self.resetDownCell_forData_atIndexPath(cell,data,indexPath);
    	}
    	else if (data.cellID().equalByCaseInsensitive("Fail"))
    	{
            self.resetFailCell_forData(cell,data);
    	}
    	return cell;
    },

    resetDownCell_forData_atIndexPath:function(cell,data,indexPath){
    	var line1 = cell.viewWithTag(10001);
    	var line2 = cell.viewWithTag(10002);
    	var line3 = cell.viewWithTag(10003);
    	var couponV = cell.viewWithTag(1001);

    	data = self.datasource().safetyObjectAtIndex(indexPath.section()).safetyObjectAtIndex(indexPath.row());
    	var premium =  data.object();
        console.log("xxxxxxx"+premium.couponlist());

    	line1.setLineAlignment(-1);
    	line2.setLineAlignment(-2);
    	line3.setLineAlignment(2);
    	couponV.setButtonHeight(25);
    	couponV.setCoupons(premium.couponlist().arrayByMapFilteringOperator(block("NSDictionary *",function(dict){
    		var name = dict.objectForKey("name");
             console.log("xxxxxxx"+name);
    		var desc = dict.objectForKey("desc");
            console.log("xxxxxxx"+desc);
    		name.setCustomObject(desc);
    		return name;
    	})));

    	var wself = self;
    	couponV.setButtonClickBlock(block("NSString *",function(name){

    		require("InsAlertVC").showInView_withMessage(wself.navigationController().view(),name.customObject())
    	}));
    	
        couponV.setNeedsLayout();                                                                                                                        
    }
})

defineClass('GasVC : UIViewController <UITableViewDataSource,UITableViewDelegate,RTLabelDelegate>',{

	actionPay:function (sender) {

        if (self.curModel().isEqual(self.czbModel())){

            var model = self.curModel();
            if (!model.curBankCard()){

                require("HKToast").sharedTosast().showText_inView("您需要先添加一张浙商汽车卡！",self.view());
                return;
            }
            else if (!self.curModel().curGasCard()){

                require("HKToast").sharedTosast().showText_inView("您需要先添加一张油卡！",self.view());
                return;
            }
            else if (self.curModel().curBankCard().gasInfo().rsp_availablechargeamt == 0){
                
                require("HKToast").sharedTosast().showText_inView("您本月加油已达到最大限额！",self.view());
                return;
            }
            else if (require("LoginViewModel").loginIfNeededForTargetViewController(self)){
                var vc = require("UIStoryboard").storyboardWithName_bundle("Gas",null).instantiateViewControllerWithIdentifier("GasPayForCZBVC");
                console.log("vc"+vc);
                // var vc = require("UIStoryboard").vcWithId_inStoryboard("GasPayForCZBVC","Gas");
                vc.setBankCard(model.curBankCard());
                vc.setGasCard(model.curGasCard());
                vc.setChargeamt(model.rechargeAmount());
                vc.setPayTitle(self.bottomBtn().titleForState(0));
                vc.setOriginVC(self);
                vc.setModel(model);
                self.navigationController().pushViewController_animated(vc,true);
            }
        }
        else
        {
            if (!self.curModel().curGasCard()){

                require("HKToast").sharedTosast().showText_inView("您需要先添加一张油卡！",self.view());
                return;
            }
            else if (!self.normalModel().curChargePackage().pkgid() && 
                    !(self.curModel().curGasCard().availablechargeamt() === false) &&
                    !self.curModel().curGasCard().availablechargeamt())
            {
                require("HKToast").sharedTosast().showText_inView("您本月加油已达到最大限额！",self.view());    
                return;   
            }
            if (require("LoginViewModel").loginIfNeededForTargetViewController(self)){
                
                var vc = require("UIStoryboard").vcWithId_inStoryboard("PayForGasViewController","Gas");
                vc.setOriginVC(self);
                if (self.curModel().isKindOfClass(require("GasNormalVM").class()))
                {
                    vc.setModel(self.curModel());                    
                }
                self.navigationController().pushViewController_animated(vc,true);
            }
        }
	}
})