require 'rspec'
require 'bosh/template/test'

describe 'rabbitmq job bin/pre-start' do
  let(:release) { Bosh::Template::Test::ReleaseDir.new(File.join(File.dirname(__FILE__), '..')) }
  let(:job) { release.job('rabbitmq') }
  let(:script) do
    job.template('bin/pre-start').render({
      'erlang' => { 'cookie' => 'test-cookie' },
      'rabbitmq' => { 'plan' => 'standalone' }
    })
  end
  let(:code) { script.lines.reject { |l| l.strip.start_with?('#') } }
  let(:loop_line) { code.grep(/^\s*for dir in /).join }

  it 'never changes ownership or mode of the job directory' do
    offenders = code.select do |line|
      line =~ /\b(chown|chmod)\b/ && line =~ %r{\$\{?JOB_DIR\b|/var/vcap/jobs/rabbitmq\b}
    end
    expect(offenders).to be_empty
    expect(loop_line).not_to match(/JOB_DIR|\/var\/vcap\/jobs\/rabbitmq/)
  end

  it 'still prepares the run, log, tmp, and store directories' do
    expect(loop_line).not_to be_empty
    %w[RUN_DIR LOG_DIR TMP_DIR STORE_DIR].each do |var|
      expect(loop_line).to include("$#{var}")
    end
  end
end
