require 'rspec'
require './klusterizer'
require './area'
require 'matrix'

describe 'Klusterizing' do

  before() do
    require './klusterizer'
    @k = Klusterizer.new()
    @k.add_dimension("allocation", %q(1adt
1adt + 1chd[0-2]
1adt + 1chd[3-12]
1adt + 1chd[0-2] + 1chd[3-12]
1adt + 2chd[0-2]
1adt + 2chd[3-12]
2adt
2adt + 1chd[0-2]
2adt + 1chd[3-12]
3adt).split(/\n/))
    @k.add_dimension("Room type", ['single', 'standard', 'junior suite' ])
    @k.add_dimension("Meal type", ['AO', 'BB' ])
    @k.add_dimension("Date", (1000..1099).map {|i| "#{i}" })
  end


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
    expect(@k.dimension_end_point).to eq [9,2,1,99]
  end

  it 'generates random points inside of area' do
    random_point = @k.new_random_point
    warn random_point.inspect
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

  it 'grow area well' do
    g = Klusterizer.new()
    g.add_dimension("x",(0..10).map {|i| "#{i}" })
    g.add_dimension("y",(0..10).map {|i| "#{i}" })
   # g.add_dimension("z",(50..60).map {|i| "#{i}" })
    # @k.add_dimension("Date", (1000..1099).map {|i| "#{i}" })
    g.init_values( 10 )

    random_point = [5,5]

    area = Area.new(random_point, random_point)

    new_area = g.grow_area( area )
    expect( new_area.to_a ).to eq( [ g.dimension_start_point, g.dimension_end_point ] )
  end

  it 'grow area well - 2' do
    g = Klusterizer.new()
    g.add_dimension("x",(0..10).map {|i| "#{i}" })
    g.add_dimension("y",(0..10).map {|i| "#{i}" })
    g.init_values( 10 )
    random_point = [5,5]
    area = Area.new(random_point, random_point)
    g.values[3][3] = 100
    new_area = g.grow_area( area )
    expect( new_area.to_a ).to eq( [ [0,4], [10,10] ] )
  end



  it 'clusterizing well' do
    g = Klusterizer.new()
    g.add_dimension("x",(0..10).map {|i| "#{i}" })
    g.add_dimension("y",(0..10).map {|i| "#{i}" })
    g.init_values( 10 )
    random_point = [5,5]
    area = Area.new(random_point, random_point)
    g.values[3][3] = 100
    clusters = g.clusterize.sort {|a,b| a.square <=> b.square }
    expect( clusters ).to eq [ Area() ]
  end

  xit 'should return result' do
    @k.klusters_print .should eq %q(1adt, single|standard, BB, 1/10/2019-30/10/2019: 80.0
    1adt, single|standard, HB, 1/10/2019-30/10/2019: 100.0
    1adt, single|standard, FB, 1/10/2019-30/10/2019: 120.0)

  end


end
