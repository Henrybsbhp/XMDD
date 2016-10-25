require('JPEngine').addExtensions(['JPMacroSupport'])

defineClass('SYPaginatorView',{

  scrollVisibleToCorrectView:function(){

    if (self.delegate().isKindOfClass(require("SuspendedAdVC").class()))
    { 
      return;
    }
    if (self.delegate().isKindOfClass(require("NearbyShopsViewController").class()))
    {
      return;
    }
    self.ORIGscrollVisibleToCorrectView();
  }
});