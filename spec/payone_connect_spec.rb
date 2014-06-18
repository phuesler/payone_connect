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
    it "connects to the payone gateway" do
      https_connection = Net::HTTP.new(@uri.host, @uri.port)

      expect(Net::HTTP).to receive(:new).with(@uri.host,@uri.port) { https_connection }

      @finance_gate_connection.request
    end

    it "sets the x form header" do
      expect(@finance_gate_connection.request_header).to eql('Content-Type'=> 'application/x-www-form-urlencoded')
    end
  end

  describe "general parameter assignment" do
    %w(portalid mid mode key encoding request).each do |parameter|
      it "sets the #{parameter} parameter" do
        expect(@finance_gate_connection.request_data).to include("#{parameter}=#{@request_data[parameter]}")
      end
    end
  end

  describe "successful request" do
    before(:each) do
      FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/", :body => "status=APPROVED\ntxid=18059493\nuserid=4923401")
    end

    it "returns the status" do
      expect(@finance_gate_connection.request[:status]).to eql("APPROVED")
    end

    it "returns payone's transaction id" do
      expect(@finance_gate_connection.request[:txid]).to eql("18059493")
    end

    it "returns payone's user id" do
      expect(@finance_gate_connection.request[:userid]).to eql("4923401")
    end

    it 'ignores empty lines' do
      FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/", :body => "status=APPROVED\n\ntxid=18059493\nuserid=4923401")

      expect(@finance_gate_connection.request[:userid]).to eql("4923401")
    end

    it 'ignores empty values' do
      FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/", :body => "status=APPROVED\nmandate_identification=PO-11190784\nmandate_status=active\nmandate_text=\ncreditor_identifier=DE16ZZZ00000961533\niban=DE76460500010209043724\nbic=WELADED1SIE\n")

      expect(@finance_gate_connection.request[:mandate_identification]).to eql("PO-11190784")
    end
  end

  describe "response is redirect" do
    it "parses the redirect url correctly" do
      FakeWeb.register_uri(:post, "https://testapi.pay1.de/post-gateway/", :body => "status=REDIRECT\ntxid=18059493\nuserid=4923401\nredirecturl=https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=ABC&useraction=commit")

      expect(@finance_gate_connection.request[:redirecturl]).to eql("https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=ABC&useraction=commit")
    end
  end

  describe "authorization parameter assignment" do
    %w(aid reference currency amount clearingtype).each do |parameter|
      it "sets the #{parameter} parameter" do
        expect(@finance_gate_connection.request_data).to include("#{parameter}=#{@request_data[parameter]}")
      end
    end
  end

  describe "credit card payment parameter assignment" do
    %w(cardpan cardtype cardexpiredate cardcvc2 cardholder).each do |parameter|
      it "sets the #{parameter} parameter" do
        expect(@finance_gate_connection.request_data).to include("#{parameter}=#{URI.encode(@request_data[parameter].to_s)}")
      end
    end
  end
end
