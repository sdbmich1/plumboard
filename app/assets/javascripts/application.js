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
//= require jquery-ui
//= require bootstrap
//= require jquery.remotipart
//= require jquery.bxslider.min.js
//= require jquery.masonry.min.js
//= require jquery.infinitescroll.js
//= require jquery.placeholder.min.js
//= require bootstrap-datepicker.js
//= require datepicker.js
//= require map.js
//= require transaction.js
//= require payment.js
//= require si.files.js
//= require autocomplete-rails.js
//= require jquery.ui.autocomplete.html.js

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
      { handleFileSelect(evt, 'sm-thumb'); }
    return false;
}); 

// hide & reset comp field
function hideComp(){
  $('#comp-fld').hide('fast');
  $('#price-fld').show('fast');

  if($('#input-form').length > 0) {
    $('#salary').val('');
  }  
}

$(function (){
  // when the #category id field changes
  $(document).on("change", "select[id*=category_id]", function(evt){

    // grab the selected category
    var cat = $("select[id*=category_id] option:selected").text();

    // toggle field display based on category value
    if(cat == 'Event') {
      $('#event-fields').show('fast');

      // hide fields
      hideComp();
      $('#yr-fld').hide('fast');
    }
    else {
      $('#event-fields').hide('fast');

      // clear event flds
      $('#start-date, #end-date, #start-time, #end-time').val('');
      
      // check for jobs
      if(cat == 'Jobs' || cat == 'Gigs') {
        $('#price-fld, #yr-fld').hide('fast');
        $('#comp-fld').show('fast');

	// reset fields
	if($('#input-form').length > 0) {
	  $('#temp_listing_price, #yr_built').val('');
	}
      }
      else {
        hideComp();

        // check for year categories
        if(cat == 'Automotive' || cat == 'Motorcycle' || cat == 'Boats') {
          $('#yr-fld').show('fast');
        }
        else {
          $('#yr-fld').hide('fast');
        }
      }
    }

  }); 
}); 

// paginate on click
$(document).on("click", "#pendingOrder .pagination a, #post_form .pagination a, #comment-list .pagination a, #post-list .pagination a", function(){
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
      $this.addClass('active').focus();
      $('.nav li.active a').css('color', '#F95700');
  }
}

// change active state for menu on click
$(document).on("click", "#profile-menu .nav li a", function(e){
  var $this = $(this);
  reset_menu_state($this, false);

  //e.preventDefault();
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
$(document).on("ajax:beforeSend", '#mark-posts, #post-frm, #comment-doc, #site_id, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu, #cat-link', function () {
    toggleLoading();
});	

$(document).on("ajax:success", '.pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu', function () {
  toggleLoading();
});	

$(document).on("ajax:complete", '#mark-posts, #post-frm, #comment-doc, #site_id, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu, #cat-link', function () {
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
  if( $('.cabinet').length > 0 ) {
    SI.Files.stylizeAll();
  }

});

$(document).ready(function(){
  load_masonry('#px-nav', '#px-nav a', '#pxboard .item');
});

// reload masonry on ajax calls to swap data
$(document).on("click", ".pixi-cat", function(showElem){
  var cid = $(this).attr("data-cat-id");
  var loc = $('#site_id').val(); // grab the selected location 
  var url = '/listings/category.js?cid=' + cid + '&loc=' + loc;

  // process ajax call
  processUrl(url);
});

// clear next page scroll data
function clearScroll(showElem, nav, nxt, item) {
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
    state: {                                              
      isDuringAjax: false,
      isInvalidPage: false,
      isDestroyed: false,
      isDone: false                           
    }
  });

  // initialize infinite scroll
  initScroll('#px-container', nav, nxt, item);

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
function initScroll(cntr, nav, nxt, item) {
  var $container = $(cntr);

  $container.infinitescroll({
      navSelector  : nav, 		// selector for the paged navigation (it will be hidden)
      nextSelector : nxt,  		// selector for the NEXT link (ie. page 2)  
      itemSelector : item,          // selector for all items that's retrieve
      animate: true,
      extraScrollPx: 50,
      bufferPx : 250
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
function load_masonry(nav, nxt, item){

  if( $('#px-container').length > 0 ) {
    var $container = $('#px-container');
 
    $container.imagesLoaded( function(){
      $container.masonry({
        itemSelector : '.item',
        columnWidth : 180
      });
    });

    // initialize infinite scroll
    initScroll('#px-container', nav, nxt, item);
  }
}

// check for category board
$(document).on("click", "#cat-link", function(){
  var loc = $('#site_id').val(); // grab the selected location 
  var url = '/categories.js?loc=' + loc;

  // process ajax call
  processUrl(url);
});	


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
    dataType: 'script',
    'beforeSend': function() {
      toggleLoading();
    },
    'complete':  function() {  				
      toggleLoading();
    },
    'success': function() {
      toggleLoading();	
    }
  });
}

// set autocomplete to accept images
$("input#buyer_name").autocomplete({ html: true });

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

var time_id;
function set_timer() {
 time_id = setTimeout(updatePixis, 30000);  
}

// polling for recent pixis
$(function () {  
  if ($('#recent-pixis').length > 0) {  
  //  set_timer(); 
  }
  else {
    clearTimeout(time_id);
  }  
});  

// refresh recent pixis
function updatePixis() {  
  if ($('.pixi').length > 0) {  
    var after = $('.pixi:last').attr('data-time');  
  }  
  else {  
    var after = 0;  
  }

  processUrl('/pages.js?after=' + after);
  set_timer();
}  

// check for location changes
$(document).on("change", "#site_id", function() {

  // reset board
  setBoardByLocation();
  
  //prevent the default behavior of the click event
  return false;
});

// check for recent link click
$(document).on("click", "#recent-link", function() {

  // reset board
  setBoardByLocation();
  
  //prevent the default behavior of the click event
  return false;
});

// reset board pixi based on location
function setBoardByLocation() {
  var loc = $('#site_id').val(); // grab the selected location 

  // check location
  if (loc > 0) {
    var url = '/listings/location?loc=' + loc; 
  }
  else {
    var url = '/listings.js';
  }

  // refresh the page
  processUrl(url);

  // toggle menu
  var $this = $("#li_home");
  reset_menu_state($this, true);
}

$(function() {
  // Fix input element click problem
  $('.dropdown input, .dropdown label, .dropdown-menu input, .dropdown-menu select').click(function(e) {
    e.stopPropagation();
  });
});

// toggle menu post menu item
$(document).on('click', '.post-menu', function(e) {
  $('#mark-posts').toggle();
});

// toggle menu post menu item
$(document).on('click', '.home-link', function(e) {
  $('#site_id').val('').prop('selectedIndex',0);

  // toggle menu
  var $this = $("#li_home");
  reset_menu_state($this, true);
});

// toggle menu state
$(document).on('click', '#mark-posts', function(e) {
  var $this = $("#li_home");
  reset_menu_state($this, true);
});
