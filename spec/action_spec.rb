require 'spec_helper'

RSpec.describe Julia::Action do
  let(:record) do
    OpenStruct.new({
      name:      'steven',
      last_name: 'barragan',
      dob:       Date.new(1990, 11, 19)
    })
  end

  describe '#get_value' do
    context 'given a key' do
      let(:subject){ described_class.new(:name) }

      it 'returns key\'s value' do
        expect(subject.get_value(record)).to eq 'steven'
      end
    end

    context 'given a action\'s and value' do
      let(:subject){ described_class.new('Last name', :last_name) }

      it 'returns action\'s value' do
        expect(subject.get_value(record)).to eq 'barragan'
      end
    end

    context 'given a block' do
      let(:subject) do
        described_class.new(:name) do |user|
          user.last_name
        end
      end

      it 'returns block\'s value' do
        expect(subject.get_value(record)).to eq 'barragan'
      end
    end

    context 'given a lambda' do
      let(:subject) { described_class.new('full name', -> { "#{name} #{last_name}" }) }

      it 'returns lambda\'s value' do
        expect(subject.get_value(record)).to eq 'steven barragan'
      end
    end
  end
end
