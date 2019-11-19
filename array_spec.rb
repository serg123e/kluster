require 'rspec'
require './array'

describe 'Nested arrays' do

  it 'should create nested arrays of given depth' do
    a = [0,0,0]
    b = a.create_inner_array(2)
    expect( b ).to eq [[nil,nil],
                       [nil,nil],
                       [nil,nil]
                      ]
    c = b.create_inner_array(1)
    expect( c ).to eq [[[nil],[nil]],
                       [[nil],[nil]],
                       [[nil],[nil]]
                      ]
  end

  it 'should get value of inner array' do
    a = [[[1],[6]],
         [[2],[5]],
         [[3],[4]]
    ]
    expect(a.get_nested_value([2,1,0])).to eq a[2][1][0]
    expect(a.get_nested_value([2,1,0])).to eq a[2][1][0]
    expect(a.get_nested_value([2,1,0])).to eq a[2][1][0]
    expect(a.get_nested_value([1,0,0])).to eq a[1][0][0]

  end

  it 'should set value of inner array' do
    a = [[[1],[6]],
         [[2],[5]],
         [[3],[4]]
    ]
    expect(a.set_nested_value([1,0,0], 10)).to eq 10
    expect(a.get_nested_value([1,0,0])).to eq 10

    expect(a.set_nested_value([1,1,0], 15)).to eq 15
    expect(a.get_nested_value([1,1,0])).to eq 15


  end

  it 'should check if value exist' do
    a = [[[1],[6]],
         [[2],[5]],
         [[3],[4]]
    ]
    expect(a.exist_nested_value?([1,0,0])).to be true
    expect(a.exist_nested_value?([10,10,0])).to be false
    expect(a.exist_nested_value?([-10,10,0])).to be false


  end
end