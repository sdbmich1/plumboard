// checks ticket order form quantity fields to ensure selections are made prior to submission 
var formError, formTxtForm, pmtForm, payForm, api_type; 
 
// process Stripe payment form for credit card payments
$(document).on('click', '#payForm', function () {
  var api_type = $('meta[name="credit-card-api"]').attr('content');  // get api type
	
  // check card # to avoid resubmitting form twice
  if ($('#card_number').length > 0) {	  
    
    // process payment based on api type
    if(api_type == 'stripe') { StripeCard() } 
    if(api_type == 'balanced') { BalancedCard() } 

    return false 
  }
  else {
    var amt = parseFloat($('#amt').val());	
    if (amt == 0.0)
       	$("#payment_form").trigger("submit.rails");
    return true
  }
});  

// create token if credit card info is valid
function StripeCard() {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));  // get stripe key		

  // disable form
  $('#payForm').attr('disabled', true);
	
  // create token	
  Stripe.createToken({
    number: $('#card_number').val(),
    cvc: $('#card_code').val(),
    expMonth: $('#card_month').val(),
    expYear: $('#card_year').val()    
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
    payForm = $('#payForm');		
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

// insert the token into the form so it gets submitted to the server
function set_token(response) {
  $('#pay_token').val(response.id);
  $("#payment_form").trigger("submit.rails");    	  
}

// handle credit card response
function stripeResponseHandler(status, response) {
  var stripeError = $('#stripe_error'); 
      
  if(status == 200) {
    toggleLoading();
    stripeError.hide(300);
	  
    // insert the token
    set_token(response);
   }
  else {
    if(response.error.message == "An unexpected error has occurred. We have been notified of the problem.") {
      payForm.attr('disabled', false);
	  
      // insert the token
      set_token(response);
    }
    else {
      stripeError.show(300).text(response.error.message);
      payForm.attr('disabled', false);

      // scroll to top of page
      $('html, body').animate({scrollTop:0}, 100); 
    }
  }
    
  return false;
}

