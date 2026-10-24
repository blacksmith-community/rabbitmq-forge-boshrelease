require 'rspec'
require 'yaml'
require 'bosh/template/test'

RSpec.shared_context 'rabbitmq plans' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('rabbitmq-blacksmith-plans') }
  let(:base) do
    {
      'environment' => 'lab',
      'bosh_env' => 'lab',
      'service' => { 'stemcell' => '0.184' },
      'cf' => {
        'exodus_path' => 'secret/exodus/lab/cf',
        'deployment_name' => 'cf',
        'system_domain' => 'sys.example.com',
        'api_url' => 'https://api.sys.example.com',
        'username' => 'admin',
        'password' => 'secret',
        'core_network' => 'core',
        'nats_client_cert' => "-----BEGIN CERTIFICATE-----\nabc\n-----END CERTIFICATE-----",
        'nats_client_key' => "-----BEGIN RSA PRIVATE KEY-----\ndef\n-----END RSA PRIVATE KEY-----"
      },
      'bosh' => { 'deployment_name' => 'lab' },
      'rabbitmq_metrics_emitter' => { 'cloud_foundry' => { 'api' => 'https://api.sys.example.com', 'username' => 'admin', 'password' => 'secret' } },
      'rabbitmq' => {
        'route_registrar' => { 'enabled' => true },
        'autoscale' => { 'enabled' => true }
      }
    }
  end

  def render(plan, props)
    YAML.safe_load(job.template("plans/#{plan}/manifest.yml").render(props), aliases: true)
  end

  def release_entry(manifest, name)
    manifest['releases'].find { |r| r['name'] == name }
  end
end
