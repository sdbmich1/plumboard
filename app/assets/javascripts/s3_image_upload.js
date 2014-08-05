var i=-1, maxFiles=15, j=0;
var goUpload = true;

// direct s3 file field
function load_image_uploader() {
  if( $('.js-s3_file_field').length > 0 ) {
    var $progress = $('.progress');
    var $meter = $('.meter');
    $progress.hide('fast');

    $('.js-s3_file_field').each(function() {
      var progress = 0;
      var $this = $(this);

      // check which page this is for
      if( $('#pixi-form').length > 0 ) {
        var str = ["#pixi-form", "temp_listing_pictures_attributes_", "temp_listing[pictures_attributes]["];
      }
      else if( $('#category-form').length > 0 ) {
        var str = ["#category-form", "category_pictures_attributes_", "category[pictures_attributes]["];
      }
      else {
        var str = [".uform", "user_pictures_attributes_", "user[pictures_attributes]["];
      }

      // process files for s3 upload
      $this.S3FileField({
        start: function(e, data) {
	  goUpload = true;
        },
        add: function(e, data) {
	  var uploadFile = data.files[0];

	  // check if correct style for image
	  checkStyle();

	  // check for valid file types
	  if (!(/\.(bmp|gif|jpg|jpeg|tiff|png)$/i).test(uploadFile.name)) {
	    goUpload = fileErrorHandler($progress, uploadFile.name + ' must be GIF, JPG, or PNG file');
	  }
	  
	  // check for valid file size
	  if (uploadFile.size > 5000000) { // 5mb
	    goUpload = fileErrorHandler($progress, uploadFile.name + ' is too large, max size is 5MB');
	  }

	  if (goUpload == true && j < maxFiles) {
            $progress.show('fast');
            j = j + 1;  // increment file counter

	    $('#list').empty();
            $(".tmp_img").remove();  // reset old list of files

	    // Render thumbnail.
	    var reader = new FileReader();
	    reader.onload = function(e) {
	      renderThumb(style, '', '', 'span', e.target.result, uploadFile.name);
              $progress.show('fast');
	    }

            // Read in the image file as a data URL.
	    reader.readAsDataURL(uploadFile);
	    data.submit();
	  }
	  else {
	    if(j >= maxFiles)
	     goUpload = fileErrorHandler($progress, "Max number of files is " + maxFiles);
	  }
        },
        progressall: function(e, data) {
	  progress = parseInt(data.loaded / data.total * 100, 10);
	  $('.progress .meter').css('width', progress + '%');
        },
        fail: function(e, data) {
	  alert('File upload error: ' + data.failReason);
          hideIndicator($progress);
        },
        stop: function(e, data) {
          hideIndicator($progress);
	  toggleLoading();
        },
        done: function(e, data) {
          i = i + 1;  // increment file counter
	  appendFields(data, i, str);
        }
      });
    });
  }
}

// check for change in file list
$(document).on("click", ".js-s3_file_field", function(e, content) {
  i = -1;  // reset counter
  j = 0;
  goUpload = true;
});

// add files to DOM
function appendFields(data, i, str) {
  var txt = '<input type="hidden" id="' + str[1] + i + '_direct_upload_url" value="' +
    data.result.url + '" name="' + str[2] + i + '][direct_upload_url]" class="tmp_img" />' +
    '<input type="hidden" id="' + str[1] + i + '_photo_file_name" value="' +
    data.result.filename + '" name="' + str[2] + i + '][photo_file_name]" class="tmp_img" />' +
    '<input type="hidden" id="' + str[1] + i + '_photo_file_path" value="' +
    data.result.filepath + '" name="' + str[2] + i + '][photo_file_path]" class="tmp_img" />' +
    '<input type="hidden" id="' + str[1] + i + '_photo_file_size" value="' +
    data.result.filesize + '" name="' + str[2] + i + '][photo_file_size]" class="tmp_img" />' +
    '<input type="hidden" id="' + str[1] + i + '_photo_content_type" value="' +
    data.result.filetype + '" name="' + str[2] + i + '][photo_content_type]" class="tmp_img" />';
  $(str[0]).append(txt);
}

// handle file load errors
function fileErrorHandler($progress, msg) {
  alert(msg);

  // check if file upload indicators should be cleared
  if(j < 1) {
    hideIndicator($progress);
  }
  return false;
}

function hideIndicator($progress) {
  if(j >= 1) {
    $progress.hide('fast');
    $("#spinner").hide();
  }
}