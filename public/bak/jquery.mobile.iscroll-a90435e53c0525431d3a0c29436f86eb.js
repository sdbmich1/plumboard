/*
 * jQuery Mobile in a iScroll plugin
 * Copyright (c) Kazuhiro Osawa
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * dependency: iScroll 3.7.1 http://cubiq.org/iscroll
 */
/*

-head1 name

iPhone like 'position fixed' header/footer manager

 */
(function(a){a(function(){function c(c){if(c.data("iscroll-plugin"))return;c.css({overflow:"hidden"});var d=0,e=c.find('[data-role="header"]');e.length&&(e.css({"z-index":1e3,padding:0,width:"100%"}),d+=e.height());var f=c.find('[data-role="footer"]');f.length&&(f.css({"z-index":1e3,padding:0,width:"100%"}),d+=f.height());var g=c.find('[data-role="content"]');g.length&&(g.css({"z-index":1}),g.height(a(window).height()-d-b),g.bind("touchmove",function(a){a.preventDefault()}));var h=c.find('[data-iscroll="scroller"]').get(0);if(h){var i=new iScroll(h,{desktopCompatibility:!0});setTimeout(function(){i.refresh()},0),c.data("iscroll-plugin",i)}}var b=34;a('[data-role="page"][data-iscroll="enable"]').live("pageshow",function(){c(a(this)),a.mobile.activePage.data("iscroll")=="enable"&&c(a.mobile.activePage)})})})(jQuery);