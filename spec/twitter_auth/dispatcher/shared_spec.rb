require File.dirname(__FILE__) + '/../../spec_helper'

describe TwitterAuth::Dispatcher::Shared do
  include TwitterAuth::Dispatcher::Shared

  describe '#append_extension_to' do
    it 'should leave extensions alone if they exist' do
      append_extension_to('/fake.json').should == '/fake.json'    
      append_extension_to('/fake.xml').should == '/fake.xml'
    end

    it 'should append .json if no extension is provided' do
      append_extension_to('/fake').should == '/fake.json'
      append_extension_to('/verify/fake').should == '/verify/fake.json'
    end

    it 'should leave extensions alone even with query strings' do
      append_extension_to('/fake.json?since_id=123').should == '/fake.json?since_id=123'
      append_extension_to('/fake.xml?since_id=123').should == '/fake.xml?since_id=123'
    end

    it 'should add an extension even with query strings' do
      append_extension_to('/fake?since_id=123').should == '/fake.json?since_id=123'
    end
  end
end
