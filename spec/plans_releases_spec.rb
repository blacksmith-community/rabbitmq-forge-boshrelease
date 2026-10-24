require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans releases' do
  include_context 'rabbitmq plans'

  %w[standalone cluster].each do |plan|
    context "the #{plan} manifest" do
      it 'defaults to bpm 1.4.41' do
        expect(release_entry(render(plan, base), 'bpm')).to eq(
          'name' => 'bpm',
          'version' => '1.4.41',
          'url' => 'https://bosh.io/d/github.com/cloudfoundry/bpm-release?v=1.4.41',
          'sha1' => 'sha256:7b445508d63d2171d892ba33f836087e1e519b9782f44c5fa5290323616ca8e6'
        )
      end

      it 'keeps the routing and bosh-dns-aliases defaults' do
        m = render(plan, base)
        expect(release_entry(m, 'routing')).to eq(
          'name' => 'routing',
          'version' => '0.338.0',
          'url' => 'https://bosh.io/d/github.com/cloudfoundry/routing-release?v=0.338.0',
          'sha1' => '69690159842feda278a45ca17484ea055432086d'
        )
        expect(release_entry(m, 'bosh-dns-aliases')).to eq(
          'name' => 'bosh-dns-aliases',
          'version' => '0.0.4',
          'url' => 'https://bosh.io/d/github.com/cloudfoundry/bosh-dns-aliases-release?v=0.0.4',
          'sha1' => '55b3dced813ff9ed92a05cda02156e4b5604b273'
        )
      end

      it 'renders each release from its properties' do
        props = base.merge(
          'bpm_release' => { 'version' => '1.4.20', 'url' => 'https://example.com/bpm.tgz', 'sha1' => 'sha1-bpm' },
          'routing_release' => { 'version' => '0.400.0', 'url' => 'https://example.com/routing.tgz', 'sha1' => 'sha1-routing' },
          'bosh_dns_aliases_release' => { 'version' => '0.0.5', 'url' => 'https://example.com/dns.tgz', 'sha1' => 'sha1-dns' }
        )
        m = render(plan, props)
        expect(release_entry(m, 'bpm')).to include('version' => '1.4.20', 'url' => 'https://example.com/bpm.tgz', 'sha1' => 'sha1-bpm')
        expect(release_entry(m, 'routing')).to include('version' => '0.400.0', 'url' => 'https://example.com/routing.tgz', 'sha1' => 'sha1-routing')
        expect(release_entry(m, 'bosh-dns-aliases')).to include('version' => '0.0.5', 'url' => 'https://example.com/dns.tgz', 'sha1' => 'sha1-dns')
      end
    end
  end
end
