require 'date'
FROM_DATE = Date.new(1970,1,1)

class String
  def plural
    return self+"s"
  end
end

class Object
  def date_i_to_s(i)
    (FROM_DATE+i).strftime("%d/%m/%Y")
  end

  def date_to_i(s)
    if (s =~ /(\d+)\/(\d+)\/(\d+)/) then
      d = Date.new( $3.to_i, $2.to_i, $1.to_i )
    else
      warn s
      d = Date.parse( s )
    end
    return ( d - FROM_DATE ).to_i
  end

  def iterate_points_in_aryary(aryary, pos=0, pref=[] )# [  [1], [2..3], ]

    if pos<=aryary.size-1 then
      aryary[pos].each do |i|
        if (i.is_a?Range) then
          i.each do |j|
            npref = [*pref, j]
            iterate_points_in_aryary(aryary, pos+1, npref ) do |r|
              yield r
            end
          end
        else
          npref = [*pref, i]
          iterate_points_in_aryary(aryary, pos+1, npref ) do |r|
            yield r
          end
        end
      end
    else
      yield pref
    end

  end


end