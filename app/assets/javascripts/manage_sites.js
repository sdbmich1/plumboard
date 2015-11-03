// toggle url for manage sites process based on status and site type
function getManageSitesUrl() {
  var status = $(".active").text().toLowerCase().trim().replace(/\d/g, '');
  var stype = $("#site_type").val();
  var url = "../sites?status=" + status + "&stype=" + stype;
  processUrl(url);
}

$(document).on("change", "#site_type", function() {
  if ($("#site_type").length > 0) {
    getManageSitesUrl();
  }
});
