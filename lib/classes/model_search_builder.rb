class ModelSearchBuilder
  attr_reader :model, :page

  def initialize(cls, pg)
    @model, @page = cls, pg
  end

  # dynamically define search options based on selections
  def search_options col, val, status='active'
    if val
      x = val.is_a?(Array) ? set_str(val) : val
      {:sql => {:include => model}, :conditions => {col.to_sym => x, :status => status}, star: true, page: page}  
    else
      {sql: {include: model}, conditions: {status: status}, star: true, page: page}  
    end
  end

  def set_str arr
    arr.inject(''){|sum, a| sum << "|" unless sum.empty?; sum << a.to_s}
  end
end
