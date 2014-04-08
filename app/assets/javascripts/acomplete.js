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

