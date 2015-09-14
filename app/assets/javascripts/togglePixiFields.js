// when the user type field changes
$(document).on("change", "#ucode", function(e){
  var fldList = '#user_gender, #user_birth_date_1i, #user_birth_date_2i, #user_birth_date_3i';
  var bus_flds = '#bus_code, #user_business_name';
  var utype = $(this).val().toLowerCase();
  var uid = $('#uid').val();

  if($('#signupDialog').length == 0 && $('#newReg').length == 0 && $('#bizDialog').length == 0)  
    bus_flds += ', #bus_url';

  if(utype.match(/^bus/) != null) {
    //var txt = uid.length > 0 ? '#bus_url,' : ''; 
    toggleBusFlds('#mbr_code, #gender_code, '+fldList, '#user_description, '+bus_flds, fldList, true);
    if($('#signupDialog').length == 0 && $('#newReg').length == 0 && $('#bizDialog').length == 0) 
      $("[name='user[url]']").attr('required', 'required');
  }  
  else {
    toggleBusFlds(bus_flds, '#mbr_code, #gender_code, '+fldList, '#user_description, '+bus_flds, false);
    $("[name='user[url]']").removeAttr('required');
  }
});

function toggleBusFlds(hideList, showList, fldList, reqFlg) {
  if(reqFlg) {
    $(showList).attr('required', 'required');
    $(fldList).removeAttr('required'); 
  }
  else {
    $(fldList).removeAttr('required'); 
  }
  $(showList).show('fast');
  $(hideList).hide('fast');
}

// business name field changes
$(document).on("change", "#user_business_name", function(e){
  var bname = $(this).val().replace(/ /g,'');

  // set field
  if(bname.length > 0) 
    $('#user_url').val(bname);
});

// hide & reset comp field
function hideComp(eFlg){
  refreshPage('#comp-fld, #job-fld', '#price-fld, #qty-fld', eFlg);
  toggleReqFlds('', '#temp_listing_job_type_code', '#salary');
}

// toggle field display based on category value
function toggleFields(ctype) {
  if(ctype.match(/^event/) != null) {
    refreshPage('#yr-fld, #vehicle-fields, #housing-fields, #product-fields, #item-fields, #cond-type-fld', '#event-fields, #event-type-fld, #et_code', 
      true);
    toggleReqFlds('#et_code, #start-date, #end-date, #start-time, #end-time', '#cond-type-code, #yr_built, #pixi_qty', '#cond-type-code, #yr_built');
    hideComp(true);
  }
  else {
    refreshPage('#qty-fld, #event-fields, #event-type-fld, #et_code', '', false);
    toggleReqFlds('', '#et_code', '#start-date, #end-date, #start-time, #end-time');
      
    // check for jobs
    if(ctype.match(/^employment/) != null) {
      refreshPage('#price-fld, #yr-fld, #qty-fld, #housing-fields, #vehicle-fields, #product-fields, #cond-type-fld, #item-fields', 
        '#comp-fld, #job-fld', true);
      toggleReqFlds('#temp_listing_job_type_code', '#cond-type-code, #yr_built, #pixi_qty', '#cond-type-code, #yr_built, #pixi_qty');
      toggleYear(ctype);
    }
    else {
      hideComp(false);
      var str = "#yr_built, #temp_listing_item_id, #temp_listing_mileage, #temp_listing_item_size, ";
      str += "#temp_listing_item_color, #temp_listing_car_color, #temp_listing_car_id";

      if(ctype.match(/^service/) != null) {
        refreshPage('#qty-fld, #vehicle-fields, #housing-fields, #product-fields, #cond-type-fld, #item-fields', '', false);
        toggleReqFlds('', '#pixi_qty, #cond-type-code, #yr_built', str+', #cond-type-code');
      }

      if(ctype.match(/^sales/) != null || ctype.match(/^asset/) != null) {
        refreshPage('#vehicle-fields, #housing-fields, #product-fields, #item-fields', '#cond-type-fld, #qty-fld', true);
        toggleReqFlds('#cond-type-code, #pixi_qty', '#yr_built', str);
      }

      if(ctype.match(/^item/) != null) {
        refreshPage('#cond-type-fld, #vehicle-fields, #housing-fields, #product-fields', '#qty-fld, #item-fields', false);
        toggleReqFlds('#pixi_qty', '#cond-type-code, #yr_built', str+', #cond-type-code');
      }

      if(ctype.match(/^vehicle/) != null) {
        refreshPage('#qty-fld, #housing-fields, #product-fields, #item-fields', '#vehicle-fields, #cond-type-fld', true);
        toggleReqFlds('#cond-type-code, #yr_built', '#pixi_qty', '#temp_listing_item_id, #temp_listing_item_size, #temp_listing_item_color');
      }

      if(ctype.match(/^product/) != null) {
        refreshPage('#housing-fields, #vehicle-fields, #item-fields', '#product-fields, #cond-type-fld', true);
        toggleReqFlds('#cond-type-code, #pixi_qty', '#yr_built', '#yr_built, #temp_listing_car_id, #temp_listing_mileage, #temp_listing_car_color');
      }

      if(ctype.match(/^housing/) != null) {
        refreshPage('#vehicle-fields, #product-fields, #cond-type-fld, #item-fields', '#housing-fields', false);
        toggleReqFlds('', '#cond-type-code, #yr_built', str+', #cond-type-code');
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
