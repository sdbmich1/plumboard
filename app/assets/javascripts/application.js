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
//= require jquery.ui.all
//= require bootstrap
//= require jquery.remotipart
//= require_tree .

$.ajaxSetup({  
  'beforeSend': function (xhr) {
  	var token = $("meta[name='csrf-token']").attr("content");
	xhr.setRequestHeader("X-CSRF-Token", token);
  	toggleLoading();
    },
  'complete': function(){ toggleLoading(); },
  'success': function() { toggleLoading(); }
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
$(document).on("click", "#pendingOrder .pagination a, #post_form .pagination a, #comment-list .pagination a", function(){
  toggleLoading();
  $.getScript(this.href);
  return false;
}); 

// clear active state
function reset_menu_state($this, hFlg) {
  $('#profile-menu .nav li').removeClass('active');
  $('#li_home, #profile-menu .nav li a').css('background-color', 'transparent').css('color', '#555555');

  if (!$this.hasClass('active')) {
    $this.parent().addClass('active');
    $this.css('background-color', '#e6e6e6').css('color', '#F95700');
  }

  if (hFlg) { 
      $this.addClass('active');
      $this.css('color', '#F95700');
    }
}

// change active state for menu on click
$(document).on("click", "#profile-menu .nav li a", function(e){
  var $this = $(this);
  reset_menu_state($this, false);

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
$(document).on("ajax:beforeSend", '#comment-doc, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu', function () {
  toggleLoading();
});	

$(document).on("ajax:success", '.pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu', function () {
  toggleLoading();
});	

$(document).on("ajax:complete", '#comment-doc, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu', function () {
  toggleLoading();
});	

// handle 401 ajax error
$(document).ajaxError( function(e, xhr, options){
  if(xhr.status == 401)
      window.location.replace('/users/sign_in');
});	

$(document).ready(function(){

  // enable placeholder text for input fields
  if( $('#px-container').length == 0 ) {
    $('input, textarea').placeholder();
  }
  
  // picture slider
  if( $('.bxslider').length > 0 ) {
    $('.bxslider').bxSlider({
      slideMargin: 10,
      auto: true,
      autoControls: true,
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
  }

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

$(document).ready(function(){
  load_masonry();
});

// reload masonry on ajax calls
$(document).on("ajax:success", "#recent-link", function(showElem){
  reload_board(showElem);
});

// reload masonry on ajax calls to swap data
$(document).on("click", ".pixi-cat", function(showElem){
  var catid = $(this).attr("data-cat-id");
  var url = '/listings/category.js?category=' + catid;
  var newUrl = '/listings/category?page=';
  var param = '&category=' + catid;

  toggleLoading();

  // process ajax call
  $.ajax({
     url: url,
     success: function(data){

       // clear pending pages
       $(document).unbind('retrieve.infscr');

       // clear scroll data
       clearScroll(data, newUrl, param);

       // reset spinner
       toggleLoading();
    }
  });
});

// clear next page scroll data
function clearScroll(showElem, url, param) {
  var $container = $('#px-container');
  var currentUrl = url + param;

  // reload board
  reload_board(showElem);

  //call the method to destroy the current infinitescroll session.
  $container.infinitescroll('destroy');

  // reset data
  $container.data('px-nav', null);

  //reinstantiate the container
  $container.infinitescroll({                      
    pathParse: function (path, currentPage) {
      return currentUrl;
    },
    state: {                                              
      isDuringAjax: false,
      isInvalidPage: false,
      isDestroyed: false,
      isDone: false                           
    }
  });

  // initialize infinite scroll
  initScroll();

  // Re-initialize
  $container.infinitescroll({path: [$("div#px-nav").find("span.page:last").find("a:first").attr('href')+'?page='], state:{currPage:1} });
}

// reload board
function reload_board(element) {
  var $container = $('#px-container');

  $container.imagesLoaded( function(){
    $container.masonry('reload');
  });
}

// initialize infinite scroll
function initScroll() {
  var $container = $('#px-container');

  $container.infinitescroll({
      navSelector  : '#px-nav', 		// selector for the paged navigation (it will be hidden)
      nextSelector : '#px-nav a',  		// selector for the NEXT link (ie. page 2)  
      itemSelector : '#pxboard .item',          // selector for all items that's retrieve
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

// use masonry to layout landing page display
function load_masonry(){

  if( $('#px-container').length > 0 ) {
    var $container = $('#px-container');
 
    $container.imagesLoaded( function(){
      $container.masonry({
        itemSelector : '.item',
        columnWidth : 180
      });
    });

    // initialize infinite scroll
    initScroll();
  }
}

// check for text display toggle
$(document).on("click", ".moreBtn, #more-btn", function(){
  $('.content').hide('fast');
  $('#fcontent, .fcontent').show('fast') 
});	

// calc invoice amount
function calc_amt(){
  var qty = $('#inv_qty').val();
  var price = $('#inv_price').val();
  var tax = $('#inv_tax').val();

  if (qty.length > 0 && price.length > 0) {
    var amt = parseInt(qty) * parseFloat(price);
    $('#inv_amt').val(amt.toFixed(2)); 

    // calc tax
    if (tax.length > 0) {
      var tax_total = amt * parseFloat(tax)/100;
    }
    else {
      var tax_total = 0.0;
    }

    // update tax total
    $('#inv_tax_total').val(tax_total.toFixed(2)); 

    // set & update invoice total
    var inv_total = amt + tax_total;
    $('#inv_total').val(inv_total.toFixed(2)); 
  }
}

// calc invoice amt
$(document).on("change", "#inv_qty, #inv_price, #inv_tax", function(){
  calc_amt();
});

// get pixi price based selection of pixi ID
$(document).on("change", "select[id*=pixi_id]", function() {
  var pid = $(this).val();
  var url = '/invoices/get_pixi_price?pixi_id=' + pid;

  // process script
  processUrl(url);
});

// process url calls
function processUrl(url) {
  $.ajax({
        url: url,
	dataType: 'script'
  });
}

// set autocomplete to accept images
$( "input#buyer_name" ).autocomplete({ html: true });

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#buyer_name", function(event, data){
  var bname = data.item.first_name + ' ' + data.item.last_name;
  $('#buyer_name').val(bname);
});

// submit contact form on enter key
$(document).on("keypress", "#contact_content", function(e){
  if (e.keyCode == 13 && !e.shiftKey) {
    e.preventDefault();
    $('#contact-btn').click();
  }
});

var keyPress = false; 

// submit comment form on enter key
$(document).on("keypress", "#comment_content", function(e){
  if (e.keyCode == 13 && !e.shiftKey && !keyPress) {
    keyPress = true;
    e.preventDefault();
    $('#comment-btn').click();
  }
});

// initialize infinite scroll
function commentScroll() {
  var $container = $('.posts');

  $container.infinitescroll({
      navSelector  : '#comment-nav', 		// selector for the paged navigation (it will be hidden)
      nextSelector : '#comment-nav a',  		// selector for the NEXT link (ie. page 2)  
      itemSelector : '#pxboard .item',          // selector for all items that's retrieve
      animate: true,
      extraScrollPx: 50,
      bufferPx : 250,
      loading: { 
         msgText: "<em>Loading the next set of comments...</em>",
         finishedMsg: "<em>No more comments to load.</em>"
        }
  });
}
