require File.dirname(__FILE__) + '/spec_helper.rb'

class TestPlugin < Munin::Plugin
  declare_field :test
end

describe Munin::Plugin do

  before(:each) do
    @plugin = TestPlugin.new
  end

  it "should have a new field with declare_field" do
    @plugin.fields.should == [ Munin::Field.new(:test) ]
  end

end
