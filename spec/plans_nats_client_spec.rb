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

      it 'registers routes with the CredHub client certificate when routing is on and no certificate is supplied' do
        manifest = render(plan, props_for(true, cert: false))
        expect(release_entry(manifest, 'routing')).not_to be_nil
        expect(registrar(manifest)['properties']['nats']['tls']).to eq(
          'enabled' => true,
          'client_cert' => '((/lab-bosh/cf/nats_client_cert.certificate))',
          'client_key' => '((/lab-bosh/cf/nats_client_cert.private_key))'
        )
      end

      it 'emits meta.cf when routing is on and no certificate is supplied' do
        expect(render(plan, props_for(true, cert: false))['meta']['cf']['deployment_name']).to eq('cf')
      end

      it 'skips route registration and the routing release when routing is off' do
        manifest = render(plan, props_for(false))
        expect(registrar(manifest)).to be_nil
        expect(release_entry(manifest, 'routing')).to be_nil
      end

      it 'references no CredHub path when a certificate is supplied or routing is off' do
        [[true, true], [false, true], [false, false]].each do |routing, cert|
          text = job.template("plans/#{plan}/manifest.yml").render(props_for(routing, cert: cert))
          expect(text).not_to match(%r{\(\(/})
          expect(text).not_to include('nats_client_cert.')
        end
      end
    end
  end
end
