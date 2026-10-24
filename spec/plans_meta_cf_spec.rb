require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans meta.cf' do
  include_context 'rabbitmq plans'

  def props_for(routing, autoscale)
    base.merge('rabbitmq' => {
      'route_registrar' => { 'enabled' => routing },
      'autoscale' => { 'enabled' => autoscale }
    })
  end

  %w[standalone cluster].each do |plan|
    context "the #{plan} plan" do
      [[true, false], [false, true], [true, true]].each do |routing, autoscale|
        it "renders meta.cf.deployment_name with routing #{routing} and autoscale #{autoscale}" do
          manifest = render(plan, props_for(routing, autoscale))
          expect(manifest['meta']['cf']['deployment_name']).to eq('cf')
        end
      end

      it 'keeps every autoscale cf value in a single meta.cf block' do
        text = job.template("plans/#{plan}/manifest.yml").render(props_for(true, true))
        meta_text = text[/^meta:\n.*?(?=^\S)/m]
        expect(meta_text.scan(/^  cf:$/).size).to eq(1)
        expect(render(plan, props_for(true, true))['meta']['cf']).to eq(
          'exodus_path' => 'secret/exodus/lab/cf',
          'deployment_name' => 'cf',
          'system_domain' => 'sys.example.com',
          'api_url' => 'https://api.sys.example.com',
          'username' => 'admin',
          'password' => 'secret'
        )
      end

      it 'renders only deployment_name and system_domain with routing on and autoscale off' do
        expect(render(plan, props_for(true, false))['meta']['cf']).to eq(
          'deployment_name' => 'cf',
          'system_domain' => 'sys.example.com'
        )
      end

      it 'renders neither the addon nor meta.cf with both off' do
        manifest = render(plan, props_for(false, false))
        expect(manifest['meta']).not_to have_key('cf')
        expect(manifest).not_to have_key('addons')
      end
    end
  end
end
