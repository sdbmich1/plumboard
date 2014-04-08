/*  
  var arr = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  var item_str = '<option default value="">' + 'Mon' + '</option>';

  // build option list
  for (var i = 1; i <= arr.length; i++) {
    item_str += '<option value="'+ i + '">' + arr[i-1] + '</option>';
  }

judge.validate(document.getElementById('temp_listing_title'), {
  valid: function(element) {
    element.style.border = '1px solid green';
  },
  invalid: function(element, messages) {
    element.style.border = '1px solid red';
    alert(messages.join(','));
  }
});
*/
