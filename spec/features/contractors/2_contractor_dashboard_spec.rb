# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Contractor dashboard' do
  let!(:tender) { FactoryBot.create(:tender) }

  context 'when logged in' do
    background do
      login_as(tender.contractor, scope: :contractor)
    end

    scenario 'A contractor can view their dashboard' do
      visit contractor_root_path
      expect(page).to have_content 'Invitations To Tender'
    end

    scenario 'A contractor can view their private invitations to tender on their dashboard' do
      visit contractor_root_path
      # expect(tender.contractor.tenders).to be > 0
      expect(page).to have_content tender.project_name
    end

    scenario 'A contractor can view their purchased tender documents on their dashboard' do
      skip 'Spec not finished'
    end

    scenario 'A contractor can view their submitted tender documents on their dashboard' do
      skip 'Spec not finished'
    end
  end

  context 'when logged out' do
    scenario 'A contractor is redirected to the login page' do
      visit contractor_root_path

      expect(page)
        .to have_content 'You need to sign in or sign up before continuing.'
      expect(page).to have_content 'Log in'
      expect(page).to have_field('Email address')
      expect(page).to have_field('Password')
    end
  end
end
