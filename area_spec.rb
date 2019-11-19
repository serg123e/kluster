require 'rspec'
require './area'


describe 'Area funcionality' do

  it 'compares areas well' do
    expect( Area.new([0,0],[1,1]) ).to eq Area.new([1,1],[0,0])
  end

  it 'compares > well' do
    expect( Area.new([0,0],[2,2]) > Area.new([1,1],[0,0]) ).to be true
  end

  it 'compares == well' do
    expect( Area.new([0,0],[2,2]) == Area.new([1,1],[0,0]) ).to be false
    expect( Area.new([0,0],[2,2]) == Area.new([2,2],[0,0]) ).to be true
  end

  it 'calcs square' do
    expect( Area.new([0,0],[2,2]).square ).to eq 9
  end


end