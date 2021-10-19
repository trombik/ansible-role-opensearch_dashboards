require "spec_helper"
require "serverspec"

package = "opensearch_dashboards"
service = "opensearch_dashboards"
config  = "/etc/opensearch_dashboards/opensearch_dashboards.conf"
user    = "opensearch_dashboards"
group   = "opensearch_dashboards"
ports   = [PORTS]
log_dir = "/var/log/opensearch_dashboards"
db_dir  = "/var/lib/opensearch_dashboards"

case os[:family]
when "freebsd"
  config = "/usr/local/etc/opensearch_dashboards.conf"
  db_dir = "/var/db/opensearch_dashboards"
end

describe package(package) do
  it { should be_installed }
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("opensearch_dashboards") }
end

describe file(log_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

describe file(db_dir) do
  it { should exist }
  it { should be_mode 755 }
  it { should be_owned_by user }
  it { should be_grouped_into group }
end

case os[:family]
when "freebsd"
  describe file("/etc/rc.conf.d/opensearch_dashboards") do
    it { should be_file }
  end
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
