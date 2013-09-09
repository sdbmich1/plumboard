$(document).bind('pageinit', function() {
  if ($('.fld').length > 0){ 
    $(".fld").css('background-color', '#FFF');
  }

  // repaint file fields
  if( $('.cabinet').length > 0 ) {
    SI.Files.stylizeAll();
  }
});

