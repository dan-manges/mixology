module Runner
  def self.included(base)
    # p "Included into #{base.name}"
  end

  def self.extended(base)
    # p "Extended into #{base.class.name}"
  end

  def run
    Math.tan(Math::PI / 4)
  end
end