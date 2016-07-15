// checks ticket order form quantity fields to ensure selections are made prior to submission 
var $formID, $btnID, formError, formTxtForm, pmtForm, payForm, api_type; 

// toggle credit card edit view
$(document).on('click', '#edit-card-btn', function(e) {
  $('#pay_token').val('');
  $('#subscription_card_account_id').val('');
  $('.card-tbl, .card-dpl').toggle();
});
 
// process Stripe payment form for credit card payments
$(document).on('click', '#payForm, #cardForm', function () {
  var clickedBtnID = $(this).attr('id');
  var api_type = $('meta[name="credit-card-api"]').attr('content');  // get api type
  $formID = clickedBtnID.match(/pay/i) ? $('#payment_form') : $('#card-acct-form');
  $btnID = clickedBtnID.match(/pay/i) ? $('#payForm') : $('#cardForm');
	
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
       	$formID.trigger("submit.rails");

    return true
  }
});  

// create token if credit card info is valid
function StripeCard() {
  token = $('#pay_token').val(); 
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));  // get stripe key		

  // disable form
  $btnID.attr('disabled', true);
  
  if (token.length > 0)  {
    //console.log('StripeCard token = ' + token);
    $formID.trigger("submit.rails");    	  
  }
  else {
    // create token	
    Stripe.createToken({
      number: $('#card_number').val(),
      cvc: $('#card_code').val(),
      expMonth: $('#card_month').val(),
      expYear: $('#card_year').val()    
    }, stripeResponseHandler);
  }

  // prevent the form from submitting with the default action
  return false;
}

// process Stripe bank account form for ACH payments
$(document).on('click', '#bank-btn', function () {
  Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'));  // get stripe key		

  // set form id
  $('#bank-btn').attr('disabled', true);
  $formID = $('#bank-acct-form');
  $btnID = $('#bank-btn');
	
  // check acct # to avoid resubmitting form twice
  if ($('#acct_number').length > 0) {	  
    processStripeAcct(); // process acct
    return false 
  }
  else {
    //$formID.trigger("submit.rails");
    return true
  }
});

// create token if bank account info is valid
function processStripeAcct() {
    $('#bank-acct-form').attr('disabled', true);
	
      Stripe.bankAccount.createToken({
	country: $('#bank_account_country_code').val(),
	currency: $('#bank_account_currency_type_code').val(),
        account_number: $('#acct_number').val(),
        routing_number: $('#routing_number').val()
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
  $('#exp_mo').val($('#card_month').val());
  $('#exp_yr').val($('#card_year').val());
  $formID.trigger("submit.rails");
}

// handle credit card response
function stripeResponseHandler(status, response) {
  var stripeError = $('#data_error'); 
      
  if(status == 200) {
    toggleLoading();
    stripeError.hide(300);
	  
    // insert the token
    set_token(response);
   }
  else {
    if(response.error.message == "An unexpected error has occurred. We have been notified of the problem.") {
      $btnID.attr('disabled', false);
	  
      // insert the token
      set_token(response);
    }
    else {
      $("#flash_notice").hide(300);
      stripeError.show(300).text(response.error.message);
      $btnID.attr('disabled', false);

      // scroll to top of page
      $('html, body').animate({scrollTop:0}, 100); 
    }
  }
    
  return false;
}

