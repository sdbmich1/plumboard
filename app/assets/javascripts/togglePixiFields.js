// toggle field display based on category value
function toggleFields(ctype) {
  if(ctype.match(/^event/) != null) {
    $('#event-fields').show('fast');
    $('#yr-fld').hide('fast');
    hideComp();
  }
  else {
    $('#event-fields').hide('fast');

    // clear event flds
    $('#start-date, #end-date, #start-time, #end-time').val('');
      
    // check for jobs
    if(ctype.match(/^employment/) != null) {
      $('#price-fld, #yr-fld').hide('fast');
      $('#comp-fld').show('fast');

      // reset fields
      if($('#input-form').length > 0) 
	  $('#temp_listing_price, #yr_built').val('');
    }
    else {
      hideComp();

      // check for year categories
      if(ctype.match(/^asset/) != null) {
        $('#yr-fld').show('fast');
      } else {
        $('#yr-fld').hide('fast');
      }
    }
  }
}
