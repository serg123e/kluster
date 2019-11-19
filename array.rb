class Array
  def create_inner_array( size, default_value=nil )
    if (self.size>0) then
      for i in (0..self.size-1) do
        if (self[i].is_a?Array) then
          self[i].create_inner_array( size, default_value )
        else
          self[i] = (1..size).map{ default_value }
        end
      end
    else
      (0..size-1).each do |i|
        self[i] = default_value
      end
    end

    return self
  end

  def exist_nested_value?(coords)
    subarray = self
    coords.each do |v|
      if v>=0 and v<=subarray.size-1 then
        subarray = subarray[v]
      else
        warn("#{v} outside of bounds: 0..#{subarray.size-1}")
        return false
      end
    end
    return !(subarray.nil?)
  end

  def to_s
    self.join(",")
  end

  def get_nested_value(coords)
    subarray = self
    coords.each do |v|
      if v>=0 and v<=subarray.size-1 then
        subarray = subarray[v]
      else
        raise "Wrong index #{v} in nested coords #{coords.inspect}"
      end
    end
    return subarray
  end

  def set_nested_value(coords, value)
    subarray = self
    coords.each_with_index do |v,i|
      if (i==coords.size-1) then
        return subarray[v] = value
      else
        subarray = subarray[v]
      end
    end
  end
end