var map, selectedLocation, myLocation, directionsDisplay, directionsService, url, geocoder, centerPt, markers, marker_num, locations;

// display map
function displayMap(centerLoc, showMkr, multiMkr, tFlg) {
  var zVar =  multiMkr ? 12 : 16;
  var myOptions = {
    zoom: zVar,
    center: centerLoc,
    mapTypeId: google.maps.MapTypeId.ROADMAP,
    zoomcontrol: true,
    zoomControlOptions: {
      position: google.maps.ControlPosition.LEFT_TOP
    }
  } 
  
  // render map  	
  if ( $('#map_canvas').length != 0 ) {
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    showDirections(map, centerLoc, showMkr, multiMkr, tFlg);	
  }	

  resizeMap();
}

function resizeMap() {
  google.maps.event.trigger(map, 'resize');
  map.setZoom( map.getZoom() );
}

function showDirections(map, centerLoc, showMkr, multiMkr, tFlg) {
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
      { alert('Address not found.'); }
  } 
}

function getMyLocation(dFlg, nearby) {
  // set default url for nearby events	
  url = '/listings.mobile';

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

  return url;
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

// get current user location
function getLocation(nearby){
  var geoOptions = {maximumAge: 60000, enableHighAccuracy: true, timeout: 100000 };  
  if (navigator.geolocation) {
    console.log("Geolocation is supported.");
  }
  navigator.geolocation.getCurrentPosition(function(position){ // geoSuccess

    // get city name
    getCityName(position.coords.latitude,position.coords.longitude);
  }, 
  function(error){       	              
    console.log('Error - getLocation failed. ' + error.message);
    set_home_location('');
    return false;
  }, geoOptions);    
}

// used to find city name
function getCity(lat, lng) {
  //url = "https://maps-api-ssl.google.com/maps/api/geocode/json?latlng="+lat+","+lng+"&sensor=true";
  url = "https://maps.googleapis.com/maps/api/geocode/json?latlng="+lat+","+lng+"&sensor=true";

  $.ajax(url).done(function(data) {
    for (var i = 0; i < data.results.length; i++) {
      for (var j = 0; j < data.results[i].address_components.length; j++) {
	for (var k = 0; k < data.results[i].address_components[j].types.length; k++) {
	  if (data.results[i].address_components[j].types[k] === 'locality') {
	    var city_name = data.results[i].address_components[j].long_name;
            $('#home_site_name').val(city_name);
	    console.log(' city name = ' + city_name);
	  }
	}
      }
    }
  });
}

// find nearest city based on geocode
function getCityName(lat, lng) {
  var latlng = new google.maps.LatLng(lat, lng);
  geocoder = new google.maps.Geocoder();

  geocoder.geocode({'latLng': latlng}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      if (results[0]) {
        var arrAddress = results[0].address_components;

        // loop thru results to grab city
	$.each(arrAddress, function (i, address_component) {
	  switch(address_component.types[0]) {
	  case 'locality':
	    var city_name = address_component.long_name;
	    //console.log('city = ' + city_name);
            $('#home_site_name').val(city_name);
	    set_home_location(city_name);
	    break;
	  default: 
	    break;
	  }
	});
      }
      else {
        console.log('No geocoder results found.');
      }
    }
    else {
      console.log('Geocoder failed due to: ' + status);
    }
  });
}

// open map
$(document).on('shown', '#mapDialog', function(e) {
  getLatLng(true);		
});
