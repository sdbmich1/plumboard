// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.remotipart
//= require_tree .

$.ajaxSetup({  
  'beforeSend': function (xhr) {
  	var token = $("meta[name='csrf-token']").attr("content");
	xhr.setRequestHeader("X-CSRF-Token", token);
  	toggleLoading();
    },
  'complete': function(){ },
  'success': function() { toggleLoading }
}); 

// preview image on file upload
$(document).on("change", "input[type=file]", function(evt){
    // reset file list
    $('#list').empty();

    // render image
    if($('#usr_photo').length != 0) 
      { handleFileSelect(evt, 'usr-photo'); }
    else  
      { handleFileSelect(evt, 'thumb'); }
    return false;
}); 

// paginate on click
$(document).on("click", "#pendingOrder .pagination a", function(){
  $.getScript(this.href);
  return false;
}); 

// change active state for menu on click
$(document).on("click", "#profile-menu .nav li a", function(e){
  $('#profile-menu .nav li').removeClass('active');
  $('#profile-menu .nav li a').css('background-color', 'transparent').css('color', '#555555');

  var $this = $(this);
  if (!$this.hasClass('active')) {
    $this.parent().addClass('active');
    $this.css('background-color', '#e6e6e6').css('color', '#F95700');
  }

  e.preventDefault();
});

// set page title
function set_title(val) { 
  document.title = "Pixi | " + val;
} 

function toggleLoading () { 
  $("#spinner").toggle(); 
}

function handleFileSelect(evt, style) {
  var files = evt.target.files; // FileList object

  // Loop through the FileList and render image files as thumbnails.
  for (var i = 0, f; f = files[i]; i++) {

    // Only process image files.
    if (!f.type.match('image.*')) {
      continue;
    }

    var reader = new FileReader();

    // Closure to capture the file information.
    reader.onload = (function(theFile) {
      return function(e) {
        // Render thumbnail.
	var span = document.createElement('span');
        span.innerHTML = ['<img class="', style, '" src="', e.target.result,
		          '" title="', escape(theFile.name), '"/>'].join('');
        document.getElementById('list').insertBefore(span, null);
      };
    })(f);

    // Read in the image file as a data URL.
    reader.readAsDataURL(f);
  }
}

// used to toggle spinner
$(document).on("ajax:beforeSend", '#purchase_btn, .uform, .back-btn, #pixi-form', function () {
  toggleLoading();
});	

$(document).on("ajax:complete", '#purchase_btn, .uform, .back-btn, #pixi-form', function () {
  toggleLoading;
});	

$(document).on("ajax:success", '#purchase_btn, .uform, .back-btn, #pixi-form', function (event, data, status, xhr) {
  $("#response").html(data);
  toggleLoading;
});	

$(document).on("ajax:error", '#purchase_btn, .back-btn, #pixi-form', function (event, data, status, xhr) {
  if (status == 401) // # thrownError is 'Unauthorized'
      window.location.replace('/users/sign_in');
});	

$(document).ready(function(){

  // enable placeholder text for input fields
  if( $('#px-container').length == 0 ) {
    $('input, textarea').placeholder();
  }
  
  // picture slider
  $('.bxslider').bxSlider({
    slideMargin:10,
    pager: false,
    mode: 'fade'
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

  // used to scroll up page
  $(window).scroll(function(){
    if ($(this).scrollTop() > 100) {
      $('.scrollup').fadeIn();
    } 
    else {
      $('.scrollup').fadeOut();
    }
  }); 

  $('.scrollup').click(function(){
    $("html, body").animate({ scrollTop: 0 }, 600);
    return false;
  });

  // repaint file fields
  if( $('#list').length > 0 ) {
    SI.Files.stylizeAll();
  }

});

// use masonry to layout landing page display
$(function(){

  if( $('#px-container').length > 0 ) {
    var $container = $('#px-container');
 
    $container.imagesLoaded( function(){
      $container.masonry({
        itemSelector : '.item',
        columnWidth : 180
      });
    });

    $container.infinitescroll({
      navSelector  : '#px-nav', 		// selector for the paged navigation (it will be hidden)
      nextSelector : '#px-nav a',  // selector for the NEXT link (ie. page 2)  
      itemSelector : '#pxboard .item',           // selector for all items you'll retrieve
      animate: true,
      extraScrollPx: 50,
      bufferPx : 250,
      loading: { 
         msgText: "<em>Loading the next set of pixis...</em>",
         finishedMsg: "<em>No more pixis to load.</em>"
        }
    },

    // trigger Masonry as a callback
    function(newElements){
      var $newElems = $(newElements).css({ opacity: 0 });

      // ensure that images load before adding to masonry layout
      $newElems.imagesLoaded(function(){
        // show elems now they're ready
        $newElems.animate({ opacity: 1 });
        $container.masonry( 'appended', $newElems, true ); 
      });
    });
  }
});


