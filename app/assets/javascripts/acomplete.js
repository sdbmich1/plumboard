$(document).ready(function(){

  // Automatically put focus on first item in drop-down list
  if( $('input[data-autocomplete]').length > 0 && ($('#site_id').length > 0 || $('#buyer_name').length > 0 || $('#slr_name').length > 0) ) {
    $('input[data-autocomplete]').autocomplete({ autoFocus: true });

    // check for incorrect selection
    $(document).on('change', 'input[data-autocomplete]', function() {
      var item = $(this).val();
      if (item == 'no existing match') { $(this).val(''); }
    });
  }
});

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#site_name", function(event, data){
  if ($('#recent-link').length > 0) {
   resetBoard(); // reset board display
  }
  else {
    var loc = $('#site_id').val(); // grab the selected location 

    if ($('#cat-wrap').length > 0) { 
      var url = '/categories/location?' + 'loc=' + loc;
      processUrl(url);
    } 
    else if ($('#status_type').length > 0) {
      get_pixi_url();
    }
    else {
      checkLocID(loc);
    }
  }
});

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#buyer_name, #slr_name, #pixan_name, #search_user", function(event, data){
  var bname = data.item.name != undefined ? data.item.name : data.item.first_name != undefined ? data.item.first_name + ' ' + data.item.last_name : 
    data.item.business_name;
  $('#pixan_name, #search_user, #slr_name, #buyer_name').val(bname);
  if ($('#search_user').length > 0) {
    $('#submit-btn').click();
  }
});

// set autocomplete selection value
$(document).on("railsAutocomplete.select", "#search", function(event, data){
  $('#submit-btn').click();
});

