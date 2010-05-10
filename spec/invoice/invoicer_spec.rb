require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'configuration'
require 'invoice/invoicer'
require 'model/invoice'
require 'model/company'
require 'model/attendee'
require 'connector/base'

describe 'an Invoicer,' do
  before do
    @invoicer = Invoicer.new
  end

  it 'should have a default connector' do
    @invoicer.connector.should be_instance_of Connector::Base
  end

  describe 'when invoicing google' do
    before do
      Configuration.new.test
      @google = Company.new(:name => 'google', :firstname => 'john', :lastname => 'doe', :email => 'john@doe.com')
      @google.save
      @john = Attendee.new(:firstname => 'john', :lastname => 'doe', :email => 'john@doe.com', :company => @google)
      @john.save
    end

    it 'should tell connector to invoice john\'s invoiceables' do
      stub(@john).invoiceables {[1,2]}
      mock(@invoicer.connector).put_invoice(@google) {:invoice_id}
      @invoicer.invoice_company @google

      invoice=Invoice.first(:invoice_id => :invoice_id)
      invoice.company.should == @google
      entrance = invoice.invoiceables[0]
      entrance.invoice_item_id.should == 'AGF10P270'
      entrance.attendee.should == @john
    end
  end
end