# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContractorMailer, type: :mailer do
  describe 'Invitation to tender' do
    let!(:tender) { FactoryBot.build(:tender) }

    let(:mail) do
      ContractorMailer.request_for_tender_email(
        tender,
        tender.request_for_tender
      ).deliver_now
    end

    it 'renders the subject' do
      expect(mail.subject)
        .to eq("Invitation to Tender for #{tender.project_name}")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([tender.contractor.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['projects@buildpals.com'])
    end
  end
end