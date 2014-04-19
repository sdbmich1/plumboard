jQuery.event.add(window, "load", adjustWindow);
jQuery.event.add(window, "resize", adjustWindow);

// used to resize window top menu
function resizeFrame() {
  // check window width to see if resize is needed
  if($(window).width() < 1024) {
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
      if($('.brand').html() > 'Pixis') {
        $(".bar-top").addClass('mtop');
      }
    }

    $("#msg_Container").addClass('top5');
    $(".pixi-logo").addClass('mleft5');

    $("#slr-pic").addClass('width60');
    $("#slr-det").addClass('width240');
  } else {
    //console.log('ms lrg width = ' + $(window).width());

    // clear dynamic added nav menu classes
    $("body").removeClass('no-pad');
    $(".bar-top").removeClass('no-mtop mneg-top');
    $(".navbar").removeClass('mneg-top');
    $(".navbar-fixed-top").removeClass('affix');
    $("#msg_Container").removeClass('top5');
    $(".pixi-logo").removeClass('mleft5');

    if($('#slr-pic').length > 0) {
      $("#slr-pic").removeClass('width60');
      $("#slr-det").removeClass('width240');
    }
  }
}

// adjust window 
function adjustWindow() {
  var docHeight = $(document).height();
  var winHeight = $(window).height();
  var footerHeight = $('#footer').height();
  var mtop;

  if($('#cat-wrap').length > 0) {
    var footerTop = $('#footer').position().top + footerHeight;
  } else {
    var footerTop = winHeight - footerHeight;
  }
  var total = footerTop - winHeight;
  var ftr_total = docHeight - footerTop;

  console.log('height = ' + winHeight);
  console.log('docHeight = ' + docHeight);
  console.log('footerTop = ' + footerTop);
  console.log('ms lrg width = ' + $(window).width());
  console.log('total = ' + total);
  console.log('ftr_total = ' + ftr_total);

  // adjust footer so that it doesn't render atop of page content
  if (footerTop > winHeight && $(window).width() < 1024) {
    if(navigator.userAgent.match(/msie/i)) {
      mtop = 80 + total;
    } else {
      if($('#cat-wrap').length > 0) {
        if(!navigator.userAgent.match(/safari/i)) 
          mtop = 80 + ftr_total + docHeight;
	else
	  mtop = 80 + docHeight;
      }
    }
  }
  else {
    if($('#cat-wrap').length > 0) 
      mtop = total;
    else
      mtop = 80;
  }
  $('#footer').css('margin-top', mtop + 'px');
  $('.scrollup').css('margin-top', mtop + 'px');
  resizeFrame();
}

