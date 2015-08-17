var px_img;
var style = 'usr-photo';

// preview image on file upload
$(document).on("change", "input[type=file]", function(evt){
  var listID = $(this).attr('id') == 'usr_photo2' ? 'list2' : 'list';

  // check if correct style for image
  checkStyle();

  //  check if s3 upload
  if($('.js-s3_file_field').length == 0) {
    handleFileSelect(evt, style);  
  }
  else {
    load_image_uploader();
  }
  return false;
}); 

// used to select files via file api
function handleFileSelect(evt, style) {
  var files = evt.target.files; // FileList object

  // Loop through the FileList and render image files as thumbnails.
  for (var i = 0, f; f = files[i]; i++) {

    // Only process image files.
    if (!f.type.match('image.*')) {
      continue;
    }

    if (typeof FileReader !== "undefined") {
      var reader = new FileReader();

      // Closure to capture the file information.
      reader.onload = (function(theFile) {
        return function(e) {
	  var link = '', ctr = '', etype = 'span';

          // Render thumbnail.
	  renderThumb(style, link, ctr, etype, e.target.result, theFile.name, 'list');
        };
      })(f);

      // Read in the image file as a data URL.
      reader.readAsDataURL(f);
    }
  }
}

// close parent
$(document).on("click", ".close-image", function(){
  $(this).parent().remove();

  if($(this).prev().is('img')) {
    console.log('title = ' + $(this).prev().prop('title'));
    remove_file($(this).prev().prop('title'));
  }

  check_file_list();
});

function remove_file(fname) {
  var input, file;
  var files = $('#photo').prop("files");
  var names = $.map(files, function(val) { console.log(val.name); });

  input = $('#photo')[0];

  //Some sanity check if there are files at all
  if (!input) {
      return;
  } else if (!input.files[0]) {
      return;
  } else {
    for(var i = files.length; i--;) {
      if(files[i].name == fname){
        console.log('fname = ' + fname);
	files.splice(i, 1);
      }
    };
  }
}

// checks list of files to be uploaded
function check_file_list() {
  var cnt = $('#list').children().length;
  if(cnt > 1) {
    console.log('list count = ' + cnt);
  }
  else {
    $('#list').html(px_img);  
    console.log('reload image = ' + cnt);
  }
}

function renderThumb(style, link, ctr, etype, src, fileName, idName) {
  var item = document.createElement(etype);

  // build html for DOM
  item.innerHTML = ['<img class="', style, '" src="', src, '" title="', escape(fileName), '"/>', link].join('');
  $(item).addClass(ctr);

  // add item		  
  document.getElementById(idName).insertBefore(item, null);
}

function checkStyle() {
  if($('#usr_photo').length == 0 && $('#usr_photo2').length == 0) {
    style = 'sm-thumb'; 
    if($('#pixi-camera-icon').length != 0) 
      px_img = $('#list').html();  
    }
}
