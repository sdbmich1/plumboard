// manage invoice functionality

// calc invoice amount
function calc_amt(){
  var qty = $('#inv_qty').val();
  var price = $('#inv_price').val();
  var tax = $('#inv_tax').val();
  var ship = $('#ship_amt').val();

  // check for inv price & quantity
  if (qty.length > 0 && price.length > 0) {

    // calc amount
    var amt = parseInt(qty) * parseFloat(price);
    $('#inv_amt').val(amt.toFixed(2)); 

    // calc ship
    if (ship.length == 0) {
      ship = 0.0;
    }

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
    var inv_total = amt + parseFloat(ship) + tax_total;
    $('#ship_amt').val(parseFloat(ship).toFixed(2)); 
    $('#inv_total').val(inv_total.toFixed(2)); 
    $('#inv_price').val(parseFloat(price).toFixed(2)); 
  }
}

// calc invoice amt
$(document).on("change", "#inv_qty, #inv_price, #inv_tax, #ship_amt", function(){
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

