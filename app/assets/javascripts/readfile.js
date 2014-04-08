var px_img;

// preview image on file upload
$(document).on("change", "input[type=file]", function(evt){
    var style = 'usr-photo';

    // render image
    if($('#usr_photo').length == 0) 
      { 
        style = 'sm-thumb'; 
        if($('#pixi-camera-icon').length != 0) {
	  px_img = $('#list').html();  
	}
      }

    // clear files
    $('#list').empty();  

    handleFileSelect(evt, style);  
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

          /* build image preview based on form type
          if($('#usr_photo').length == 0) {
	    var btn_cls = 'btn btn-mini btn-primary mtop sm-bot close-image';
	    ctr = 'med-top no-left span1 center-wrapper left-form';
	    style += ' mleft15';
	    link = '<a href="#" class="' + btn_cls + '">Remove';
	    etype = 'div';
	  }
	  */

          // Render thumbnail.
	  var item = document.createElement(etype);
          item.innerHTML = ['<img class="', style, '" src="', e.target.result,
		          '" title="', escape(theFile.name), '"/>', link].join('');
          $(item).addClass(ctr);

	  // add item		  
          document.getElementById('list').insertBefore(item, null);
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

  var cnt = $('#list').children().length;
  var cntl = ($('#list').children().length > 1) ? true : false;
  if(!cntl) {
    $('#list').html(px_img);  
  }
  else {
    console.log('list count = ' + cnt);
  }
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

