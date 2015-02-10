// hide & reset comp field
function hideComp(eFlg){
  refreshPage('#comp-fld, #job-fld', '#price-fld, #qty-fld', eFlg);
  toggleReqFlds('', '#temp_listing_job_type_code', '#salary');
}

// toggle field display based on category value
function toggleFields(ctype) {
  if(ctype.match(/^event/) != null) {
    refreshPage('#yr-fld, #qty-fld, #vehicle-fields, #product-fields, #cond-type-fld', '#event-fields, #event-type-fld, #et_code', true);
    toggleReqFlds('#et_code', '#cond-type-code, #yr_built', '#cond-type-code');
    hideComp(true);
  }
  else {
    refreshPage('#event-fields, #event-type-fld, #et_code', '', false);
    toggleReqFlds('', '#et_code', '#start-date, #end-date, #start-time, #end-time');
      
    // check for jobs
    if(ctype.match(/^employment/) != null) {
      refreshPage('#price-fld, #yr-fld, #qty-fld, #vehicle-fields, #product-fields, #cond-type-fld', '#comp-fld, #job-fld', true);
      toggleReqFlds('#temp_listing_job_type_code', '#cond-type-code, #yr_built', '#cond-type-code, #yr_built');
      toggleYear(ctype);
    }
    else {
      hideComp(false);
      if(ctype.match(/^service/) != null) {
        refreshPage('#vehicle-fields, #product-fields, #cond-type-fld, #qty-fld', '', false);
        toggleReqFlds('', '#cond-type-code, #yr_built', '#cond-type-code, #yr_built');
        hideComp(false);
      }

      if(ctype.match(/^sales/) != null || ctype.match(/^asset/) != null) {
        refreshPage('#vehicle-fields, #product-fields', '#cond-type-fld, #qty-fld', true);
        toggleReqFlds('#cond-type-code', '#yr_built', '#temp_listing_other_id, #temp_listing_mileage, #temp_listing_item_size, #temp_listing_color');
      }

      if(ctype.match(/^vehicle/) != null) {
        refreshPage('#qty-fld, #product-fields', '#vehicle-fields, #cond-type-fld', true);
        toggleReqFlds('#cond-type-code, #yr_built', '', '#qty-fld, #temp_listing_other_id, #temp_listing_item_size');
      }

      if(ctype.match(/^product/) != null) {
        refreshPage('#vehicle-fields', '#product-fields, #cond-type-fld', true);
        toggleReqFlds('#cond-type-code', '#yr_built', '#temp_listing_other_id, #temp_listing_mileage');
      }
      toggleYear(ctype);
    }
  }
}

// refresh current page
function refreshPage(hideList, showList, rFlg) {
  $(showList).show('fast');
  if(rFlg) 
    $('#cat-fld').removeClass('span4').addClass('span2');
  else
    $('#cat-fld').removeClass('span2').addClass('span4');

  $(hideList).hide('fast');
}

// refresh current page
function toggleReqFlds(reqList, clearList, resetList) {
  $(reqList).attr('required', 'required');
  $(clearList).removeAttr('required'); 
  $(resetList).val('');
}

// check for year categories
function toggleYear(ctype) {
  if(ctype.match(/^vehicle/) != null) {
    $('#yr-fld').show('fast');
  } else {
    $('#yr-fld').hide('fast');
  }
}
