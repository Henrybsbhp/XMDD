require('JPEngine').addExtensions(['JPMacroSupport'])
require('MyCarStore')
require('ADViewController')
require('MASConstraintMaker')

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