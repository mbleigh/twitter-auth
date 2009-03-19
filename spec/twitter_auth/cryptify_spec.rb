require File.dirname(__FILE__) + '/../spec_helper'

describe TwitterAuth::Cryptify do
  before do
    stub_basic!
  end

  it 'should have encrypt and decrypt methods' do
    TwitterAuth::Cryptify.should respond_to(:encrypt)
    TwitterAuth::Cryptify.should respond_to(:decrypt)
  end

  describe '.encrypt' do
    it 'should return a hash with :encrypted_data and :salt keys' do
      result = TwitterAuth::Cryptify.encrypt('some string')
      result.should be_a(Hash)
      result.key?(:encrypted_data).should be_true
      result.key?(:salt).should be_true
    end

    it 'should make a call to EzCrypto::Key.encrypt_with_password' do
      EzCrypto::Key.should_receive(:encrypt_with_password).once.and_return('gobbledygook')
      TwitterAuth::Cryptify.encrypt('some string') 
    end

    it 'should not have the same encrypted as plaintext data' do
      TwitterAuth::Cryptify.encrypt('some string')[:encrypted_data].should_not == 'some string'
    end
  end

  describe '.decrypt' do
    before do
      @salt = TwitterAuth::Cryptify.generate_salt
      TwitterAuth::Cryptify.stub!(:generate_salt).and_return(@salt)
      @string = 'decrypted string'
      @encrypted = TwitterAuth::Cryptify.encrypt(@string)
    end

    it 'should return the original string' do
      TwitterAuth::Cryptify.decrypt(@encrypted).should == @string
    end

    it 'should raise an argument error if encrypted data is provided without a salt' do
      lambda{TwitterAuth::Cryptify.decrypt('asodiaoie2')}.should raise_error(ArgumentError)
    end

    it 'should raise an argument error if a string or hash are not provided' do
      lambda{TwitterAuth::Cryptify.decrypt(23)}.should raise_error(ArgumentError)
    end
  end
end
