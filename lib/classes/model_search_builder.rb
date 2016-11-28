class ModelSearchBuilder
  attr_reader :model, :page

  def initialize(cls, pg)
    @model, @page = cls, pg
  end

  # dynamically define search options based on selections
  def search_options col, val, status='active'
    if val
      {:sql => {:include => model}, :conditions => {col.to_sym => val, :status => status}, star: true, page: page}  
    else
      {sql: {include: model}, conditions: {status: status}, star: true, page: page}  
    end
  end
end
