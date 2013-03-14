// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require jquery.remotipart
//= require_tree .

$.ajaxSetup({  
  'beforeSend': function (xhr) {
  	var token = $("meta[name='csrf-token']").attr("content");
	xhr.setRequestHeader("X-CSRF-Token", token);
  	toggleLoading();
    },
  'complete': function(){ },
  'success': function() { toggleLoading }
}); 

// preview image on file upload
$(document).on("change", "input[type=file]", function(evt){
    // reset file list
    $('#list').empty();

    // render image
    handleFileSelect(evt);
    return false;
}); 

// clear input file text on click
$(document).on("click", "#delete_photo", function(evt){

  // reset file list
  $('#list').empty();

  // reset file field
  $('#photo').val(null);
}); 

// set page title
function set_title(val) { 
  document.title = "Pixi | " + val;
} 

function toggleLoading () { 
  $("#spinner").toggle(); 
}

function handleFileSelect(evt) {
  var files = evt.target.files; // FileList object

  // Loop through the FileList and render image files as thumbnails.
  for (var i = 0, f; f = files[i]; i++) {

    // Only process image files.
    if (!f.type.match('image.*')) {
      continue;
    }

    var reader = new FileReader();

    // Closure to capture the file information.
    reader.onload = (function(theFile) {
      return function(e) {
        // Render thumbnail.
	var span = document.createElement('span');
        span.innerHTML = ['<img class="thumb" src="', e.target.result,
		          '" title="', escape(theFile.name), '"/>'].join('');
        document.getElementById('list').insertBefore(span, null);
      };
    })(f);

    // Read in the image file as a data URL.
    reader.readAsDataURL(f);
  }
}

// used to toggle spinner
$(document).on("ajax:beforeSend", '#purchase_btn, .back-btn, #pixi-form', function () {
  toggleLoading();
});	

$(document).on("ajax:complete", '#purchase_btn, .back-btn, #pixi-form', function () {
  toggleLoading;
});	

$(document).on("ajax:success", '#purchase_btn, .back-btn, #pixi-form', function (event, data, status, xhr) {
  $("#response").html(data);
  toggleLoading;
});	

$(document).on("ajax:error", '#purchase_btn, .back-btn, #pixi-form', function (event, data, status, xhr) {
  if (status == 401) // # thrownError is 'Unauthorized'
      window.location.replace('/users/sign_in');
});	

