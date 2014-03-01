// process datepicker
var nowTemp = new Date();
nowTemp.setDate(nowTemp.getDate() + 1);
var dt = nowTemp.getDate(); 
var now = new Date(nowTemp.getFullYear(), nowTemp.getMonth(), dt, 0, 0, 0, 0);

// set default date
$(document).on("focus", ".dt-pckr", function(e){
  var newDt = $(this).datepicker('setValue', nowTemp);
});

// manage event date
$(document).on("focus", "#start-date", function(e){
  var sdt = $(this).datepicker({
    onRender: function(date) {
      return date.valueOf() < now.valueOf() ? 'disabled' : '';
      }
    }).on('changeDate', function(ev) { 

    if (ev.date.valueOf() >= edt.date.valueOf()) {
      var newDate = new Date(ev.date);
      newDate.setDate(newDate.getDate());

      // set end date
      edt.setValue(newDate);
    }

    sdt.hide();
//    $('#end-date')[0].focus();
  }).data('datepicker');

  var edt = $('#end-date').datepicker({
    onRender: function(date) {
      return date.valueOf() < sdt.date.valueOf() ? 'disabled' : ''; }
    }).on('changeDate', function(ev) { edt.hide(); }).data('datepicker');
});

$(document).on("focus", "#end-date", function(e){
  var sdt = $('#start-date').val();

  if (sdt.length == 0){
    var edt = $(this).datepicker({
      onRender: function(date) {
        return date.valueOf() < now.valueOf() ? 'disabled' : ''; }
    })
    .on('changeDate', function(ev){ 

      var newDate = new Date(ev.date);
      newDate.setDate(newDate.getDate());

      // set start date
      sdt.setValue(newDate);

      edt.hide(); 
    }).data('datepicker');
  }

  var sdt = $('#start-date').datepicker({
    onRender: function(date) {
      return date.valueOf() < now.valueOf() ? 'disabled' : ''; }
    }).on('changeDate', function(ev) { sdt.hide(); }).data('datepicker');
});

// set end time on change
function set_end_time(elem) {
  // select one hour ahead
  var idx = elem.selectedIndex + 4;  

  // check drop-down index size
  if (idx > 95) {idx -= 96}     

  var etm = $("#end-time").prop('selectedIndex', idx).val();  
  $("#end-time").val(etm);
}

// toggle end time on change of start time
$(document).on('change', "#start-time", function() {
  set_end_time(this);
});

// check if end time < start time on same day
$(document).on('change', "#end-time", function() {
  var idx = this.selectedIndex;  
  var stm = $("#start-time").selectedIndex; 
  var sdt = $("#start-date").val();
  var edt = $("#end-date").val();

  // check if start_date = end date
  if ((edt == sdt) && (stm >= idx))
    { set_end_time($('#start-time')) }
  
});
