jQuery.event.add(window, "load", adjustWindow);
jQuery.event.add(window, "resize", adjustWindow);

// used to resize window top menue
function resizeFrame() {
  //console.log('width = ' + $(window).width());
    if($(window).width() < 1024) {
      if($('#cat-wrap').length == 0) {
        $("body").addClass('no-pad');
      }
      $(".bar-top").addClass('no-mtop');
      $(".navbar").addClass('mneg-top');
      $(".navbar .navbar-fixed-top").addClass('affix');

      if($('#pixi-hdr').length > 0) {
        $(".navbar").addClass('mneg-bot');
      }
    } else {
      //console.log('ms lrg width = ' + $(window).width());
      $("body").removeClass('no-pad');
      $(".bar-top").removeClass('no-mtop');
      $(".navbar").removeClass('mneg-top');
      $(".navbar").removeClass('mneg-bot');
      $(".navbar .navbar-fixed-top").removeClass('affix');
    }
}

// adjust window 
function adjustWindow() {
  var docHeight = $(window).height();
  var footerHeight = $('#footer').height();

  if($('#cat-wrap').length > 0) {
    var footerTop = $('#footer').position().top + footerHeight;
  } else {
    var footerTop = docHeight - footerHeight;
  }
  var total = footerTop - docHeight;
  //console.log('height = ' + docHeight);
  //console.log('footerTop = ' + footerTop);

  if (footerTop > docHeight && $(window).width() < 1024) {
    //console.log('total = ' + total);
    if(navigator.userAgent.match(/msie/i)) {
      $('#footer').css('margin-top', 80+ total + 'px');
    } else {
      if($('#cat-wrap').length > 0) 
        $('#footer').css('margin-top', 120+ docHeight*5 + 'px');
    }
  }
  else {
    $('#footer').css('margin-top', 80+ docHeight + 'px');
  }
  resizeFrame();
}

