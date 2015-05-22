jQuery.event.add(window, "load", adjustWindow);
jQuery.event.add(window, "resize", adjustWindow);
var orig_hgt = 0;
var orig_width = 0;
var orig_win_width = 0;

// used to resize window top menu
function resizeFrame() {
  resizePixi();

  // check window width to see if resize is needed
  if($(window).width() < 1024) {
    $('#fb-btn').removeClass('span3').addClass('width240');
    $('#wrap').css({'margin-top': 0 });
    $(".navbar-fixed-top").css({'margin-bottom': 0 });
    $("#submenu").removeClass('.bar-top').removeClass('.mtop');

    // check if small window
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
        console.log('in pixis');
        $(".bar-top").addClass('mtop');
      }
    }

    $("#msg_Container").addClass('top5');
    $(".pixi-logo").addClass('mleft30');
    $("#slr-pic").addClass('width60');
    $("#slr-det").addClass('width320');
  } else {
    //console.log('ms lrg width = ' + $(window).width());

    // clear dynamic added nav menu classes
    $("body").removeClass('no-pad');
    $(".bar-top").removeClass('no-mtop mneg-top');
    $(".navbar").removeClass('mneg-top');
    $(".navbar-fixed-top").removeClass('affix mneg-top xneg-top big-neg-bot');
    $("#msg_Container").removeClass('top5');
    $(".pixi-logo").removeClass('mleft30');
    $('#fb-btn').addClass('span3').removeClass('width240');

    $('#wrap').css({'margin-top': '40px' });
    $(".navbar-fixed-top").css({'margin-bottom': '20px' });

    if($('#slr-pic').length > 0) {
      $("#slr-pic").removeClass('width60');
      $("#slr-det").removeClass('width320');
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

  /*
  console.log('height = ' + winHeight);
  console.log('docHeight = ' + docHeight);
  console.log('footerTop = ' + footerTop);
  console.log('ms lrg width = ' + $(window).width());
  console.log('total = ' + total);
  console.log('ftr_total = ' + ftr_total);
  console.log('navbar fixed top height = ' + $('.navbar-fixed-top').height());
  */

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

function resizePixi () {
  $('img.img-board').each(function(i, item) {
    var img_width = $(item).width();
    var img_height = $(item).height();
    var factor = $(window).width() / orig_win_width;

    //INCREASE WIDTH OF IMAGE TO MATCH CONTAINER
    if(i==0) {
      orig_width = orig_width == 0 ? set_item_size() : orig_width;
      $('.item').css({'width': parseInt(orig_width*factor)});
    }
    $(item).css({'width': '100%'});

    //GET THE NEW WIDTH AFTER RESIZE
    var new_width = $(item).width();

    // set new height
    var result = orig_hgt == 0 ? img_height : orig_hgt;
    var sz = orig_hgt == 0 ? set_item_size() : result*factor;
    orig_hgt = orig_hgt == 0 ? sz : orig_hgt;

    /*
    //var factor = orig_width > new_width ? img_width / orig_width : new_width / img_width;
    //var sz = new_width > 190 ? 200 : result*factor;
    console.log('img_width = ' + img_width);
    console.log('new_width = ' + new_width);
    console.log('orig_width = ' + orig_width);
    console.log('result = ' + result);
    console.log('factor = ' + factor);
    console.log('orig_hgt = ' + orig_hgt);
    console.log('sz = ' + sz);
    */

    //INCREASE HEIGHT OF IMAGE TO MATCH CONTAINER
    $(item).css({'height': sz });
  }); 
}

// set default item size based on window size
function set_item_size () {
  var width = $(window).width();
  var col = 200;

  if(width < 1200 && width >= 980) {
    col = 160;
  }
  else if(width < 980 && width >= 768) {
    col = 140;
  }
  else if(width < 768 && width >= 480) {
    col = 120;
  }
  else if(width < 480) {
    col = 100;
  }
  return col;
}
