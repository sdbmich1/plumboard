jQuery.event.add(window, "load", adjustWindow);
jQuery.event.add(window, "resize", adjustWindow);
var orig_hgt = 0;
var orig_width = 0;
var orig_win_width = 0;

// used to resize window top menu
function resizeFrame() {
  resizePixi();

  // check window width to see if resize is needed
  if($(window).width() < 1200) {
    $('#fb-btn').removeClass('span3').addClass('width240');
    $("#submenu").removeClass('.bar-top').removeClass('.mtop');
    $("#sellerName").removeClass('neg-left');
    $("#trend-pixi").removeClass('offset1').removeClass('span10');

    $('#wrap').css({'margin-top': 0 });
    $(".navbar-fixed-top").css({'margin-bottom': 0 });

    resizeSmallWindow();
    resizeSafari();

    $("#msg_Container").addClass('top5');
    $(".pixi-logo").addClass('mleft30');
    $("#slr-pic").addClass('width60');
    $("#slr-det").addClass('width320');
  } else {
    restoreWindow();
  }
}

// clear dynamic added nav menu classes
function restoreWindow() {
    $("body").removeClass('no-pad');
    $(".bar-top").removeClass('no-mtop mneg-top');
    $(".navbar").removeClass('mneg-top');
    $(".navbar-fixed-top").removeClass('affix mneg-top xneg-top big-neg-bot');
    $("#msg_Container").removeClass('top5');
    $(".pixi-logo").removeClass('mleft30');
    $('#fb-btn').addClass('span3').removeClass('width240');
    $("#sellerName").addClass('neg-left');
    $("#trend-pixi").addClass('offset1').addClass('span10');

    $('#wrap').css({'margin-top': '40px' });
    $(".navbar-fixed-top").css({'margin-bottom': '20px' });

    if($('#slr-pic').length > 0) {
      $("#slr-pic").removeClass('width60');
      $("#slr-det").removeClass('width320');
    }
}

// check if small window
function resizeSmallWindow() {
    if($(window).width() < 768) {
        if($('.navbar-fixed-top').length > 0) {
          //console.log('top menu offset: ' + $(".navbar-fixed-top").offset().top);
          if($('.navbar-fixed-top').offset().top > 20) {
            $(".navbar-fixed-top").addClass('xneg-top big-neg-bot');
	  }
	  else
            if(!navigator.userAgent.match(/firefox/i)) 
              $(".navbar-fixed-top").addClass('mneg-top big-neg-bot');
	    else
              $(".navbar-fixed-top").addClass('mneg-top');
	}
    }
}

function resizeSafari() {
    if(!navigator.userAgent.match(/safari/i)) {
      if($('#cat-wrap').length == 0) {
        $("body").addClass('no-pad');
      }

      $(".navbar").addClass('mneg-top');

      if($('#pixi-hdr').length > 0) {
        $(".bar-top").addClass('mneg-top');
      } else {
        $(".bar-top").addClass('no-mtop');
      }
    } else {
      if($('.brand').html() > 'Pixis' || $('.brand').html() > 'Categories') {
        // console.log('in pixis');
        $(".bar-top").addClass('mtop');
      }
    }
}

// adjust window 
function adjustWindow() {
  var docHeight = $(document).height();
  var winHeight = $(window).height();
  var winWidth = $(window).width();
  var footerHeight = $('#footer').height();
  var mtop;

  orig_win_width = orig_win_width == 0 ? winWidth : orig_win_width;

  if($(('#cat-wrap').length > 0 || $('#wrap').length > 0) && $('#footer').length > 0) {
    var footerTop = $('#footer').position().top + footerHeight;
  } else {
    var footerTop = winHeight - footerHeight;
  }
  var total = footerTop - winHeight;
  var ftr_total = docHeight - footerTop;

  // adjust footer so that it doesn't render atop of page content
  if (footerTop > winHeight && $(window).width() < 1024) {
    if(navigator.userAgent.match(/msie/i)) {
      mtop = 80 + total;
    } else {
      if($('#cat-wrap').length > 0) {
        mtop = (!navigator.userAgent.match(/safari/i)) ? 80 + total + docHeight : 80 + docHeight;
      }
    }
  }
  else {
    mtop = ($('#cat-wrap').length > 0) ? 120 : 80;
  }

  $('#footer').css('margin-top', mtop + 'px');
  $('.scrollup').css('margin-top', mtop + 'px');
  resizeFrame();
}

function checkMenuHgt(str) {
  var $item = $('.navbar-fixed-top');
  if($(window).width() < 1024 && $item.length > 0 && $item.height() > 45) {
    $(str).addClass('mtop'); 
  }
}

// resize pixis
function resizePixi () {
  var fname = '.featured-container .bx-wrapper .bx-viewport';
  $('img.img-board').each(function(i, item) {
    resizeElement(item, i, 200, false);
  }); 
  $('.bx-wrapper img').each(function(i, item) {
    resizeElement(item, i, 180, false);
  }); 
  if($(fname).length > 0) {
    $(fname).css({'width': set_item_size(0, true)});
  }
  /*
  $('.item.masonry-brick img').each(function(i, item) {
    resizeElement(item, i, 200, true);
  }); 
  */
}

// resize each element
function resizeElement(item, i, origSz, hFlg) {
  var img_width = $(item).width();
  var img_height = $(item).height();
  var factor = $(window).width() / orig_win_width;

  //INCREASE WIDTH OF IMAGE TO MATCH CONTAINER
  if(i==0) {
    orig_width = orig_width == 0 ? set_item_size(origSz, false) : orig_width;
    $('.item').css({'width': parseInt(orig_width*factor)});
  }
  $(item).css({'width': '100%'});

  //GET THE NEW WIDTH AFTER RESIZE
  var new_width = $(item).width();

  // set new height
  var result = orig_hgt == 0 ? img_height : orig_hgt;
  var sz = orig_hgt == 0 ? set_item_size(origSz, false) : result*factor;
  orig_hgt = orig_hgt == 0 ? sz : orig_hgt;

  //INCREASE HEIGHT OF IMAGE TO MATCH CONTAINER
  $(item).css({'height': sz });
}

// set default item size based on window size
function set_item_size (origSize, wFlg) {
  var width = $(window).width();
  var col = !wFlg ? origSize : '85%';

  if(width < 1200 && width >= 980) {
    col = !wFlg ? 160 : '80%';
  }
  else if(width < 980 && width >= 768) {
    col = !wFlg ? 140 : '75%';
  }
  else if(width < 768 && width >= 480) {
    col = !wFlg ? 120 : '70%';
  }
  else if(width < 480) {
    col = !wFlg ? 100 : '70%';
  }
  return col;
}

// set default item size based on window size
function set_banner_slides () {
  var width = $(window).width();
  var col = 5;

  if(width < 1200 && width >= 980) {
    col = 5;
  }
  else if(width < 980 && width >= 768) {
    col = 4;
  }
  else if(width < 768 && width >= 480) {
    col = 3;
  }
  else if(width < 480) {
    col = 2;
  }
  return col;
}
