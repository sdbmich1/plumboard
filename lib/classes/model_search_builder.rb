class ModelSearchBuilder

  def initialize(cls, pg)
    @models, @page = cls, pg
  end

  # dynamically define search options based on selections
  def search_options col, val, status='active'
    if val
      {:sql => {:include => @models}, :conditions => {col.to_sym => val, :status => status}, star: true, page: @page}  
    else
      {sql: {include: @models}, conditions: {status: status}, star: true, page: @page}  
    end
  end
end
