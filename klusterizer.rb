require './array'

class Klusterizer
  attr_accessor :values, :dimension_names, :dimension_values, :dimension_start_point, :dimension_end_point,
                :dimension_index, :dimension_value_index
  def initialize
    @dimension_names = []
    @dimension_values = []
    @dimension_index = {}
    @dimension_value_index = []
    @values = []
  end


  def add_dimension(name, values)

    @values.create_inner_array( values.size )
    dimension_names.push( name )
    dimension_values.push( values )
    current_dimension_index = @dimension_names.size - 1
    @dimension_value_index[current_dimension_index] = Hash.new()

    @dimension_index[name] = current_dimension_index
    values.each_with_index do |value, value_index|
      @dimension_value_index[current_dimension_index][value] = value_index
    end

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
    iterate_inner_each(from_point, to_point) do |r|
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
    area.value = values.get_nested_value( area.from_point )
    return area
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

  def area_set(area, value)

    #return false unless values.exist_nested_value?( area.from_point )
    #return false unless values.exist_nested_value?( area.to_point )
    iterate_inner_each(area.from_point,area.to_point) do |point|
      values.set_nested_value( point, value )
    end

    return value

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


  def point_outside_of_list?(p,list)
    list.each do |a|
      return false if (a.includes?(p))
    end
    return true
  end

  def new_random_point_outside_of(list)
    list_square = list.map { |a| a.square }.inject(0,:+)
    @total_square ||= Area.new( @dimension_start_point, @dimension_end_point ).square

    if (list_square == @total_square) then # clusterizing done
      # warn "clusterizing done"
      return false
    elsif (list_square > @total_square) then
      warn("list square #{list_square} > #{total_square}, therefore area list have intersections")
      return false
    end

    iterations = 0
    while (iterations < @total_square*10) do # TODO: how to iterate well?
      iterations += 1
      p = new_random_point()
      return p if (values.exist_nested_value?(p) and point_outside_of_list?(p,list))
    end

    warn("after #{iterations} no new points in list #{list}")
    return false

  end

  #def try_extend_area(from_point, to_point, shift_ary)
  def clusterize
    res = []
    while (random_point = new_random_point_outside_of(res)) do
      area = Area.new(random_point, random_point)
      new_area = grow_area( area )

      area_set( new_area, nil )
      # warn("cluster: #{new_area.to_s}")
      res.push( new_area )
    end
    return res.sort {|a,b| a.value <=> b.value or a.square<=> b.square}
  end

  def dimension_iterable?( index )
    if (dimension_values[ index].size > 10) then
      return true
    else
      return false
    end
  end

  def print_value( dimension_index, from, to )
    if (from == 0 and to == dimension_values[ dimension_index ].size - 1 ) then
      return "All "+dimension_names[ dimension_index ].downcase.plural
    else
      if dimension_iterable?( dimension_index ) then
        from_value = dimension_values[dimension_index][ from ]
        to_value = dimension_values[dimension_index][ to ]
        return "#{from_value}-#{to_value}"
      else
        return (from..to).map { |value_index| dimension_values[dimension_index][value_index] }.join(", ")
      end
    end
  end

  def names_to_coords( names )
    res = []
    raise "wrong size of named vector: #{names.size} instead of #{dimensions()}" if names.size != dimensions()
    names.each_with_index do |value_name, dimension_index|
      if (@dimension_value_index[dimension_index].has_key? value_name) then
        res[dimension_index] = @dimension_value_index[dimension_index][value_name]
      else
        raise "wrong name '#{value_name}' in #{dimension_index} position of named vector, possible values: "+
                  "#{@dimension_value_index[dimension_index].keys.join(",")}"
      end
    end
    return res
  end

  def set_by_nested_names( names, value )
    point = names_to_coords(names)
    values.set_nested_value( point, value )
  end

  def dimension_value_to_index(dimension_index, value_name)
    if (@dimension_value_index[dimension_index].has_key? value_name) then
      return @dimension_value_index[dimension_index][value_name]
    else
      raise "Wrong position #{value_name} for dimension Nr#{dimension_index}"
    end
    retrurn -1
  end

#  def dimension_value_to_index(dimension_index, value_name)
 #   @dimension_value_index[dimension_index][value_name]
 # end


  def nameshash_to_aryary(hash)
    res = Array(dimensions)
    @dimension_names.each_with_index do |dimension_name, dimension_index|
      if (hash.has_key? dimension_name) then
        if (hash[dimension_name].is_a?Array) then
          value_names = hash[dimension_name]
          res[dimension_index] =  value_names.map { |value_name| dimension_value_to_index(dimension_index, value_name) }
        elsif (hash[dimension_name].is_a?Range) then
          raise "TODO: process ranges in nameshash_to_aryary, use arrays"
        else
          res[dimension_index] = @dimension_value_index[dimension_index][ hash[dimension_name] ]
        end
      else
        res[dimension_index] = (0..(@dimension_values[dimension_index].size-1))
        warn "axis #{dimension_name} not defined, usin all range: #{res[dimension_index].inspect}"
      end
    end
    return res
  end


  def iterate_by_names_as_points( hash )
    aryary = nameshash_to_aryary( hash )
    iterate_points_in_aryary( aryary ) do |point|
      yield point
    end
  end

  def init_by_names( hash, value )
  #hash =   { "Allocation" => [ "1adt"],
  #                    "Room type" => [ 'Single', 'Standard' ],
  #                    'Meal type' => [ 'BB' ],
  #                    'Date' => [ (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i)} ]
  #                  }
  # , 80 )

    iterate_by_names_as_points( hash ) do |point|
      # warn point.inspect
      values.set_nested_value( point, value )
    end

  end


  def klusters_print( list )
    rows = []
    list.each do |area|
      dims = []
      dimension_names.each_with_index do |name,dimension_index|
        dims << print_value( dimension_index, area.from_point[dimension_index], area.to_point[dimension_index] )
      end
      rows << "#{dims.join("\t")}:\t#{area.value}"
    end
    return rows.join("\n")
  end

  def try_extend_area(from_point2, to_point2, shift_ary)
    from_point = from_point2.clone
    to_point = to_point2.clone
    if @values.exist_nested_value?( from_point ) then
      val = @values.get_nested_value( from_point )
      try_point = from_point
      next_point = (Vector[*try_point] + Vector[*shift_ary]).to_a
      if @values.exist_nested_value?( try_point ) then
        while (area_eql?( Area.new( try_point, calc_slice_ary(try_point, to_point, shift_ary ) ) , val)) do
          try_point = next_point
          next_point = (Vector[*try_point] + Vector[*shift_ary]).to_a
        end
      end
      from_point = try_point
      return Area.new( from_point, to_point )
    else
      return Area.new( from_point, to_point )
    end
  end
end