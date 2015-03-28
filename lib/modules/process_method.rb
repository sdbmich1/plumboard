module ProcessMethod

  # get model attributes
  def self.get_attr model, arr
    attr = model.attributes
    arr.map {|x| attr.delete x}
    attr
  end
end
