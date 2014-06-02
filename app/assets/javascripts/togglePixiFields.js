// hide & reset comp field
function hideComp(){
  $('#comp-fld').hide('fast');
  $('#job-fld').hide('fast');
  $('#price-fld').show('fast');
  $('#cat-fld').removeClass('span2').addClass('span4');
  $('#temp_listing_job_type_code').removeAttr('required'); 

  if($('#input-form').length > 0) {
    $('#salary').val('');
  }  
}

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
      $('#job-fld').show('fast');
      $('#cat-fld').removeClass('span4').addClass('span2');
      $('#temp_listing_job_type_code').attr('required', 'required');

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
