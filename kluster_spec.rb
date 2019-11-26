require 'rspec'
require './klusterizer'
require './area'
require './helpers'
require 'matrix'

describe 'k0' do

  it 'should init values' do
    a = Klusterizer.new()
    a.add_dimension("x", ["0","1","2"])
    a.add_dimension("y", ["0","1","2"])
    expect(a.dimension_end_point).to eq [2,2]

    a.init_values(1)
    expect(a.values).to eq [[1,1,1],
                            [1,1,1],
                            [1,1,1]]
    expect( a.area_eql?( Area.new([0,0], [1,1]), 1 )).to be true
  end
end

describe 'Klusterizing1' do
  before(:each) do
    @g = Klusterizer.new()
    @g.add_dimension("x",(0..10).map {|i| "#{i}" })
    @g.add_dimension("y",(0..10).map {|i| "#{i}" })
    @g.init_values( 10 )
  end


  it 'generates random points outside of areas' do
    # warn @g.dimension_end_point
    p = @g.new_random_point_outside_of([ Area.new([1,1],[10,10]), Area.new([1,0],[10,0]), Area.new([0,1],[0,10]) ])
    expect( p ).to eq [0,0]
  end

  it 'grow area well' do
    random_point = [5,5]

    area = Area.new(random_point, random_point)

    new_area = @g.grow_area( area )
    expect( new_area.to_a ).to eq( [ @g.dimension_start_point, @g.dimension_end_point ] )
  end


  it 'grow area well - 2' do
    random_point = [3,4]
    area = Area.new(random_point, random_point)
    @g.values[3][3] = 100
    new_area = @g.grow_area( area )
    expect( new_area.includes? random_point ).to be true
    expect( new_area.to_a ).to eq( [ [0,4], [10,10] ] )
  end

  it 'grow area well - loop' do
    (0..100).each do
      @g.init_values( 10 )
      random_point = [3,4]
      area = Area.new(random_point, random_point)
      @g.values[3][3] = 100
      new_area = @g.grow_area( area )
      expect( new_area.includes? random_point ).to be true
      expect( new_area.to_a ).to eq( [ [0,4], [10,10] ] )
    end

  end

  it 'clusterizing well loop' do
    (0..100).each do
      @g.init_values( 10 )
      random_point = [5,5]
      area = Area.new(random_point, random_point)
      @g.values[4][3] = 100
      clusters = @g.clusterize
      # warn clusters.inspect
      expect( (clusters.include? Area.new([5,0],[10,10])) ||
                  (clusters.include? Area.new([0,4],[10,10])) ||
                  (clusters.include? Area.new([4,4],[10,10])) ||
                  (clusters.include? Area.new([5,3],[10,10]))
      ).to be true
      expect( clusters.include? Area.new([4,3],[4,3]) ).to be true
    end
  end
end

describe 'Klusterizing2' do

  before(:each) do
    @k = Klusterizer.new()
    @k.add_dimension("Allocation", %q(1adt
1adt + 1chd[0-2]
1adt + 1chd[3-12]
1adt + 1chd[0-2] + 1chd[3-12]
1adt + 2chd[0-2]
1adt + 2chd[3-12]
2adt
2adt + 1chd[0-2]
2adt + 1chd[3-12]
3adt).split(/\n/))
    @k.add_dimension("Room type", ['Single', 'Standard', 'Junior Suite' ])
    @k.add_dimension("Meal type", ['AO', 'BB', 'HB']) # если добавить здесь третье значение, падают тесты в другом блоке
    @k.add_dimension("Date", (date_to_i("01/09/2019")..date_to_i("31/12/2019")).map {|i| "#{date_i_to_s(i)}" })
  end


  it 'should calc vectors' do
    # @k.new_point( [ '1adt', 'single','BB', '2000' ]  )
    fp = Vector[3,0,2]
    tp = Vector[6,2,3]
    shift_vec = Vector[0,-1,0]


    expect( @k.calc_slice_vector(fp, tp, shift_vec )).to eq Vector[6, -1, 3] # 2,2,3
    #expect((fp-tp)*slice_vec).to eq Vector[0,-2,0]

    # expect((fp-tp)*slice_vec + shift_vec).to eq Vector[2,1,3]
    expect((fp+shift_vec)).to eq Vector[3,-1,2]



    fp = Vector[1,2,3]
    tp = Vector[2,4,3]
    # slice_vec = Matrix[[0,1,0]]

    shift_vec = Vector[0,-1,0]
    expect((fp-tp)).to eq Vector[-1,-2,0]
    expect( @k.calc_slice_vector(fp, tp, shift_vec )).to eq Vector[2, 1, 3] # 2,2,3
    #expect((fp-tp)*slice_vec).to eq Vector[0,-2,0]

    # expect((fp-tp)*slice_vec + shift_vec).to eq Vector[2,1,3]
    expect((fp+shift_vec)).to eq Vector[1,1,3]
  end


  it 'should iterate all' do

    expect( @k.iterate_inner_all( [1,2,3], [2,3,4] ) ).to eq [[1, 2, 3], [1, 2, 4], [1, 3, 3], [1, 3, 4], [2, 2, 3], [2, 2, 4], [2, 3, 3], [2, 3, 4]]
    expect( @k.iterate_inner_all( [2,3], [1,2] ) ).to eq [[1,2],[1,3],[2,2],[2,3]]

  end

  it 'inits well' do
    expect(@k.dimension_end_point).to eq [9,2,2,121]
  end

  it 'generates random points inside of area' do
    random_point = @k.new_random_point
    # warn random_point.inspect
    (0..@k.dimension_names.size-1).each do |i|
      expect( random_point[i] ).to be >= @k.dimension_start_point[i]
      expect( random_point[i] ).to be <= @k.dimension_end_point[i]
    end
  end


  it 'should extend area' do

    @k.init_values( 0 )
    random_point = [5,1,0,64]
    area = Area.new(random_point, random_point)

    shift_vec = @k.zero_ary
    shift_vec[3] = -1

    new_area = @k.try_extend_area( random_point, random_point, shift_vec )
    expect( new_area.to_a ).to eq( [[5,1,0,0],[5,1,0,64]] )
  end



  it 'converts names to indexes' do
    expect( @k.names_to_coords(['1adt','Standard','AO','01/10/2019']) ).to eq [0,1,0,30]
  end

  it 'inits values by name' do

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'BB' ],
                        'Date' => (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 80 )


    point = @k.names_to_coords( ['1adt', 'Standard', 'BB', '15/10/2019'] )

    expect( @k.values.get_nested_value( point ) ).to eq 80

    new_area = @k.grow_area( Area.new( point, point) )
    expect( new_area.to_a ).to eq( [[ 0,0,1,30], [0,1,1,59]] )


  end



  it 'should return result' do
    @k.init_values( nil )
    #@k.init_by_names( { "Room type" => [ "Single"] }, 30 )
    #@k.init_by_names( { "Room type" => [ "Standard"] }, 50 )
    #@k.init_by_names( { "Room type" => [ "Junior Suite"] }, 100 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
               "Room type" => [ 'Single', 'Standard' ],
               'Meal type' => [ 'BB' ],
               'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
             }, 80.0 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'HB' ],
                        'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 100.0 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'AO' ],
                        'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 60.0 )

    clusters = @k.clusterize
    # warn( clusters.inspect )
    expect( @k.klusters_print( clusters ) ).to eq %Q(1adt\tSingle, Standard\tAO\t01/10/2019-30/10/2019:\t60.0\n) +
                                                  %Q(1adt\tSingle, Standard\tBB\t01/10/2019-30/10/2019:\t80.0\n) +
                                                  %Q(1adt\tSingle, Standard\tHB\t01/10/2019-30/10/2019:\t100.0)

  end
end

describe 'real test drive' do
  it 'should return result 2' do

    @k = Klusterizer.new()
    @k.add_dimension("Allocation", %q(1adt
1adt + 1chd[0-2]
1adt + 1chd[3-12]
1adt + 1chd[0-2] + 1chd[3-12]
1adt + 2chd[0-2]
1adt + 2chd[3-12]
2adt
2adt + 1chd[0-2]
2adt + 1chd[3-12]
3adt).split(/\n/))
    @k.add_dimension("Room type", ['Single', 'Standard', 'Junior Suite' ])
    @k.add_dimension("Meal type", ['AO', 'BB', 'HB']) # если добавить здесь третье значение, падают тесты в другом блоке
    @k.add_dimension("Date", (date_to_i("01/09/2019")..date_to_i("31/12/2019")).map {|i| "#{date_i_to_s(i)}" })

  @k.init_values( nil )
    @k.init_by_names( { "Room type" => [ "Single"] }, 30 )
    @k.init_by_names( { "Room type" => [ "Standard"] }, 50 )
    @k.init_by_names( { "Room type" => [ "Junior Suite"] }, 100 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'BB' ],
                        'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 80.0 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'HB' ],
                        'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 100.0 )

    @k.init_by_names( { "Allocation" => [ "1adt"],
                        "Room type" => [ 'Single', 'Standard' ],
                        'Meal type' => [ 'AO' ],
                        'Date' =>  (date_to_i("1/10/2019")..date_to_i("30/10/2019")).map { |i| date_i_to_s(i) }
                      }, 60.0 )

    clusters = @k.clusterize
    # warn( clusters.inspect )
    expect( @k.klusters_print( clusters ) ).to eq %Q(1adt\tSingle, Standard\tAO\t01/10/2019-30/10/2019:\t60.0\n) +
                                                      %Q(1adt\tSingle, Standard\tBB\t01/10/2019-30/10/2019:\t80.0\n) +
                                                      %Q(1adt\tSingle, Standard\tHB\t01/10/2019-30/10/2019:\t100.0)

  end
end
