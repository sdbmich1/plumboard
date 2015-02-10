// manage invoice functionality

// calc invoice amount
function calc_amt(){
  var rowCount = $('#inv-table tr').length;
  var totAmt = 0;
  var tax = $('#inv_tax').val();
  var ship = $('#ship_amt').val();
  
  for (var j = 1; j <= rowCount; j++) {
    if($('#inv_qty'+j).length == 0)
      continue;

    var qty = $('#inv_qty'+j).val();
    var price = $('#inv_price'+j).val();

    // calc amounts
    if (qty.length > 0 && price.length > 0) {
      var amt = parseInt(qty) * parseFloat(price);
      totAmt += amt;
      $('#inv_amt'+j).val(amt.toFixed(2)); 
    }
  }

  // calc ship
  if (ship.length == 0) {
    ship = 0.0;
  }

  // calc tax
  if (tax.length > 0) 
    var tax_total = totAmt * parseFloat(tax)/100;
  else 
    var tax_total = 0.0;

  // update tax total
  $('#inv_tax_total').val(tax_total.toFixed(2)); 

  // set & update invoice total
  var inv_total = totAmt + parseFloat(ship) + tax_total;

  $('#ship_amt').val(parseFloat(ship).toFixed(2)); 
  $('#inv_total').val(inv_total.toFixed(2)); 
  $('#inv_price').val(parseFloat(price).toFixed(2)); 
}

// calc invoice amt
$(document).on("change", "select[id*=inv_qty], input[id*=inv_price], #inv_tax, #ship_amt", function(){
  calc_amt();
});

// get pixi price based selection of pixi ID
$(document).on("change", "select[id*=pixi_id]", function() {
  var pid = $(this).val();
  var $row = $(this).closest('td').parent(); 
  var idx = $row[0].sectionRowIndex;

  if (pid.length > 0 && $('#invoice_buyer_id').length > 0) {
    var url = '/listings/pixi_price?id=' + pid;

    // reset buyer id
    $('#invoice_buyer_id').val('');

    // process script
    getItemData('#inv_price'+idx, url);
  }
});

// set invoice buyer if selected buyer is changed
$(document).on("change", "#tmp_buyer_id", function() {
  var pid = $(this).val();
  $('#invoice_buyer_id').val(pid);
});

// load quantity selectmenu
function loadQty(fld, val, qty) {
  var qty_str = '<option default value="">' + 'Select' + '</option>';

  for (var j = 1; j <= qty; j++) {
    qty_str += '<option value="'+ j + '">' + j + '</option>';
  }

  setSelectMenu(fld, qty_str, val); // set option menu
}

// set dropdown selection and refresh menu
function setSelectMenu(fld, str, val) {
  if(str.length > 0) 
    $(fld).append(str);

  $(fld).trigger("chosen:updated");
}

// check for add or remove row 
$(document).on('click', '.add-row-btn, .remove-row-btn', function(e){
  var $row = $(this).closest('td').parent(); 
  var idx = $row[0].sectionRowIndex;

  if($(this).attr("class").match(/add/i))
    add_row($row, idx+1);
  else
    remove_row($row, idx);
});

// add row to html table
function add_row($element, row) {
  var fld = '#inv_qty' + row;
  var pxFld = '#pixi_id' + row;
  var fname = "invoice[invoice_details_attributes][new_invoice_details][";
  var rowCount = $('#inv-table tr').length;
  var str = "<tr><td class='width120'><select name='" + fname + "quantity]' id='inv_qty" + row + "' class='pixi-select' ></select></td>"; 
  str += "<td class='width360'><select name='" + fname + "pixi_id]' id='pixi_id" + row + "' class='pixi-select'></select></td>";
  str += "<td class='width120'><input type='text' name='" + fname + "price]' in='0..15000.0' step='0.01' id='inv_price" + row + "' class='price' /></td>";
  str += "<td class='width120'><input type='text' name='" + fname + "subtotal]' id='inv_amt" + row + "' class='price' readonly='true' /></td>";
  str += "<td class='borderless width60'><a href='#' class='pixi-link add-row-btn' title='Add Item'>";
  str += "<img class='social-img mbot' src='/assets/rsz_plus-blue.png'></a>";
  str += "<a href='#' class='pixi-link remove-row-btn' title='Remove Item'><img class='social-img mleft5 mbot' src='/assets/rsz_minus.png'></a></td></tr>";

  // add row
  document.getElementById("inv-table").insertRow(row).innerHTML = str;

  // load items
  $(pxFld).html( $('#pixi_id1').html() );
  $(fld).html( $('#inv_qty1').html() );
}

// remove row from html table
function remove_row($element, row) {
  var rowCount = $('tr:visible').length;
  if(rowCount > 5) {
    $element.find("input[type=hidden]").val("1");
    $("#pixi_id"+row).val("");
    $("#inv_price"+row).val(0);
    $element.hide();
    calc_amt();
  }
  else
    alert('There must be at least one item on an invoice.');
}

// get data from server
function getItemData(fld, url) {
  $.ajax({
    url: url,
    type: "get",
    dataType: "json",
    contentType: "application/json",
    success: function(data, status, xhr) {
      if (data !== undefined) {
        $(fld).val(data.price); 
	calc_amt();
      }
    }
  });
}
