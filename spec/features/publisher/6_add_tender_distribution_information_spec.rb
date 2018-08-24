# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Create request for tender', js: true do
  include RequestForTendersHelper

  let!(:publisher) {FactoryBot.create(:publisher)}

  let!(:request_for_tender) do
    FactoryBot.create(:request_for_tender,
                      publisher: publisher,
                      published_at: nil)
  end

  scenario 'should publish a request for tender' do
    given_a_publisher_who_has_logged_in

    when_they_publish_a_request_for_tender(request_for_tender)

    then_the_rft_should_appear_in_unpublished_tenders_as_publishing(
        request_for_tender
    )
  end

  scenario 'should not send admin an email when an already published request' \
           'for tender is published again' do
    given_a_publisher_who_has_logged_in
    when_they_publish_a_request_for_tender(request_for_tender)
    visit request_for_tender_build_path(request_for_tender, :distribution)
    expect {click_button 'Publish'}
        .to change {ActionMailer::Base.deliveries.count}.by(0)
  end

  scenario 'should display previous step of create request for tender wizard' do
    given_a_publisher_who_has_logged_in
    visit request_for_tender_build_path(request_for_tender, :distribution)
    click_link 'Previous'
    expect(page).to have_content 'Please add the documents you want the
                                        contractor to submit as part of their
                                        tender'
    expect(page).to have_content 'Add another required document'
  end
end

def given_a_publisher_who_has_logged_in
  login_as publisher, scope: :publisher
end

def when_they_publish_a_request_for_tender(request_for_tender)
  visit request_for_tender_build_path(request_for_tender, :distribution)

  fill_in 'Selling price', with: 1

  accept_confirm do
    click_button 'Publish'
  end

  expect(page).to have_content 'Your request for tender has been submitted, ' \
                               'it will take at most 24 hours before it ' \
                               'becomes accessible publicly'
end

def and_the_request_for_tender_should_have_a_purchase_tender_page(
    request_for_tender
)
  new_window = window_opened_by {click_link :purchase_link}
  within_window new_window do
    should_have_content_of_request_for_tender(request_for_tender)
  end
end

def then_the_rft_should_appear_in_unpublished_tenders_as_publishing(
    request_for_tender
)
  visit publisher_root_path
  within :css, '#unpublished-request-for-tenders' do
    within page.find('a', text: request_for_tender.project_name) do
      expect(page).to have_content request_for_tender.project_name
      expect(page).to have_content 'publishing..'
      expect(page).to have_content project_location request_for_tender
    end
  end
end