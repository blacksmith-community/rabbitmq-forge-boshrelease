require_relative 'support_plans'

describe 'rabbitmq-blacksmith-plans bpm colocation' do
  include_context 'rabbitmq plans'

  [true, false].product([true, false]).each do |routing, autoscale|
    %w[standalone cluster].each do |plan|
      context "the #{plan} manifest with routing #{routing} and autoscale #{autoscale}" do
        let(:props) do
          base.merge('rabbitmq' => {
            'route_registrar' => { 'enabled' => routing },
            'autoscale' => { 'enabled' => autoscale }
          })
        end

        it 'colocates the bpm job exactly once' do
          jobs = render(plan, props)['instance_groups'].first['jobs']
          expect(jobs.count { |j| j['name'] == 'bpm' }).to eq(1)
        end

        it 'includes the bpm release exactly once' do
          releases = render(plan, props)['releases']
          expect(releases.count { |r| r['name'] == 'bpm' }).to eq(1)
        end
      end
    end
  end
end
