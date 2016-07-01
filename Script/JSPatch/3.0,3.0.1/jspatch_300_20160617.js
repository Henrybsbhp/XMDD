require('JPEngine').addExtensions(['JPMacroSupport'])
require('CKDict')
require('UITableViewCell')
require('NSIndexPath')

defineClass('GasNormalVC',{

  needInvoice:function()
  {
    return self.datasource().objectAtIndex(0).objectForKeyedSubscript("WantInvoiceCell").objectForKeyedSubscript("bill")
  };

    wantInvoiceItem: function() {

      var dict = require('NSMutableDictionary').dictionary();
      dict.setObject_forKey("WantInvoiceCell","__itemkey");
      dict.setObject_forKey(require('NSNumber').numberWithInt(0),"bill");
      var item = CKDict.dictWith(dict);

      var prepareBlock = function(data,cell,indexPath)
      {
          var invoiceBtn = cell.viewWithTag(101);
          var tagLb = cell.viewWithTag(103);
          var invoiceView;
          if (!invoiceBtn.customObject())
          {
              invoiceView = require('UIView').alloc().initWithFrame({x:12, y:12, width:16, height:16});
              invoiceView.setBackgroundColor(cell.backgroundColor());
              invoiceView.setUserInteractionEnabled(false);
              invoiceBtn.addSubview(invoiceView);
              invoiceBtn.setCustomObject(invoiceView);
          }
          else
          { 
              invoiceView = invoiceBtn.customObject();
          }
          invoiceBtn.rac__signalForControlEvents(1<<6).takeUntil(cell.rac__prepareForReuseSignal()).subscribeNext(block("UIButton *",function(x){

            if (data.objectForKeyedSubscript("bill")  == 1)
            {
              data.setObject_forKeyedSubscript(require('NSNumber').numberWithInt(0),"bill")
            }
            else
            {
              data.setObject_forKeyedSubscript(require('NSNumber').numberWithInt(1),"bill")
            }
            data.setForceReload(!data.forceReload());
          }));

          item.rac__valuesForKeyPath_observer("forceReload",self).takeUntil(cell.rac__prepareForReuseSignal()).subscribeNext(block("NSNumber *",function(x){

              require('UIImage');
              var bill = data.objectForKeyedSubscript("bill");
              tagLb.setHidden(!bill);
              invoiceView.setHidden(bill);
              var image = bill ? UIImage.imageNamed("checkbox_selected") : UIImage.imageNamed("checkbox_normal");
              invoiceBtn.setImage_forState(image, 0);
          }));
      };

      item.setObject_forKeyedSubscript(block("CKDict *,UITableViewCell *,NSIndexPath *", prepareBlock),"__preparecell");
      return item;

    },
});


defineClass('GasCZBVC',{

    wantInvoiceItem: function() {

      console.log("wantInvoiceItem");
      var dict = require('NSMutableDictionary').dictionary();
      dict.setObject_forKey("WantInvoiceCell","__itemkey");
      dict.setObject_forKey(require('NSNumber').numberWithInt(0),"bill");
      var item = CKDict.dictWith(dict);

      var prepareBlock = function(data,cell,indexPath)
      {
          var invoiceBtn = cell.viewWithTag(101);
          var tagLb = cell.viewWithTag(103);
          var invoiceView;
          if (!invoiceBtn.customObject())
          {
              invoiceView = require('UIView').alloc().initWithFrame({x:12, y:12, width:16, height:16});
              invoiceView.setBackgroundColor(cell.backgroundColor());
              invoiceView.setUserInteractionEnabled(false);
              invoiceBtn.addSubview(invoiceView);
              invoiceBtn.setCustomObject(invoiceView);
          }
          else
          { 
              invoiceView = invoiceBtn.customObject();
          }

          invoiceBtn.rac__signalForControlEvents(1<<6).takeUntil(cell.rac__prepareForReuseSignal()).subscribeNext(block("UIButton *",function(x){

            if (data.objectForKeyedSubscript("bill")  == 1)
            {
              data.setObject_forKeyedSubscript(require('NSNumber').numberWithInt(0),"bill")
            }
            else
            {
              data.setObject_forKeyedSubscript(require('NSNumber').numberWithInt(1),"bill")
            }
            data.setForceReload(!data.forceReload());
          }));


          item.rac__valuesForKeyPath_observer("forceReload",self).takeUntil(cell.rac__prepareForReuseSignal()).subscribeNext(block("NSNumber *",function(x){

              require('UIImage');
              var bill = data.objectForKeyedSubscript("bill");
              tagLb.setHidden(!bill);
              invoiceView.setHidden(bill);
              var image = bill ? UIImage.imageNamed("checkbox_selected") : UIImage.imageNamed("checkbox_normal");
              invoiceBtn.setImage_forState(image, 0);
          }));
      };

      item.setObject_forKeyedSubscript(block("CKDict *,UITableViewCell *,NSIndexPath *", prepareBlock),"__preparecell");
      return item;

    },
})