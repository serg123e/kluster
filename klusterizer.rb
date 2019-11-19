require './array'

class Klusterizer
  attr_accessor :values, :dimension_names, :dimension_values, :dimension_start_point, :dimension_end_point
  def initialize
    @dimension_names = []
    @dimension_values = []
    @values = []
  end


  def add_dimension(name, array)
    @values.create_inner_array( array.size )
    dimension_names.push( name )
    dimension_values.push( array )
    @dimension_end_point = dimension_values.map { |d| d.size-1 }
    @dimension_start_point = dimension_values.map { 0 }
  end


  def init_values(value)

    iterate_inner_each( @dimension_start_point, @dimension_end_point ) do |point|
      @values.set_nested_value(point, value)
    end
  end

  def min(a,b)
    return (a>b)?b:a
  end

  def max(a,b)
    return (a>b)?a:b
  end

  def iterate_inner_all(from_point, to_point)
    res = []
    iterate_inner_each(from_point.clone, to_point.clone) do |r|
      res.push( r )
    end
    res
  end
  def iterate_inner_each( from_p, to_p, pref=[] )
    from_point = from_p.clone
    to_point = to_p.clone

    # warn( "iterate_inner_all #{pref.inspect} #{from_point.inspect} - #{to_point.inspect} ")
    if (from_point.size > 1) then
      from = from_point.shift
      to = to_point.shift
      # warn("iterate [#{pref.inspect}, #{from}..#{to}, #{from_point.inspect}-#{to_point.inspect} ] ")
      (min(from,to)..max(from,to)).each do |i|
        iterate_inner_each( from_point, to_point, [ *pref, i ] ) do |r|
          # warn "#{[*pref, i]}, #{from}..#{to}, #{from_point}-#{to_point}=#{r.inspect}"
          yield [ *r ]
        end
      end

    else
      from = min( from_point[0], to_point[0] )
      to = max(from_point[0], to_point[0])
      # warn("preparing #{pref.inspect}, #{from}..#{to}")
      (from..to).each do |i|

        yield [ *pref, i ]
      end
    end
  end

  def zero_ary
    (0..@dimension_names.size-1).map { 0 }
  end

  def grow_area( area )
    for i in (0..dimensions-1) do
      shift_ary = zero_ary
      shift_ary[i] = -1
      area = try_extend_area( area.from_point, area.to_point, shift_ary )

      shift_ary[i] = 1
      area = try_extend_area( area.to_point, area.from_point, shift_ary )
    end
    area
  end


  def dimensions
    return @dimension_names.size
  end
  def area_eql?(area, value)
    return false unless values.exist_nested_value?( area.from_point )
    return false unless values.exist_nested_value?( area.to_point )
    iterate_inner_each(area.from_point,area.to_point) do |point|
      return false if (values.get_nested_value( point ) != value )
    end
    return true
  end

  def new_random_point
    @dimension_values.map {|v| rand(v.size) }
  end

  def calc_slice_vector(from_point, to_point, shift_ary )
    down_point = to_point.to_a.clone
    (0..shift_ary.size-1).each do |i|
      if shift_ary[i]!=0 then
        down_point[i] = from_point[i]
      end
    end
    result = (Vector[*down_point] + Vector[*shift_ary])
    return result
  end

  def calc_slice_ary(from_point, to_point, shift_ary )
    calc_slice_vector(from_point, to_point, shift_ary ).to_a
  end


  #def try_extend_area(from_point, to_point, shift_ary)
  def try_extend_area(from_point2, to_point2, shift_ary)
    from_point = from_point2.clone
    to_point = to_point2.clone
    if @values.exist_nested_value?( from_point ) then
      val = @values.get_nested_value( from_point )
      # @dimension_names.each_with_index do |d,i|

      try_point = from_point
      next_point = (Vector[*try_point] + Vector[*shift_ary]).to_a
      if @values.exist_nested_value?( try_point ) then
        while (area_eql?( Area.new( try_point, calc_slice_ary(try_point, to_point, shift_ary ) ) , val)) do
          try_point = next_point
          next_point = (Vector[*try_point] + Vector[*shift_ary]).to_a
        end
      end
      from_point = try_point

      # end
      return Area.new( from_point, to_point )
    else
      warn "cant extend: #{from_point} does not exist"
      return Area.new( from_point, to_point )
    end
  end
end