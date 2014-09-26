function get_pixi_url() {
  var site_id = $("#site_id").val();
  var category_id = $("#category_id").val();
  var stype = $("#status_type").val();

  var url;
  switch (stype) {
    case "pending":
      url = "../pending_listings?status='pending'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "draft":
      url = "../temp_listings/unposted?status='new/edit'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "active":
      url = "../listings?status='active'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "expired":
      url = "../listings?status='expired'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "sold":
      url = "../listings?status='sold'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "removed":
      url = "../listings?status='removed'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "denied":
      url = "../listings?status='denied'&loc=" + site_id + "&cid=" + category_id;
      break;
    case "invoiced":
      url = "../listings/invoiced?loc=" + site_id + "&cid=" + category_id;
      break;
  }
  processUrl(url);
}

$(document).on("change", "#status_type", function() {
  if ($('#status_type').length > 0) {
    get_pixi_url();
  }
  url = "/pixi_posts/pixter_report?date_range=" + url;
});