class Area
  attr_accessor :from_point, :to_point, :square, :value
  def initialize(from,to)
    raise "Dimensions of from and to points does not match" if from.size != to.size
    @from_point = []
    @to_point = []
    @value = nil

    @square = 1
    for i in (0..from.size-1) do
      @from_point[i] = [from[i],to[i]].min
      @to_point[i] = [from[i],to[i]].max
      @square *= @to_point[i]-@from_point[i] + 1
    end
  end

  def includes?(p)
    for i in (0..@from_point.size-1) do
      return false if @from_point[i]>p[i]
      return false if @to_point[i]<p[i]
    end
    return true
  end

  def ==(a)
    a.from_point==@from_point and a.to_point == @to_point
  end
  def <=>(a)
    self.from_point<=>a.from_point or self.to_point <=> a.to_point
  end

  def >(a)
    self.square > a.square
  end

  def <(a)
    self.square < a.square
  end

  def to_a
    [@from_point,@to_point]
  end

  def inspect
    to_s
  end
  def to_s
    "#{@from_point.inspect}-#{@to_point.inspect}"
  end
end