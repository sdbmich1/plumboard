// *************
// Original plugin Gist: https://gist.github.com/268257
// Current repos: https://github.com/desandro/imagesloaded
// fix in response to: https://github.com/desandro/imagesloaded/issues/8
// 
// In case this is useful to anyone.
// *************


/*!
 * jQuery imagesLoaded plugin v1.0.4
 * http://github.com/desandro/imagesloaded
 *
 * MIT License. by Paul Irish et al.
 */

(function($, undefined) {

  // $('#my-container').imagesLoaded(myFunction)
  // or
  // $('img').imagesLoaded(myFunction)

  // execute a callback when all images have loaded.
  // needed because .load() doesn't work on cached images

  // callback function gets image collection as argument
  //  `this` is the container
  
  $.fn.imagesLoaded = function( callback ) {
    var $this = this,
        $images = $this.find('img').add( $this.filter('img') ),
        len = $images.length,
        blank = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///ywAAAAAAQABAAACAUwAOw==';
      
    // some browsers (IE9) fail to trigger image loaded when using cached images 
    // This flag is so we can account for this dumb MSIE situation.
    var can_use_cached_images = confirm_can_use_cached_images();

    function confirm_can_use_cached_images() {
      var result = 'Good browser';
      var arr_known_browsers_with_issues = ['MSIE 11.0', 'MSIE 10.0', 'MSIE 9.0'];

      // block to check for specific know buggy browsers.
      if (window.navigator.appName.match(/Microsoft/)) {
        result = window.navigator.appVersion.match(/MSIE [^;/]+/);
        if(result) result = result[0];
      }

      return ($.inArray(result, arr_known_browsers_with_issues) == -1);  // -1 means no match found.
    }

    function triggerCallback() {
      callback.call( $this, $images );
    }

    function imgLoaded( event ) {
      if ( --len <= 0 && event.target.src !== blank ){
        setTimeout( triggerCallback );
        $images.unbind( 'load error', imgLoaded );
      }
    }

    if ( !len ) {
      triggerCallback();
    }

    $images.bind( 'load error',  imgLoaded ).each( function() {
      if (can_use_cached_images == false) { 
        this.src = this.src.split('?')[0];
      }

      // cached images don't fire load sometimes, so we reset src.
      if (this.complete || typeof this.complete === "undefined"){
        var src = this.src;
        // webkit hack from http://groups.google.com/group/jquery-dev/browse_thread/thread/eee6ab7b2da50e1f
        this.src = blank;
        this.src = src;
      }
    });

    return $this;
  };

})(jQuery);
