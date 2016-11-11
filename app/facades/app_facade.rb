class AppFacade
  attr_reader :params

  def initialize params
    @params = params.with_indifferent_access
  end

  def id
    @id = params[:id]
  end

  def cat
    @cat = params[:cid] || ''
  end

  def loc
    @loc ||= params[:loc]
  end

  def loc_name
    @loc_name ||= params[:loc_name]
  end

  def set_location request, user
    @loc, @loc_name = LocationManager::setup request.remote_ip, loc || region, loc_name, user.home_zip
  end

  def set_region action_name, request, homeID, zip=nil
    @region = homeID || LocationManager::retrieve_loc(action_name, request, zip)
  end

  def region
    @region
  end

  def action_name
    @action_name
  end

  def set_geo_data request, aname, homeID, user
    @action_name = aname
    set_region aname, request, homeID, user.home_zip
    set_location request, user
  end

  def adminFlg
    @adminFlg = params[:adminFlg].to_bool rescue false
  end

  def status
    @status = NameParse::transliterate params[:status] if params[:status]
  end

  def ptype
    @ptype = params[:ptype]
  end

  def url
    @url
  end

end

