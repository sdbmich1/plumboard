var feature_slider;

// process slider
function load_slider(cntl) {
  if( $('.bxslider').length > 0 ) {

    // check slider length to toggle slideshow
    cntl = ($('.bxslider').children().length > 1) ? true : false;

    var slider = $('.bxslider').bxSlider({
      slideMargin: 10,
      minSlides: 2,
      auto: false,
      pager: cntl,
      pagerCustom: '.bx-pager',
      autoControls: false,
      mode: 'fade',
      onSlideAfter: function() {
        // trigger lazy to load new in-slided images
        setTimeout(function() { $(window).trigger("scroll"); }, 100);
      }
    });

    // vertically center align images in slider
    $('.bxslider-inner').each(function(){
      var height_parent = $(this).css('height').replace('px', '') * 1;
      var height_child = $('div', $(this)).css('height').replace('px', '') * 1;
      var padding_top_child = $('div', $(this)).css('padding-top').replace('px', '') * 1;
      var padding_bottom_child = $('div', $(this)).css('padding-bottom').replace('px', '') * 1;
      var top_margin = (height_parent - (height_child + padding_top_child + padding_bottom_child)) / 2;
      $(this).html('<div style="height: ' + top_margin + 'px; width: 100%;"></div>' + $(this).html());
    });

    $('.lazy').lazyload({
      effect: 'fadeIn'
    });
  }
}

// load featured band carousel
function load_featured_slider() {
  var val = set_banner_slides();
  if($('.featured').length > 0) {
    feature_slider = $('.featured').bxSlider({
      minSlides: 3,
      maxSlides: val,
      slideWidth: 180,
      slideMargin: 20,
      auto: false,
      pager: true,
      pagerCustom: '.bx-pager',
      autoControls: false,
      mode: 'horizontal',
      onSlideAfter: function() {
        // trigger lazy to load new in-slided images
        setTimeout(function() { $(window).trigger("scroll"); }, 100);
      }
    });
    scrollEverySecond();

    $('.lazy').lazyload({
      effect: 'fadeIn'
    });
  }
}

// trigger lazy to load every image after the first one when slider is loaded
function scrollEverySecond() {
  setTimeout(function() {
    $(window).trigger("scroll");
    scrollEverySecond();
  }, 1000);
}