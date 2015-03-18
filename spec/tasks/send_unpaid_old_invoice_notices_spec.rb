require 'spec_helper'
require 'rake'

describe 'manage server namespace rake task' do
  describe 'send_unpaid_old_invoice_notice' do
    before do
      load File.expand_path("../../../lib/tasks/manage_server.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it 'should send unpaid old invoice notice' do
      UserMailer.should_receive(:send_unpaid_old_invoice_notice).exactly(Invoice.unpaid_old_invoices.count).times
      Invoice.should_receive :unpaid_old_invoices
      Rake::Task['manage_server:send_unpaid_old_invoice_notices'].invoke
    end
  end
end