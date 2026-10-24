require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans stemcell' do
  include_context 'rabbitmq plans'

  %w[standalone cluster].each do |plan|
    context "the #{plan} manifest" do
      it 'keeps ubuntu-jammy as the default stemcell OS' do
        expect(render(plan, base)['stemcells']).to eq(
          [{ 'alias' => 'default', 'os' => 'ubuntu-jammy', 'version' => '0.184' }]
        )
      end

      it 'renders the stemcell OS from a property' do
        props = base.merge('service' => { 'stemcell' => '0.184', 'stemcell_os' => 'ubuntu-resolute' })
        expect(render(plan, props)['stemcells'].first['os']).to eq('ubuntu-resolute')
      end

      it 'keeps the stemcell version a string' do
        expect(render(plan, base)['stemcells'].first['version']).to be_a(String)
      end
    end
  end
end
