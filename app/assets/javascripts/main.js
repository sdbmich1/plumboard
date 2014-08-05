// main.js file
//

$.ajaxSetup({  
  'beforeSend': function (xhr) {
  	var token = $("meta[name='csrf-token']").attr("content");
	xhr.setRequestHeader("X-CSRF-Token", token);
  	toggleLoading();
    },
  'complete': function(){ toggleLoading(); }
}); 

// when the #category id field changes
$(document).on("change", "select[id*=category_id]", function(evt){

  // check if pixi form
  if($('#pixi-form').length > 0) {
    var cid = $(this).val();

    if (cid.length > 0) {
      var url = '/categories/category_type?id=' + cid;

      // process script
      processUrl(url);
    }
  }
}); 

// paginate on click
var pstr = "#inq-list .pagination a, #pendingOrder .pagination a, #post_form .pagination a, #comment-list .pagination a," +
  "#post-list .pagination a, #user-list .pagination a, #inv-list .pagination a, #faq-list .pagination a, #pxp-list .pagination a";

$(document).on("click", pstr, function(){
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
});

// set page title
function set_title(val) { 
  document.title = "Pixi | " + val;
} 

function toggleLoading () { 
  $("#spinner").toggle(); 
}

// used to toggle spinner
$(document).on("ajax:beforeSend", '#mark-posts, #post-frm, #comment-doc, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu, #cat-link', function () {
    toggleLoading();
});	

$(document).on("ajax:success", '.pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu', function () {
  toggleLoading();
});	

$(document).on("ajax:complete", '#mark-posts, #post-frm, #comment-doc, .pixi-cat, #purchase_btn, #search_btn, .uform, .back-btn, #pixi-form, .submenu, #cat-link', function () {
  toggleLoading();
});	

// handle 401 ajax error
$(document).ajaxError( function(e, xhr, options){
  if(xhr.status == 401)
      console.log('in 401 status error handler');
      // window.location.replace('/users/sign_in');
      location.reload();
});	

// process slider
function load_slider(cntl) {

  // picture slider
  if( $('.bxslider').length > 0 ) {

    // check slider length to toggle slideshow
    cntl = ($('.bxslider').children().length > 1) ? true : false;

    $('.bxslider').bxSlider({
      slideMargin: 10,
      minSlides: 2,
      auto: cntl,
      pager: cntl,
      autoControls: cntl,
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
}

$(document).ready(function(){

  // enable tooltip
  if( $('.ttip').length > 0 ) {
    $('a').tooltip();
  }
  // set location
  if( $('#home_site_name').length > 0 ) {
    getLocation(true);
  }

  // check for disabled buttons
  $('a[disabled=disabled]').click(function(event){
    event.preventDefault(); // Prevent link from following its href
  });

  // enable video clip
  if( $('.vimeo-thumb').length > 0 ) {
    $('.vimeo-thumb').smartVimeoEmbed();
  }

  // enable placeholder text for input fields
  if( $('#px-container').length == 0 ) {
    $('input, textarea').placeholder();
  }
  else {
    // load board on doc ready
    if( $('.pixiPg').length == 0) {
      load_masonry('#px-nav', '#px-nav a', '#pxboard .item', 180); 
    }
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

  // initialize slider
  load_slider(true);

  // initialize s3 image upload
  load_image_uploader();

  // init scroll to top
  $('.scrollup').click(function(){
    $("html, body").animate({ scrollTop: 0 }, 600);
    return false;
  });

  // repaint file fields
  if( $('.cabinet').length > 0 ) {
    SI.Files.stylizeAll();
  }

  // set rating elements
  if ($('#rateit5').length > 0) {  
    $('#rating-done-btn').attr('disabled', true);
    $("#rateit5").bind("rated", function (event, value)  { $('#value5').val(value); $('#rating-done-btn').removeAttr('disabled'); });
    $("#rateit5").bind('reset', function () { $('#value5').val(0); $('#rating-done-btn').attr('disabled', true); });
  }

  // set inquiry form elements
  if ($('#inquiry_frm').length > 0) {  
    if($('#inq_status').is(':visible')) {
      $('#inq-done-btn').removeAttr('disabled');
    } else {
      $('#inq-done-btn').attr('disabled', true);
    }
  }

  // hide footer on main board
  if ($('.item-cat').length > 0) {  
    $('#footer').hide('fast');
  }
});

// masks phone number fields
var mask_flds = '#pixi_post_home_phone, #pixi_post_mobile_phone, #home_phone, #mobile_phone, #work_phone, #transaction_home_phone';
$(document).on('focus', mask_flds, function() {
  $(this).mask("(999) 999-9999");
});

// hide spinner
$(document).on('focus', '#signup, #pixi-form', function() {
  $("#spinner").hide('fast'); 
});

// check for empty flds on form when fld changes
var inq_flds = '#inq_first_name, #inq_last_name, #inq_comments, #inq_subject, #inq_email';
$(document).on('keyup change', inq_flds, function() {
  if(allFilled(inq_flds)) {
    $('#inq-done-btn').removeAttr('disabled');
  } else {
    $('#inq-done-btn').attr('disabled', true);
  }
});

// check form for blank fields
function allFilled(list) {
  var filled = true;
  var flds = list.split(', ');

  $.each(flds, function(index, item) {
    if($(item).val() == '') {
      filled = false; 
    }
  });
  return filled;
}

// toggle button on value reset
$(document).on('change', '#value5', function() {
  if($(this).val() == '0') {
    $('#rating-done-btn').removeAttr('disabled');
  } else {
    $('#rating-done-btn').attr('disabled', true);
  }
});

// disable btn to prevent double click
$(document).on("click", "#approve-btn, #px-done-btn, #fb-btn", function(showElem){
  toggleLoading();
  $(this).attr('disabled', true);
});

// show spinner on forms with image uploads
$(document).on("click", "#build-pixi-btn", function(showElem){
  var loc = $('#site_id').val(); // grab the selected location 
  if(checkLocID(loc))
    toggleLoading();
});

// reload masonry on ajax calls to swap data
$(document).on("click", ".pixi-cat", function(showElem){
  var cid = $(this).attr("data-cat-id");

  // toggle value
  $('#category_id').val(cid);

  // toggle menu
  if($('.pixiPg').length > 0) {
    $('#category_id').selectmenu("refresh", true);
  }

  // process ajax call
  resetBoard();
});

// reload board
function reload_board(element) {
  var $container = $('#px-container');

  $container.imagesLoaded( function(){
    $container.masonry('reload');
  });

 // switchToggle(false);
 $('#spinner').hide('fast');
}

var loadingBoard = false; 

// initialize infinite scroll
function initScroll(cntr, nav, nxt, item) {
  var $container = $(cntr);
  loadingBoard = true;

  if(!loadingBoard && ($("#px-nav").is(':visible'))) {
    $container.infinitescroll({
      navSelector  : nav, 		// selector for the paged navigation (it will be hidden)
      nextSelector : nxt,  		// selector for the NEXT link (ie. page 2)  
      itemSelector : item,          // selector for all items that's retrieve
      animate: false,
      extraScrollPx: 150,
      bufferPx : 100,
      localMode    : true,
      loading: {
        img:  'http://i.imgur.com/6RMhx.gif',
	msgText: "<em>Loading...</em>"
      }
    },

    // trigger Masonry as a callback
    function(newElements){
      var $newElems = $(newElements).css({ opacity: 0 });

      // ensure that images load before adding to masonry layout
      $newElems.imagesLoaded(function(){
        $newElems.animate({ opacity: 1 });
        $container.masonry( 'appended', $newElems, true ); 
      });

      $("#spinner").hide('fast');
      loadingBoard = false;
    });
  }

  $("#spinner").hide('fast');
}

// use masonry to layout landing page display
function load_masonry(nav, nxt, item, sz){

  if( $('#px-container').length > 0 ) {
    var $container = $('#px-container');
 
    $container.imagesLoaded( function(){
      $container.masonry({
        itemSelector : '.item',
	gutter : 10,
	isFitWidth: true,
        columnWidth : sz,
	layoutPriorities : {
	   upperPosition: 1,
	   shelfOrder: 1
	}
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

// check for category board
function set_home_location(loc){
  console.log('loc name = ' + loc);
  var url = '/pages/location_name.js?loc_name=' + loc;

  // process ajax call
  processUrl(url);
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
    $('#inv_price').val(parseFloat(price).toFixed(2)); 
  }
}

// calc invoice amt
$(document).on("change", "#inv_qty, #inv_price, #inv_tax", function(){
  calc_amt();
});

// get pixi price based selection of pixi ID
$(document).on("change", "select[id*=pixi_id]", function() {
  var pid = $(this).val();

  if (pid.length > 0 && $('#invoice_buyer_id').length > 0) {
    var url = '/listings/pixi_price?id=' + pid;

    // reset buyer id
    $('#invoice_buyer_id').val('');

    // process script
    processUrl(url);
  }
});

// set invoice buyer if selected buyer is changed
$(document).on("change", "#tmp_buyer_id", function() {
  var pid = $(this).val();
  $('#invoice_buyer_id').val(pid);
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

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#site_name", function(event, data){
  if ($('#recent-link').length > 0) {
   resetBoard(); // reset board display
  }
  else {
    var loc = $('#site_id').val(); // grab the selected location 

    if($('#cat-wrap').length > 0) { 
      var url = '/categories/location?' + 'loc=' + loc;
      processUrl(url);
    } 
    else {
      checkLocID(loc);
    }
  }
});

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#buyer_name, #slr_name, #pixan_name, #search_user", function(event, data){
  var bname = data.item.first_name + ' ' + data.item.last_name;
  $('#pixan_name, #search_user, #slr_name, #buyer_name').val(bname);
  if ($('#search_user').length > 0) {
    $('#submit-btn').click();
  }
});

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#search", function(event, data){
  $('#submit-btn').click();
});

// toggle profile state
$(document).on('click', '#edit-txn-addr, #edit-addr-btn', function(e) {
  $('.user-tbl, .addr-tbl').toggle();
});

// toggle credit card edit view
$(document).on('click', '#edit-card-btn', function(e) {
  $('#pay_token').val('');
  $('.card-tbl, .card-dpl').toggle();
});

// toggle contact form for show pixi
$(document).on('click', '#want-btn', function(e) {
  var fld = '#contact_content';
  var txt;
  $('#post_form').toggle();

  // set focus on fld
  $(fld).focus();
  $(fld).val($(fld).val());

  // toggle button display
  if ($(this).text() == 'Want') {
    txt = 'Unwant';
    $(this).removeClass('submit-btn width80').addClass('btn-mask');
  }
  else {
    txt = 'Want';
    $(this).removeClass('btn-mask').addClass('submit-btn width80');
  }

  // toggle button name
  $(this).text(txt);
});

var keyPress = false; 

// submit contact form on enter key
$(document).on("keypress", "#contact_content", function(e){ 
  keyEnter(e, $(this), '#contact-btn');
});

// submit comment form on enter key
$(document).on("keypress", "#comment_content", function(e){
  var a = $(this).attr('id');
  keyEnter(e, $(this), '#comment-btn');
});

// submit search form on enter key
$(document).on("keypress", "#search", function(e){
  keyEnter(e, $(this), '#submit-btn');
});

// submit reply form on enter key
$(document).on("keypress", ".reply_content", function(e){
  keyEnter(e, $(this), '.reply-btn');
});

// submit login form on enter key
$(document).on("keypress", "#pwd", function(e){
  //keyEnter(e, $(this), '#login-btn');
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

// populate board based on category 
$(document).on("click", ".pixi-cat-link", function() {
  var loc = $('#site_id').val(); // grab the selected location 
  var loc_name = $('#home_site_name').val(); // grab the selected location 
  var url, cid = $(this).attr("data-cat-id");

  // refresh menu
  $('#nav-home-menu').html('');

  // set url
  if (cid > 0) {
    url = '/listings/category?' + 'cid=' + cid; 
  }

  // add location
  if (loc > 0) {
    url += '&loc=' + loc;
  }
  else {
    url += '&loc_name=' + loc_name;
  }

  // reset board
  resetScroll(url);
  
  //prevent the default behavior of the click event
  return false;
});

// check for location changes
$(document).on("change", "#site_id, #category_id", function() {
 
  // reset board
  if($('#px-container').length > 0) {
    resetBoard();
  }
  
  //prevent the default behavior of the click event
  return false;
});

// check for recent link click
$(document).on("click", "#recent-link", function() {

  // reset board
  resetBoard();
  
  //prevent the default behavior of the click event
  return false;
});

// reset board pixi based on location
function resetBoard() {
  var loc = $('#site_id').val(); // grab the selected location 
  var cid = $('#category_id').val(); // grab the selected category 

  // set search form fields
  $('#cid').val(cid);
  $('#loc').val(loc);

  // check location
  if (loc > 0) {
    if (cid > 0) {
      var url = '/listings/category?' + 'loc=' + loc + '&cid=' + cid; 
    }
    else {
      var url = '/listings/local?' + 'loc=' + loc;
    }
  }
  else {
    if (cid > 0) {
      var url = '/listings/category?' + 'cid=' + cid; 
    }
    else {
      var url = '/listings.js';
    }
  }

  // refresh the page
  resetScroll(url);

  // toggle menu
  reset_menu_state($("#li_home"), true);
}

// Fix input element click problem
$(function() {
  $('.dropdown input, .dropdown label, .dropdown-menu input, .dropdown-menu select').click(function(e) {
    e.stopPropagation();
  });
});

// toggle menu post menu item
$(document).on('click', '.post-menu', function(e) {
  $('#mark-posts').toggle();
});

// toggle seller comments
$(document).on('click', '#seller-cmt-btn', function(e) {
  $('#cmt-fld').toggle();

  $(this).text(function(i, text){
    return text === "Add Comment" ? "Hide Comment" : "Add Comment";
  });
});

// toggle menu post menu item
$(document).on('click', '#home-link', function(e) {
  $('#site_id').val('').prop('selectedIndex',0);
  $('#category_id').val('').prop('selectedIndex',0);
  $('#search').val('');

  // reset board
  resetBoard();

  // toggle menu
  if($('.pixiPg').length == 0) {
    reset_menu_state($("#li_home"), true);
  }
  else {
    $('#category_id').selectmenu("refresh", true);
    $('#site_id').selectmenu("refresh", true);
  }
});

// toggle menu state
$(document).on('click', '#mark-posts', function(e) {
  reset_menu_state($("#li_home"), true);
});

// reset next page scroll data
function resetScroll(url) {
  var $container = $('#px-container');

  // call the method to destroy the current infinitescroll session.
  $container.infinitescroll('destroy');
  $container.infinitescroll('unbind');

  // clear current infinitescroll session.
  $.removeData($container.get(0), 'infinitescroll')
  $container.data('infinitescroll', null);

  $.ajax({
    url: url,
    dataType: 'script',
    beforeSend: function() {
      switchToggle(true);
    },
    success: function(data){
      $container.infinitescroll({                      
          state: {                                              
	    isDestroyed: false,
	    isDone: false                           
	  }
      });
    },
    complete: function() {
      switchToggle(false);
    }
  });
}

// return masonry item size
function get_item_size() {
  if($('.board-top').length > 0) {
    var sz = 1; }
  else {
    var sz = 180; }

  return sz;
}

// process Enter key
function keyEnter(e, $this, str) {
  if (e.keyCode == 13 && !e.shiftKey && !keyPress) {
    toggleLoading();
    keyPress = true;
    e.preventDefault();

    if($this.val().length > 0) {
      $(str).click();
      $(str).attr('disabled', true);
    }  
    else {
      $(str).removeAttr('disabled');
    }  
    keyPress = false;
  }
}

// process Autocomplete Enter key
function keySelectEnter(e, $this) {
  if (e.keyCode == 13 && !e.shiftKey && !keyPress) {
    keyPress = true;
    e.preventDefault();
    //console.log('in keySelectEnter');

    var keyEvent = $.Event("keydown");          
    keyEvent.which = 40;
    $this.trigger('focus').trigger(keyEvent);
    $this.click();
  }
}

// process window scroll for main image board
var processFlg = false;

$(window).scroll(function(e) {

  if ($('#px-container').length > 0) {
    var url = $('a.nxt-pg').attr('href');

    if (url != undefined && url.length > 0 && !processFlg && $(window).scrollTop() > ($(document).height() - $(window).height() - 50)) {
      processFlg = true;

      $.ajax({
        url: url,
        dataType: 'script',
        'beforeSend': function (xhr) {
  	   var token = $("meta[name='csrf-token']").attr("content");
	   xhr.setRequestHeader("X-CSRF-Token", token);
	   switchToggle(true);
        },
        success: function(data){
	  processFlg = false;
	},
        complete: function(data){
	  processFlg = false;
	  switchToggle(false);
	}
      })
    }
  }
});

// show spinner
function switchToggle(flg) {
  if($('.pixiPg').length > 0)
    uiLoading(flg);
  else
    toggleLoading();
}

// fix bootstrap mobile dropdown issue
$('body').on('touchstart.dropdown', '.dropdown-menu', function (e) { e.stopPropagation(); })
         .on('touchstart.dropdown', '.dropdown-submenu', function (e) { e.stopPropagation(); });
	  
// set card month for credit card
$(document).on("change", "#cc_card_month", function() {
  var card_mo = $(this).val();
  $('#exp_mo').val(card_mo);
});
	  
// set card year for credit card
$(document).on("change", "#cc_card_year", function() {
  var card_yr = $(this).val();
  $('#exp_yr').val(card_yr);
});

// check if dropdown is open to close
$(document).on("click", ".navbar li a", function() {
  $('li[class="dropdown open"]').removeClass('open');
});

// write flash notice on page dynamically
function postFlashMsg(id, cls, msg) {
  var str = '<div class="' + cls + '"><button class="close" data-dismiss="alert"><i class="icon-remove-sign"></i></button>' +
    msg + '</div>';
  $(id).append(str);
}

// check if loc id is set
function checkLocID(loc) {
  if(loc.length == 0 && $('#pixi-form').length > 0) {
    postFlashMsg('#form_errors','error', 'Location is invalid');
    return false;
  }
  return true;
}
