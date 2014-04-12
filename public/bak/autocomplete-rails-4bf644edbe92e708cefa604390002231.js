/*
* Unobtrusive autocomplete
*
* To use it, you just have to include the HTML attribute autocomplete
* with the autocomplete URL as the value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete">
*
* Optionally, you can use a jQuery selector to specify a field that can
* be updated with the element id whenever you find a matching value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete" data-id-element="#id_field">
*/
(function(a){var b=null;a.fn.railsAutocomplete=function(){var b=function(){this.railsAutoCompleter||(this.railsAutoCompleter=new a.railsAutocomplete(this))};return a.fn.on!==undefined?$(document).on("focus",this.selector,b):this.live("focus",b)},a.railsAutocomplete=function(a){_e=a,this.init(_e)},a.railsAutocomplete.fn=a.railsAutocomplete.prototype={railsAutocomplete:"0.0.1"},a.railsAutocomplete.fn.extend=a.railsAutocomplete.extend=a.extend,a.railsAutocomplete.fn.extend({init:function(b){function c(a){return a.split(b.delimiter)}function d(a){return c(a).pop().replace(/^\s+/,"")}b.delimiter=a(b).attr("data-delimiter")||null,a(b).autocomplete({html:!0,source:function(c,f){a.getJSON(a(b).attr("data-autocomplete"),{term:d(c.term)},function(){arguments[0].length==0&&(arguments[0]=[],arguments[0][0]={id:"",label:"no existing match"}),a(arguments[0]).each(function(c,d){var f={};f[d.id]=d,a(b).data(f)}),f.apply(null,arguments)})},change:function(b,c){if(a(a(this).attr("data-id-element")).val()=="")return;a(a(this).attr("data-id-element")).val(c.item?c.item.id:"");var d=a.parseJSON(a(this).attr("data-update-elements")),e=c.item?a(this).data(c.item.id.toString()):{};if(d&&a(d["id"]).val()=="")return;for(var f in d)a(d[f]).val(c.item?e[f]:"")},search:function(){var a=d(this.value);if(a.length<2)return!1},focus:function(){return!1},select:function(d,f){var g=c(this.value);g.pop(),g.push(f.item.value);if(b.delimiter!=null)g.push(""),this.value=g.join(b.delimiter);else{this.value=g.join(""),a(this).attr("data-id-element")&&a(a(this).attr("data-id-element")).val(f.item.id);if(a(this).attr("data-update-elements")){var h=a(this).data(f.item.id.toString()),i=a.parseJSON(a(this).attr("data-update-elements"));for(var j in i)a(i[j]).val(h[j])}}var k=this.value;return a(this).bind("keyup.clearId",function(){a(this).val().trim()!=k.trim()&&(a(a(this).attr("data-id-element")).val(""),a(this).unbind("keyup.clearId"))}),a(b).trigger("railsAutocomplete.select",f),!1}})}}),a(document).ready(function(){a("input[data-autocomplete]").railsAutocomplete()})})(jQuery);