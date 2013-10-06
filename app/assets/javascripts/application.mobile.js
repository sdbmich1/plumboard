$(document).on('pageinit', '#app', function() {
  if ($('.fld').length > 0){ 
    $(".fld").css('background-color', '#FFF');
  }

  // repaint file fields
  if( $('.cabinet').length > 0 ) {
    SI.Files.stylizeAll();
  }
});

$(document).on('pageshow', '#app', function() {

  // load board on doc ready
  if( $('#px-container').length > 0 ) {
    // uiLoading(true);
    resetBoard();
  }
});

function goToUrl(url, rFlg) {
  $.mobile.changePage( url, { transition: "none", reverse: false, reloadPage: rFlg, changeHash: false });
}

$(document).on('pageinit', '#listapp', function() {

  // initialize infinite scroll
  if( $('#px-container').length > 0 ) {
    initScroll('#px-container', '#px-nav', '#px-nav a', '#pxboard .item', null); 
  }
});

$(document).on('pageinit', '#formapp', function() {

  // initialize slider
  load_slider(false);

  // set tab
  if( $('#show-pixi').length > 0 ) {
    $('#show-pixi').addClass('ui-btn-active');
  }
});

// hide form btn
function hide_btn() {

  if( $('#comment-btn').length > 0 ) {
    $("#comment-btn").parent().hide();
  }

  if( $('#contact-btn').length > 0 ) {
    $("#contact-btn").parent().hide();
  }
}

// force pages to be refresh
$(document).on('pagehide', 'div', function(event, ui) {
  var page = $(event.target);

  if(page.attr('data-cache') == 'never'){
    page.remove();
  };
});

// remove header icons
$(document).ready(function(){
  $('a[data-theme="app-bar"], a[data-theme="app-loc"]').find('.ui-icon').remove();
});

// toggle page display
$(document).on('click', '#loc-nav', function(e) {
  reset_top('#pixi-loc', '#cat-top, #px-search');
});

// toggle menu state
$(document).on('click', '#cat-nav', function(e) {
  reset_top('#cat-top', '#pixi-loc, #px-search');
});

// toggle menu state
$(document).on('click', '#search-nav', function(e) {
  reset_top('#px-search', '#pixi-loc, #cat-top');
});

// toggle menu state
$(document).on('click', '#home-link', function(e) {
  reset_top('#px-search', '#pixi-loc, #cat-top, #px-search');
});

function reset_top(tag, str) {
  $(tag).toggle();
  $(str).hide(300);

  if ($('#pixi-loc').is(':visible') || $('#cat-top').is(':visible') || $('#px-search').is(':visible')) {
    $(".nearby-top").css('margin-top', '40px'); }
  else {
    $(".nearby-top").css('margin-top', '0'); 	
  }
}

// toggle menu state
$(document).on('click', '#show-pixi, #show-cmt', function(e) {
  $('.item-descr, .list-ftr, #px-pix, #comment_form, #post_form').toggle();
});

// toggle spinner
function uiLoading(bool) {
  if (bool)
    $('body').addClass('ui-loading');
  else
    $('body').removeClass('ui-loading');
}

$(document).on('click', "#comment-btn, #contact-btn", function (e) {
  uiLoading(true);
  $(this).parent().attr('disabled', 'disabled');
});
