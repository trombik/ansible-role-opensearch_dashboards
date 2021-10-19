require "spec_helper"
require "serverspec"

package = "opensearch-dashboards"
service = "opensearch-dashboards"
config  = "/etc/opensearch_dashboards/opensearch_dashboards.conf"
user    = "www"
group   = "www"
ports   = [5601]
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc/opensearch-dashboards"
             else
               "/etc/opensearch-dashboards"
             end

config = "#{config_dir}/opensearch_dashboards.yml"

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
