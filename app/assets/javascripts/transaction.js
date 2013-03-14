// checks ticket order form quantity fields to ensure selections are made prior to submission 
var formError, formTxtForm, pmtForm, payForm; 
 
function getFormID(fld) { 
  if ($('#fancybox-content').length > 0) {
	return $('#fancybox-content').find(fld);
	}		
  else {
  	return $(fld);   
  }
}  

// process Stripe payment form for credit card payments
$(document).on('click', '#payForm', function () {
	
  // check card # to avoid resubmitting form twice
  if (getFormID('#card_number').length > 0) {	  
    Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));  // get stripe key		
    processCard(); // process card
    false 
  }
  else {
    true
      }
});  

// create token if credit card info is valid
function processCard() {
    $('#payForm').attr('disabled', true);
	
      Stripe.createToken({
        number: getFormID('#card_number').val(),
        cvc: getFormID('#card_code').val(),
        expMonth: getFormID('#card_month').val(),
        expYear: getFormID('#card_year').val()    
      }, stripeResponseHandler);

    // prevent the form from submitting with the default action
    return false;
}

// used to toggle promo codes
$(document).on('click', '.promo-cd', function () {
   	$(".promo-code").show();
});	

$(document).ready(function() {	
  if ($('#pmtForm').length == 0 || $('#buyTxtForm').length == 0) {
	payForm = getFormID('#payForm');		
  } 
});

// process discount
$(document).on('click', '#discount_btn', function () {
    var cd = $('#promo_code').val();
    if (cd.length > 0) {
  		var url = '/discount.js?promo_code=' + cd; 
  		process_url(url);
  	}
  	
	return false;
});

// print page
$(document).on('click', '#print-btn', function () {
  printIt($('#printable').html());
  return false;
});

var win=null;
function printIt(printThis)
{
	win = window.open();
	self.focus();
	win.document.write(printThis);	
	win.print();
	win.close();	
}

// handle credit card response
function stripeResponseHandler(status, response) {
  var stripeError = getFormID('#stripe_error'); 
      
  if(status == 200 || status == '200') {
    toggleLoading();
    stripeError.hide(300);
	  
    // insert the token into the form so it gets submitted to the server
    getFormID('#transaction_token').val(response.id);
    getFormID("#payment_form").trigger("submit.rails");    	  
 	}
  else {
    stripeError.show(300).text(response.error.message)
    payForm.attr('disabled', false);
      
    $('html, body').animate({scrollTop:0}, 100); 
  }
    
  return false;
}

