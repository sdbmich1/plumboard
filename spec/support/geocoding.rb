google_json = <<-JSON
{
  "status": "OK",
  "results": [ {
  "types": [ "street_address" ],
  "formatted_address": "45 Main Street, Long Road, Neverland, England",
  "address_components": [ {
    "long_name": "45 Main Street, Long Road",
    "short_name": "45 Main Street, Long Road",
    "types": [ "route" ]
    }, {
	 "long_name": "Neverland",
         "short_name": "Neverland",
         "types": [ "city", "political" ]
       }, {
	    "long_name": "England",
            "short_name": "UK",
            "types": [ "country", "political" ]
	   } ],
    "geometry": {
		  "location": {
		          "lat": 0.0,
		          "lng": 0.0
		        }
    }
  } ]
}
JSON

FakeWeb.register_uri(:any, %r|http://maps\.googleapis\.com/maps/api/geocode|, :body => google_json)
