var map, selectedLocation, myLocation, directionsDisplay, directionsService, url, geocoder, centerPt, markers, marker_num, locations;

// display map
function displayMap(centerLoc, showMkr, multiMkr, tFlg) {
  
  if (multiMkr)
    var zVar = 11;
  else
    var zVar = 16;
    	
  var myOptions = {
	zoom: zVar,
	center: centerLoc,
	mapTypeId: google.maps.MapTypeId.ROADMAP,
	zoomControl: true,
    zoomControlOptions: {
        position: google.maps.ControlPosition.LEFT_TOP
    }
  } 
  
  // display map  	
  if ( $('#map_canvas').length != 0 ) {
	map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
	
	// show directions
    if (!multiMkr) {	  
	  directionsDisplay.setMap(map);
    }	
	
	// show directions details
	if ( $('#directionsPanel').length != 0 ) {
		getDirections();
	 }
	
	// show markers
	showMarkers(map, centerLoc, showMkr, multiMkr, tFlg);	
  }	
  // resize
  google.maps.event.trigger(map, 'resize');
}

// show markers
function showMarkers(map, centerLoc, showMkr, multiMkr, tFlg) {
  if (markers !== undefined) {
  	if (markers.length > 10)
  		var mcnt = 10;
  	else
  		var mcnt = markers.length;
  }
  	
  // show marker
  if (showMkr) {	  
 	  var marker = new google.maps.Marker({
        position: centerLoc,
        map: map
      }); 
  }  
  
  // show multiple location markers
  if (multiMkr) {
    for(i = 0; i < mcnt; i++) {
      var mark = markers[i];
    
      // use toggle to determine which lat/lng is being used
      if (tFlg) {
  	    var pos = new google.maps.LatLng(mark[1], mark[2]);
        var title = mark[0];
	    var zindex = mark[3];
  	   }
	  else {
	    var pos = mark;
  	    var title = locations[i];
	    var zindex = 1;
      }
   
      // place marker
      var marker = new google.maps.Marker({
        position: pos,
        map: map,
        icon: 'http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=' + i.toString() + '|339999|000000',
        title: title,
        zIndex: zindex
      });
    }
  }
}

// initialize google map
function NewInitialize(lat,lng, showMkr) {
  directionsService = new google.maps.DirectionsService();	
  directionsDisplay = new google.maps.DirectionsRenderer();
  selectedLocation = new google.maps.LatLng(lat,lng);
  
  // show map
  displayMap(selectedLocation, showMkr, false, false);
}

function loadLocations(addrs, tFlg) {

  if (tFlg)
  	getLocCenter(addrs, tFlg);
  else {
    processLocations(addrs, tFlg);
  }
      	
}

// process long/lat array for nearby events based on given lat/long
function getLocCenter(addrs, tFlg) {
  markers = addrs;

  if (myLocation !== undefined) {
  	displayMap(myLocation, false, true, tFlg); 
  }
  else {
  	if ( addrs !== undefined ) {
  		k = addrs.length-1;
  	    var addr = addrs[k];
		var latLng = new google.maps.LatLng(addr[1], addr[2]); 
	  	displayMap(latLng, false, true, tFlg); 
  	}
  }
}

// process long/lat array for nearby events based on full address
function processLocations(addrs, tFlg) {	
  markers = [];
  marker_num = 0;
  geocoder = new google.maps.Geocoder();
  centerPt = new google.maps.LatLngBounds(); 
  locations = addrs;
    
  if ( addrs !== undefined ) {
      for(k=0;k<addrs.length;k++){
        var addr = addrs[k];
        geocoder.geocode({'address':addr},function(res,stat){
          if(stat==google.maps.GeocoderStatus.OK){
            // add the point to the LatLngBounds to get center point, add point to markers
            centerPt.extend(res[0].geometry.location);
            markers[marker_num]=res[0].geometry.location;
            marker_num++;
                        
            // actually display the map and markers, this is only done the last time
            if(k == addrs.length) {
                // It's the last address so we can display the map
				displayMap(centerPt.getCenter(), false, true, tFlg); 
          	} 
        }         
      }); 
	}                    	
  }	
}

// get longitude & latitude
function getLatLng(showMkr) {
  if ( $('.lnglat').length != 0 ) {
  	var lnglat = $('.lnglat').attr("data-lnglat");
	if ( lnglat !== undefined && lnglat != '' ) {
  		var lat = parseFloat(lnglat.split(', ')[0].split('["')[1]);
  		if ( !isNaN(lat) ) {
  			var lng = parseFloat(lnglat.split(', "')[1].split('"]')[0]); 
  		} 	
  		else {
  			lat = parseFloat(lnglat.split(', ')[0].split('[')[1]);
  			var lng = parseFloat(lnglat.split(', ')[1].split(']')[0]);  	
  		} 
  		NewInitialize(lat,lng, showMkr); // get position
	} else
	{
		alert('Address not found.');
	}
	
  } 
}

function getMyLocation(dFlg, nearby) {
  // set default url for nearby events	
  url = '/nearby_events.mobile';

  var geoOptions = {maximumAge: 60000, enableHighAccuracy: true, timeout: 30000 };  
  navigator.geolocation.getCurrentPosition(function(position){ // geoSuccess
       myLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);

    // display nearby events?
    if (nearby) {
    	if (myLocation !== undefined) {    		
  			var parts = myLocation.toString().split(')'); 
  			var newLoc = parts[0].split('(');
      		url = url + '?loc=' + newLoc[1];
      	}
       	  	 
      	// change the page              
    	window.location.href= url; 	
       }
                     
       // check for directions
       if (dFlg) {     
    	  if ( $('#mode').length != 0 ) 
    	  	{ var selectedMode = $('#mode').val(); }
    	  else 
    	  	{ var selectedMode = 'DRIVING'; }
    	  	
          var request = {origin: myLocation, destination: selectedLocation, travelMode: google.maps.TravelMode[selectedMode] };        
          directionsService.route(request, function(response, status) {
    			if (status == google.maps.DirectionsStatus.OK) 
    				{ directionsDisplay.setDirections(response); }       	
       			});       	
       	}       
    }, 
    function(error){       	              
		if (!dFlg)
    	  goToUrl(url); // change the page
    }, geoOptions);    
     
}

function calcRoute() {
  getLatLng(false);  // get longitude & latitude of destination
  getMyLocation(true, false);  // get user location 
}

function getDirections() {
	$('#directionsPanel').empty();
	directionsDisplay.setPanel(document.getElementById("directionsPanel"));	
}

// detect browser to set map layout
function detectBrowser() {
  var useragent = navigator.userAgent;
  var mapdiv = document.getElementById("map_canvas");
  
  if (useragent.indexOf('iPhone') != -1 || useragent.indexOf('Android') != -1 ) {
	mapdiv.style.width = '100%';
    mapdiv.style.height = '100%';
	} 
  else {
	mapdiv.style.width = '600px';
    mapdiv.style.height = '800px';
	}
};
