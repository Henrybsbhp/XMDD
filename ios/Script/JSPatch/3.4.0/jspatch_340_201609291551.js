require('JPEngine').addExtensions(['JPMacroSupport'])
require('MyCarStore')
require('ADViewController')
require('MASConstraintMaker')
require('CKDict')

defineClass('MyCarStore',{

  defalutInfoCompletelyCar:function () {
    
  	return self.defalutCar();
  }
});

defineClass('GasVC',{

  setupADView:function () {
    
  	if (!self.adctrl())
  	{
  		var ww =  self.view().bounds().width;
  		self.setAdctrl(require('ADViewController').vcWithADType_boundsWidth_targetVC_mobBaseEvent_mobBaseEventDict(4,ww,self,"rp501_1",null));
  	}

  	
  	var weakSelf = __weak(self)
  	self.adctrl().reloadDataWithForce_completed(false,block("ADViewController *,NSArray *",function(ctrl,ads){

		var strongSelf = __strong(weakSelf);
		var header = strongSelf.headerView();

  		if (ads.count() == 0 || header.subviews().containsObject(ctrl.adView()))
  		{
			return;  			
  		}

  		var height = ctrl.adView().frame().height;
  		var originHeight = header.frame().height;
  		header.setFrame({x:0, y:0, width:strongSelf.view().frame().height, height:height+originHeight});
  		header.addSubview(ctrl.adView());
  		ctrl.adView().mas__makeConstraints(block("MASConstraintMaker *",function (make) {
  			
  			if (header)
  			{	
  				make.left().equalTo()(header);
  				make.right().equalTo()(header);
  				make.top().equalTo()(header);
  				make.height().equalTo()((height));
  			}
  		}))
  		strongSelf.tableView().setTableHeaderView(header);
  	}))
  }
});


defineClass('ViolationItemViewController',{

  setupViolationItemCell:function (violation) {
    
    var dict = require('NSMutableDictionary').dictionary();
    dict.setObject_forKey("ViolationItemCell","__itemkey");
    dict.setObject_forKey("ViolationItemCell","__cellid");
    var item = CKDict.dictWith(dict);

    var prepareBlock = function(data,cell,indexPath)
    {

      console.log("prepareBlock");
       var moneyLb = cell.viewWithTag(20101);
       var moneyText = "罚款"+violation.violationMoney().toJS()+"元";
       var moneyText2 =  violation.violationMoney().length() > 0 ? moneyText : "罚款未知";
       moneyLb.setText(moneyText2);

       var fenLb = cell.viewWithTag(20201);
       var fenText = "扣"+violation.violationScore().toJS()+"分";
       var fenText2 =  violation.violationScore().length() > 0 ? fenText : "罚款未知";
       fenLb.setText(fenText2);

       var whenLb = cell.viewWithTag(104);
       whenLb.setText(violation.violationDate());

       var whereLb = cell.viewWithTag(105);
       whereLb.setNumberOfLines(0);
       whereLb.setText(violation.violationArea());

       var whyLb = cell.viewWithTag(106);
       whyLb.setNumberOfLines(0);
       whyLb.setText(violation.violationAct());

       var handleIcon = cell.viewWithTag(103);

       if (violation.ishandled().isEqualToString("1"))
       {
          handleIcon.setImageByUrl_withType_defImage_errorImage("https://o78yed0m9.qnssl.com/violation_handled.png",0,null,null);
       }
       else
       {
          handleIcon.setImageByUrl_withType_defImage_errorImage("https://o78yed0m9.qnssl.com/violation_unhandle.png",0,null,null);
       }
    };

    var heightBlock = function(data,indexPath) {
      
      var width1 = require("AppManager").sharedManager().deviceInfo().screenSize().width - 60;
      var size1 = violation.violationArea().labelSizeWithWidth_font(width1,require("UIFont").systemFontOfSize(12));

      var width2 = require("AppManager").sharedManager().deviceInfo().screenSize().width - 45;
      var size2 = violation.violationAct().labelSizeWithWidth_font(width2,require("UIFont").systemFontOfSize(15));

      var height = 63 + size1.height + 16 + size2.height + 14;
      var height2 =  Math.ceil(height)
      console.log("heightBlock"+height2);
      return 100;
    }

    item.setObject_forKeyedSubscript(block("CKDict *,UITableViewCell *,NSIndexPath *", prepareBlock),"__preparecell");
    item.setObject_forKeyedSubscript(block("CKDict *,NSIndexPath *", heightBlock),"__getcellheight");

    if (require("AppManager").sharedManager().deviceInfo().screenSize().height > 667)
    {
      return item;
    }
    else
    {
      return self.ORIGsetupViolationItemCell(violation);
    }
  }
});