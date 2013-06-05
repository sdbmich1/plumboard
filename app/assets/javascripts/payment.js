// process Stripe payment form for credit card payments
$(document).on('click', '#payForm', function () {
	
  // check card # to avoid resubmitting form twice
  if (getFormID('#card_number').length > 0) {	  
    balanced.init($('meta[name="balanced-key"]').attr('content'));  // get balanced key		
    processCard(); // process card
    return false 
  }
  else {
    var amt = parseFloat(getFormID('#amt').val());	
    if (amt == 0.0)
       	getFormID("#payment_form").trigger("submit.rails");
    return true
  }
});

function callbackHandler(response) {
  switch (response.status) {
    case 201:
      // WOO HOO!
      // response.data.uri == uri of the card or bank account resource
      break;
    case 400:
      // missing field - check response.error for details
      break;
    case 402:
      // we couldn't authorize the buyer's credit card
      // check response.error for details
      break;
    case 404:
      // your marketplace URI is incorrect
      break;
    case 500:
      // Balanced did something bad, please retry the request
      break;
  }
}
