require File.dirname(__FILE__) + '/spec_helper.rb'

describe Munin::Plugin do

  before(:each) do
    @plugin = Munin::Plugin.new
  end

  it "should have fields" do
    @plugin.fields.should be_empty
  end

end
