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


defineClass('HKAddressComponent',{

    
},{
  //类方法
  isEqualAddrComponent_otherAddrComponent: function(ac1,ac2) {

    console.log("isEqualAddrComponent_otherAddrComponent");
    return false;
  },
  isEqualAddrComponent_AMapAddrComponent: function(ac1,ac2) {

    console.log("isEqualAddrComponent_AMapAddrComponent");
    return false;
  },
})