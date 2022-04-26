# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe 'validate_date_bounds' do
    let(:invoice) do
      build(:invoice, from_date: Time.zone.now - 2.days, to_date: Time.zone.now)
    end

    it 'ensures from_date is before to_date' do
      expect(invoice).to be_valid
    end

    context 'when from_date is after to_date' do
      let(:invoice) do
        build(:invoice, from_date: Time.zone.now + 2.days, to_date: Time.zone.now)
      end

      it 'ensures from_date is before to_date' do
        expect(invoice).not_to be_valid
      end
    end
  end

  describe 'sequential_id' do
    let(:subscription) { create(:subscription) }

    let(:invoice) do
      build(
        :invoice,
        from_date: Time.zone.now - 2.days,
        to_date: Time.zone.now,
        subscription: subscription,
      )
    end

    it 'assigns a sequential id to a new invoice' do
      invoice.save

      aggregate_failures do
        expect(invoice).to be_valid
        expect(invoice.sequential_id).to eq(1)
      end
    end

    context 'when sequential_id is present' do
      before { invoice.sequential_id = 3 }

      it 'does not replace the sequential_id' do
        invoice.save

        aggregate_failures do
          expect(invoice).to be_valid
          expect(invoice.sequential_id).to eq(3)
        end
      end
    end

    context 'when invoice alrady exsits' do
      before do
        create(
          :invoice,
          from_date: Time.zone.now - 2.days,
          to_date: Time.zone.now,
          subscription: subscription,
          sequential_id: 5,
        )
      end

      it 'takes the next available id' do
        invoice.save

        aggregate_failures do
          expect(invoice).to be_valid
          expect(invoice.sequential_id).to eq(6)
        end
      end
    end

    context 'with invoices on other organization' do
      before do
        create(
          :invoice,
          from_date: Time.zone.now - 2.days,
          to_date: Time.zone.now,
          sequential_id: 1,
        )
      end

      it 'scopes the sequence to the organization' do
        invoice.save

        aggregate_failures do
          expect(invoice).to be_valid
          expect(invoice.sequential_id).to eq(1)
        end
      end
    end
  end
end
