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
      $("#msg_Container").addClass('top5');

      $("#slr-pic").addClass('width60');
      $("#slr-det").addClass('width240');

      if($('#pixi-hdr').length > 0) {
      //  $(".navbar-fixed-top").addClass('mneg-bot');
      }
    } else {
      //console.log('ms lrg width = ' + $(window).width());
      $("body").removeClass('no-pad');

      // set nav menu classes
      $(".bar-top").removeClass('no-mtop');
      $(".navbar").removeClass('mneg-top');
      $(".navbar-fixed-top").removeClass('affix');
      $("#msg_Container").removeClass('top5');

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

  if($('#cat-wrap').length > 0) {
    var footerTop = $('#footer').position().top + footerHeight;
  } else {
    var footerTop = winHeight - footerHeight;
  }
  var total = footerTop - winHeight;
  //console.log('height = ' + winHeight);
  //console.log('docHeight = ' + docHeight);
  //console.log('footerTop = ' + footerTop);

  if (footerTop > winHeight && $(window).width() < 1024) {
    //console.log('total = ' + total);
    if(navigator.userAgent.match(/msie/i)) {
      $('#footer').css('margin-top', 80+ total + 'px');
    } else {
      if($('#cat-wrap').length > 0) 
        $('#footer').css('margin-top', 80+ docHeight + 'px');
    }
  }
  else {
    $('#footer').css('margin-top', 80+ winHeight + 'px');
  }
  resizeFrame();
}

