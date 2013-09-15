$(document).on('pageinit', '#app', function() {
  if ($('.fld').length > 0){ 
    $(".fld").css('background-color', '#FFF');
  }

  // repaint file fields
  if( $('.cabinet').length > 0 ) {
    SI.Files.stylizeAll();
  }

  // load board on doc ready
  if( $('#px-container').length > 0 ) {
    load_masonry('#px-nav', '#px-nav a', '#pxboard .item', 1);
    reload_board(this);
  }
});

// remove header icons
$(document).ready(function(){
  $('a[data-theme="app-bar"], a[data-theme="app-loc"]').find('.ui-icon').remove();
});

// toggle menu state
$(document).on('click', '#loc-btn', function(e) {
  $('#pixi-loc').toggle();

  if ($('#pixi-loc').is(':visible')) {
    $(".nearby-top").css('margin-top', '40px'); }
  else {
    $(".nearby-top").css('margin-top', '0'); 	
  }
});

// toggle spinner
function uiLoading(bool) {
  if (bool)
    $('body').addClass('ui-loading');
  else
    $('body').removeClass('ui-loading');
}
