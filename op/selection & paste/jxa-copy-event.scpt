JsOsaDAS1.001.00bplist00?Vscript_u'use strict';

function clickCopy(se) {

  const process = se.applicationProcesses.whose({frontmost: true})[0];

  try {
    const copyBtn = process.menuBars[0].menuBarItems.byName('Edit')
      .menus[0].menuItems.byName('Copy');
	  
    const copyEnabled = copyBtn.enabled();
	
    if (copyEnabled) {
      const copyBtnIsSubmenu = copyBtn.entireContents().length != 0;
      if (copyBtnIsSubmenu) {
        const newCopyBtn = copyBtn.menus[0].menuItems.byName('Copy');
        const newCopyEnabled = newCopyBtn.enabled();
	    if (newCopyEnabled) {
	      newCopyBtn.click();
	      return "copy-success";
	    } else {
	      return "copy-disabled";
	    }
      } else {
        copyBtn.click();
	    return "copy-success";
      }
    } else {
      return "copy-disabled";
    }
  } catch {
    return "copy-failed";
  }
}

var se = Application("System Events");

clickCopy(se);                              ? jscr  ??ޭ