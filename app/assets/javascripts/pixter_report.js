// when the #date_range field in pixter_report changes
$(document).on("change", "#date_range_name", function(evt){
    var pixter_id = $('#user_id').val();
    if($('#date_range_name').length > 0) {
        var date_range = $(this).val();
        if (date_range.length > 0) 
          var url = $('#pxp-report').length == 0 ? '/transactions?date_range=' + date_range : get_pixter_url(pixter_id, date_range);
	else
          var url = $('#pxp-report').length == 0 ? '/transactions' : get_pixter_url(pixter_id, '');
        processUrl(url);
    }
});

// when the #user_id field in pixter_report changes
$(document).on("change", "#user_id", function(evt){
    var date_range = $('#date_range_name').val();
    if($('#user_id').length > 0) {
        var pixter_id = $(this).val();
	var url = get_pixter_url(pixter_id, date_range);
        processUrl(url);
    }
});

function get_pixter_url(pixter_id, date_range) {
  if (pixter_id === undefined) 
    var url = '/pixi_posts/pixter_report?date_range=' + date_range + "&status='pixter_report'";
  else
    var url = '/pixi_posts/pixter_report?date_range=' + date_range + '&pixter_id=' + pixter_id + "&status='pixter_report'";
  return url;
}
