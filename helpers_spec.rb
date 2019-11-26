require 'rspec'
require './helpers'
describe 'My behaviour' do

  it 'should parse dates as expected' do
    i = 18170
    expect( date_to_i("01/10/2019") ).to eq i
    expect( date_to_i("1/10/2019") ).to eq i
    expect( date_to_i("01/11/2019") ).to eq i+31

  end

  it 'should convert num to date' do
    i = 18170
    expect( date_i_to_s(i) ).to eq "01/10/2019"

  end

  it 'should iterate aryary' do
    aa = [  [1], [2,5], [4,5] ]
    res = []
    iterate_points_in_aryary(aa) do |p|
      res << p
    end
    expect(res).to eq [[1,2,4], [1,2,5], [1,5,4],  [1,5,5]]
  end

  it 'should iterate aryrange' do
    aa = [  [1], [2..3], [4..5] ]
    res = []
    iterate_points_in_aryary(aa) do |p|
      res << p
    end
    expect(res).to eq [[1,2,4], [1,2,5], [1,3,4],  [1,3,5]]
  end

  xit 'should iterate huge aryarys' do
    a = []
    (1..6).each do
      a << (0..9)
    end
    count = 0
    iterate_points_in_aryary(a) do |p|
      count += 1
    end
    expect( count ).to be 10**6
  end

end