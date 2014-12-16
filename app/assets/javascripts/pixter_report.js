// when the #date_range field in pixter_report changes
$(document).on("change", "#date_range_name", function(evt){
    var pixter_id = $('#user_id').val();
    // check if px-rpt
    if($('#date_range_name').length > 0) {
        var date_range = $(this).val();
        if (date_range.length > 0) {
            var url;
            if (pixter_id === undefined) {
                url = '/transactions?date_range=' + date_range;
            } else {
                url = '/pixi_posts/pixter_report?date_range=' + date_range + '&pixter_id=' + pixter_id;
            }
            // process script
            processUrl(url);
        }
    }
});

// when the #user_id field in pixter_report changes
$(document).on("change", "#user_id", function(evt){

    var date_range = $('#date_range_name').val();
    // check if px-rpt
    if($('#user_id').length > 0) {
        var pixter_id = $(this).val();
        if (pixter_id.length > 0) {
            var url = '/pixi_posts/pixter_report?date_range=' + date_range + '&pixter_id=' + pixter_id;
            // process script
            processUrl(url);
        }
    }
});