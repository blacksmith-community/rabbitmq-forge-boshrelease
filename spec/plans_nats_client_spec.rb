require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans NATS client certificate' do
  include_context 'rabbitmq plans'

  def props_for(routing, cert: true)
    cf = base['cf'].dup
    cf.delete('nats_client_cert') unless cert
    cf.delete('nats_client_key') unless cert
    base.merge(
      'cf' => cf,
      'rabbitmq' => { 'route_registrar' => { 'enabled' => routing }, 'autoscale' => { 'enabled' => false } }
    )
  end

  def registrar(manifest)
    manifest['instance_groups'].first['jobs'].find { |j| j['name'] == 'route_registrar' }
  end

  %w[standalone cluster].each do |plan|
    context "the #{plan} plan" do
      it 'registers routes with the supplied client certificate when routing is on' do
        job_def = registrar(render(plan, props_for(true)))
        expect(job_def['properties']['nats']['tls']).to include(
          'enabled' => true,
          'client_cert' => base['cf']['nats_client_cert'],
          'client_key' => base['cf']['nats_client_key']
        )
      end

      it 'skips route registration when routing is on but no client certificate is supplied' do
        manifest = render(plan, props_for(true, cert: false))
        expect(registrar(manifest)).to be_nil
        expect(release_entry(manifest, 'routing')).to be_nil
      end

      it 'skips route registration when routing is off' do
        expect(registrar(render(plan, props_for(false)))).to be_nil
      end

      [[true, true], [true, false], [false, true]].each do |routing, cert|
        it "references no CredHub path the forge does not control with routing #{routing} and cert #{cert}" do
          text = job.template("plans/#{plan}/manifest.yml").render(props_for(routing, cert: cert))
          expect(text).not_to match(%r{\(\(/})
          expect(text).not_to include('nats_client_cert.')
        end
      end
    end
  end
end
