require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PayoneConnect do
  before(:each) do
    FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/",:body => "status=APPROVED\ntxid=18059493\nuserid=4923401")
    @request_data = {
     :mode           => "test",
     :amount         => 100,
     :cardholder     => "John Doe",
     :currency       => "CHF",
     :mid            => "12345",
     :cardexpiredate => "1202",
     :encoding       => "UTF-8",
     :key            => "827ccb0eea8a706c4c34a16891f84e7b",
     :aid            => "54321",
     :cardtype       => "V",
     :clearingtype   => "cc",
     :cardpan        => "4901170005495083",
     :request        => "authorization",
     :reference      => "00000000000000000001",
     :portalid       => "1234567",
     :cardcvc2       => 233
     }
    @finance_gate_connection = PayoneConnect.new("https://testapi.pay1.de/post-gateway/",@request_data)
    @uri = URI.parse("https://testapi.pay1.de/post-gateway/")
  end
  
  describe "connection" do
    it "should connect to the payone gateway" do
      https_connection = Net::HTTP.new(@uri.host, @uri.port)
      Net::HTTP.should_receive(:new).with(@uri.host,@uri.port).and_return(https_connection)
      @finance_gate_connection.request
    end
      
    it "should set the x form header" do
      @finance_gate_connection.request_header.should == {'Content-Type'=> 'application/x-www-form-urlencoded'}
    end
  end
  
  describe "general parameter assignment" do
    %w(portalid mid mode key encoding request).each do |parameter|
      it "should set the #{parameter} parameter" do
        @finance_gate_connection.request_data.should include("#{parameter}=#{@request_data[parameter]}")
      end
    end
  end
  
  describe "successfull request" do
    before(:each) do
      FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/", :body => "status=APPROVED\ntxid=18059493\nuserid=4923401")
    end
    it "should return the status" do
      @finance_gate_connection.request[:status].should == "APPROVED"
    end
    
    it "should return payones transaction id" do
      @finance_gate_connection.request[:txid].should == "18059493"
    end
    
    it "should return payones user id" do
      @finance_gate_connection.request[:userid].should == "4923401"
    end
  end
  
  describe "authorization parameter assignment" do
    %w(aid reference currency amount clearingtype).each do |parameter|
      it "should set the #{parameter} parameter" do
        @finance_gate_connection.request_data.should include("#{parameter}=#{@request_data[parameter]}")
      end
    end
  end
    
  describe "credit card payment parameter assignment" do
    %w(cardpan cardtype cardexpiredate cardcvc2 cardholder).each do |parameter|
      it "should set the #{parameter} parameter" do
        @finance_gate_connection.request_data.should include("#{parameter}=#{URI.encode(@request_data[parameter].to_s)}")
      end
    end
  end  
end