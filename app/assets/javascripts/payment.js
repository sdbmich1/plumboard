var $formID, marketplaceUri, token;
var $balancedError = $('#card_error'); 

// process Balanced bank account form for ACH payments
$(document).on('click', '#acctForm', function () {
  marketplaceUri = $('meta[name="balanced-key"]').attr('content');  // get balanced key		

  // set form id
  $formID = $('#bank-acct-form');
	
  // check acct # to avoid resubmitting form twice
  if ($('#acct_number').length > 0) {	  

    // initialize object
    balanced.init(marketplaceUri);

    processAcct(); // process acct
    return false 
  }
  else {
    $("#bank-acct-form").trigger("submit.rails");
    return true
  }
});
 
// process card
function BalancedCard() {
  token = $('#pay_token').val(); 
  $formID = $('#payment_form');
  marketplaceUri = $('meta[name="balanced-key"]').attr('content');  // get balanced key		

  // disable form
  $('#payForm').attr('disabled', true);
  
  if (token.length > 0)  {
    console.log('token = ' + token);
    $formID.trigger("submit.rails");    	  
  }
  else {
    // initialize object
    balanced.init(marketplaceUri);

    // create token	
    balanced.card.create({
      card_number: $('#card_number').val(),
      security_code: $('#card_code').val(),
      expiration_month: $('#card_month').val(),
      expiration_year: $('#card_year').val()    
    }, callbackHandler);
  }

  // prevent the form from submitting with the default action
  return false;
}

// create token if credit card info is valid
function processAcct() {
    $('#bank-acct-form').attr('disabled', true);
	
      balanced.bankAccount.create({
        name: $('#bank_account_acct_name').val(),
        account_number: $('#acct_number').val(),
        routing_number: $('#routing_number').val(),
        type: $('#bank_account_acct_type').val()
      }, callbackHandler);

    // prevent the form from submitting with the default action
    return false;
}

// process errors
function processError(response, msg) {
  var $balancedError = $('#data_error'); 

  $balancedError.show(300).text(msg);

  if($('#bank-acct-form').length > 0) {
    $('#bank-acct-form').attr('disabled', false); }
  else {
    $('#payForm').attr('disabled', false); }

  // scroll to top of page
  $('html, body').animate({scrollTop:0}, 100); 
}

// process balanced callback
function callbackHandler(response) {
  switch (response.status) {
    case 400:
      console.log(response.error);
      processError(response, 'Card/Account number or cvv invalid');
      break;
    case 402:
      console.log(response.error);
      processError(response, 'Card/Account is invalid and could not be authorized');
      break;
    case 404:
      console.log(response.error);
      processError(response, 'Payment token is invalid');
      break;
    case 500:
      console.log(response.error);
      processError(response, 'Network request invalid. Please try again.');
      break;
    case 201:
      toggleLoading();
      $balancedError.hide(300);
       
      // insert the data into the form 
      $('#pay_token').val(response.data.uri);

      if($('#bank_account_acct_no').length > 0) {
        $('#bank_account_acct_no').val(response.data.account_number); }

      // submit to the server
      $formID.trigger("submit.rails");    	  
      break;
    default:
      console.log(response);
      processError(response, 'Request invalid. Please try again.');
      break;
  }
}
