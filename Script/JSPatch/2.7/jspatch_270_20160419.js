require('JPEngine').addExtensions(['JPMacroSupport'])

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