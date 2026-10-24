require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans meta.cf' do
  include_context 'rabbitmq plans'

  [true, false].product([true, false]).each do |routing, autoscale|
    %w[standalone cluster].each do |plan|
      context "the #{plan} plan with routing #{routing} and autoscale #{autoscale}" do
        let(:props) do
          base.merge('rabbitmq' => {
            'route_registrar' => { 'enabled' => routing },
            'autoscale' => { 'enabled' => autoscale }
          })
        end

        it 'provides every meta.cf value the manifest grabs' do
          manifest = job.template("plans/#{plan}/manifest.yml").render(props)
          meta = YAML.safe_load(job.template('plans/meta.yml').render(props))['meta']
          grabbed = manifest.scan(/grab meta\.cf\.(\w+)/).flatten.uniq
          expect(grabbed - (meta['cf'] || {}).keys).to be_empty
        end
      end
    end
  end
end
