require('JPEngine').addExtensions(['JPMacroSupport'])

defineClass('ADViewController',{

  initWithADType_boundsWidth_targetVC_mobBaseEvent_mobBaseEventDict:function (type,width,vc,event,dict) {
    

    console.log("initWithADType_boundsWidth_targetVC_mobBaseEvent_mobBaseEventDict");
    self = self.super().init();
    if (self)
    {
      self.setValue_forKey(vc,"targetVC");
      self.setValue_forKey(type,"adType");
      self.setValue_forKey(event,"mobBaseEvent");
      self.setValue_forKey(dict,"mobBaseEventDict");
      self.setNavModel(require("NavigationModel").alloc().init());
      self.navModel().setCurNavCtrl(self.targetVC().navigationController());
      var height = Math.floor(width * 184.0 / 640);

      var adView = require("SYPaginatorView").alloc().initWithFrame({x:0, y:0, width:width, height:height});
      adView.setIsInfinite(true);
      adView.setDelegate(self);
      adView.setDataSource(self);
      adView.setPageGapWidth(0);
      adView.pageControl().setHidden(true);
      self.setValue_forKey(adView,"adView");

      adView.setCurrentPageIndex(0);

      var weakSelf = __weak(self)
      var dis = require("AdvertisementManager").sharedManager().rac__scrollTimerSignal().subscribeNext(block("NSOject *",function(x){

        if (!self || !adView)
        {
          return;
        }
        var index = adView.currentPageIndex() + 1;
        if (index > weakSelf.adList().count() - 1)
        {
          index = 0;
        }        
        if (index = adView.currentPageIndex())
        {
          adView.setCurrentPageIndex_animated(index,true);            
        }
      }));

      self.rac__deallocDisposable().addDisposable(dis);
    }
    return self;
  }
});


defineClass('SYPaginatorView',["isInfinite"],{

  reloadDataRemovingCurrentPage:function(removeCurrentPage) {

    console.log("reloadDataRemovingCurrentPage");
    self.__resetScrollViewContentSize();

    var numberOfPages = self.numberOfPages();
    if (self.isInfinite())
    {
      self.pageControl().setNumberOfPages(numberOfPages > 2 ? numberOfPages - 2 : numberOfPages);
    }
    else
    {
      self.pageControl().setNumberOfPages(numberOfPages);
    }

    var keysToRemove = require('NSMutableArray').alloc().init();

    console.log("reloadDataRemovingCurrentPage2");
    var pages = self.valueForKey("pages")
    console.log("reloadDataRemovingCurrentPage2 : "+ pages);
    var pagesKeys = pages.allKeys();
    for (var i=0;i<pagesKeys.count();i++)
    {

      console.log("reloadDataRemovingCurrentPage for begin ");
      var pageKey = pagesKeys.objectAtIndex(i);
      var pageValue = pages.objectForKey(pageKey);
      console.log("reloadDataRemovingCurrentPage for begin " + pageKey);
      if (removeCurrentPage ==  false && (pageKey.integerValue() == self.currentPageIndex()))
      {
        continue;
      }
      pageValue.removeFromSuperview();
      keysToRemove.addObject(pageKey);

      console.log("reloadDataRemovingCurrentPage for end ");
    }

    pages.removeObjectsForKeys(keysToRemove);

    var newIndex = self.currentPageIndex();
    if (newIndex >= numberOfPages)
    {
      newIndex = numberOfPages - 1;
    }

    console.log("reloadDataRemovingCurrentPage3");
    self.__setCurrentPageIndex_animated_scroll_forcePreload(newIndex,false,true,true);
    console.log("reloadDataRemovingCurrentPage4");
  },

  __setCurrentPageIndex_animated_scroll_scroll_forcePreload:function(targetPage,animated,scroll,forcePreload){
     console.log("_setCurrentPageIndex_animated_scroll_scroll_forcePreload");
    if (self.currentPageIndex() == targetPage && self.pageSetViaPublicMethod() == false)
    {
      return;      
    }

    if (scroll && self.delegate() && self.delegate().respondsToSelector("paginatorViewDidBeginPaging:"))
    {
      self.delegate().paginatorViewDidBeginPaging(self);
    }

    console.log("_setCurrentPageIndex_animated_scroll_scroll_forcePreload  2");
    var numberOfPages = self.numberOfPages();
    if (targetPage > numberOfPages)
    {
      targetPage = 0;
    }
    else if (targetPage >numberOfPages - 1)
    {
      targetPage = numberOfPages;
    }

    console.log("_setCurrentPageIndex_animated_scroll_scroll_forcePreload  3");
    if (self.currentPageIndex() != targetPage || self.pageForIndex(targetPage) == null || forcePreload)
    {
      self.setCurrentPageIndex(targetPage);

      if (self.isInfinite())
      {
        var numberOfPageControl = self.numberOfPages() > 2 ? self.numberOfPages() - 2 : self.numberOfPages();
        if (targetPage > numberOfPageControl)
        {
           self.pageControl().setCurrentPage(0);
        }        
        else if (targetPage == 0)
        {
          self.pageControl().setCurrentPage(numberOfPageControl - 1);
        }
        else
        {
          self.pageControl().setCurrentPage(targetPage - 1);
        }
      }  
      else
      {
          self.pageControl().setCurrentPage(targetPage);
      }    

      self.__loadPage(targetPage);
      self.__loadPagesToPreloadAroundPageAtIndex(targetPage);
    }

    console.log("_setCurrentPageIndex_animated_scroll_scroll_forcePreload  3");
    if (scroll)
    {
      var targetOffset = self.__offsetForPage(targetPage) - Math.round(self.pageGapWidth() / 2.0);
      if (self.paginationDirection() == 0)
      {
        if (self.scrollView().contentOffset().x != targetOffset)
        {
          self.scrollView().setContentOffset({x: targetOffset, y: 0},animated);
          self.setPageControlUsed(true);      
        }
      }
      else
      {
        if (self.scrollView().contentOffset().y != targetOffset)
        {
          self.scrollView().setContentOffset({x: 0, y: targetOffset},animated);
          self.setPageControlUsed(true);      
        }
      }
    }

    self.setPageSetViaPublicMethod(false);
  },

  scrollVisibleToCorrectView:function(){

    if (!self.isInfinite())
    {
      return;
    }

    console.log("scrollVisibleToCorrectView  1");
    self.ORIGscrollVisibleToCorrectView();
  }


});

