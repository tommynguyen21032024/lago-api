# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InvoiceSubscription, type: :model do
  let(:invoice_subscription) { create(:invoice_subscription, properties: properties) }
  let(:invoice) { invoice_subscription.invoice }
  let(:subscription) { invoice_subscription.subscription }

  let(:from_datetime) { '2022-01-01 00:00:00' }
  let(:to_datetime) { '2022-01-31 23:59:59' }
  let(:charges_from_datetime) { '2022-01-01 00:00:00' }
  let(:charges_to_datetime) { '2022-01-31 23:59:59' }

  let(:properties) do
    {
      from_datetime: from_datetime,
      to_datetime: to_datetime,
      charges_from_datetime: charges_from_datetime,
      charges_to_datetime: charges_to_datetime,
    }
  end

  describe '#fees' do
    it 'returns corresponding fees' do
      first_fee = create(:fee, subscription_id: subscription.id, invoice_id: invoice.id)
      create(:fee, subscription_id: subscription.id)
      create(:fee, invoice_id: invoice.id)

      expect(invoice_subscription.fees).to eq([first_fee])
    end
  end

  describe '#from_datetime' do
    it 'returns properties from_datetime' do
      expect(invoice_subscription.from_datetime).to match_datetime('2022-01-01 00:00:00')
    end

    context 'when properties from_datetime is empty' do
      let(:from_datetime) { nil }

      it { expect(invoice_subscription.from_datetime).to be_nil }
    end
  end

  describe '#to_datetime' do
    it 'returns properties to_datetime' do
      expect(invoice_subscription.to_datetime).to match_datetime('2022-01-31 12 23:59:59')
    end

    context 'when properties to_datetime is empty' do
      let(:to_datetime) { nil }

      it { expect(invoice_subscription.to_datetime).to be_nil }
    end
  end

  describe '#charges_from_datetime' do
    it 'returns properties charges_from_datetime' do
      expect(invoice_subscription.charges_from_datetime).to match_datetime('2022-01-01 00:00:00')
    end

    context 'when properties charges_from_datetime is empty' do
      let(:charges_from_datetime) { nil }

      it { expect(invoice_subscription.charges_from_datetime).to be_nil }
    end
  end

  describe '#charges_to_datetime' do
    it 'returns properties charges_to_datetime' do
      expect(invoice_subscription.charges_to_datetime).to match_datetime('2022-01-31 23:59:59')
    end

    context 'when properties charges_to_datetime is empty' do
      let(:charges_to_datetime) { nil }

      it { expect(invoice_subscription.charges_to_datetime).to be_nil }
    end
  end

  describe '#charge_amount_cents' do
    it 'returns the sum of the related charge fees' do
      charge = create(:standard_charge)
      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        charge: charge,
        fee_type: 'charge',
        amount_cents: 100,
      )

      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        charge: charge,
        fee_type: 'charge',
        amount_cents: 200,
      )

      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        amount_cents: 400,
      )

      expect(invoice_subscription.charge_amount_cents).to eq(300)
    end
  end

  describe '#subscription_amount_cents' do
    it 'returns the amount of the subscription fees' do
      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        amount_cents: 50,
      )

      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        charge: create(:standard_charge),
        fee_type: 'charge',
        amount_cents: 200,
      )

      expect(invoice_subscription.subscription_amount_cents).to eq(50)
    end
  end

  describe '#total_amount_cents' do
    it 'returns the sum of the related fees' do
      charge = create(:standard_charge)
      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        amount_cents: 50,
      )

      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        charge: charge,
        fee_type: 'charge',
        amount_cents: 200,
      )

      create(
        :fee,
        subscription_id: subscription.id,
        invoice_id: invoice.id,
        charge: charge,
        fee_type: 'charge',
        amount_cents: 100,
      )

      expect(invoice_subscription.total_amount_cents).to eq(350)
    end
  end

  describe '#total_amount_currency' do
    it 'returns the currency of the total amount' do
      expect(invoice_subscription.total_amount_currency).to eq(subscription.plan.amount_currency)
    end
  end

  describe '#charge_amount_currency' do
    it 'returns the currency of the charge amount' do
      expect(invoice_subscription.charge_amount_currency).to eq(subscription.plan.amount_currency)
    end
  end

  describe '#subscription_amount_currency' do
    it 'returns the currency of the subscription amount' do
      expect(invoice_subscription.subscription_amount_currency).to eq(subscription.plan.amount_currency)
    end
  end
end
