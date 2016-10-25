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

defineClass('PaymentCenterViewController',{

  tableView_paymentCellForRowAtIndexPath:function(tableView,indexPath){

    var cell = self.ORIGtableView_paymentCellForRowAtIndexPath(tableView,indexPath);

    var recommendLB = cell.viewWithTag(104);
    recommendLB.makeCornerRadius(3.0);

    var dict = self.paymentArray().safetyObjectAtIndex(indexPath.row()-1);
    var channel = dict.objectForKey("paymentType");
    recommendLB.setHidden(channel != 82);

    return cell;
  }
});
