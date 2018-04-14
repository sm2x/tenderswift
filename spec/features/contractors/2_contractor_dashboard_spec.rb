# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Contractor dashboard' do
  let!(:contractor) { FactoryBot.create(:contractor) }

  context 'when logged in' do
    background do
      login_as(contractor, scope: :contractor)
    end

    scenario 'A contractor can view their dashboard' do
      visit contractor_root_path
      expect(page).to have_content 'Invitations To Tender'
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