require "spec_helper"
require "serverspec"

package = "opensearch-dashboards"
service = "opensearch-dashboards"
ports   = [5601]
config_dir = case os[:family]
             when "freebsd"
               "/usr/local/etc/opensearch-dashboards"
             else
               "/etc/opensearch-dashboards"
             end
config = "#{config_dir}/opensearch_dashboards.yml"
install_method = case os[:family]
                 when "ubuntu"
                   "src"
                 else
                   "default"
                 end
data_dir = case os[:family]
           when "freebsd"
             "/var/db/openseach-dashboards"
           else
             "/var/lib/opensearch-dashboards"
           end
default_user = "root"
default_group = case os[:family]
                when /bsd/
                  "wheel"
                else
                  "root"
                end
user = case os[:family]
       when "freebsd"
         "www"
       else
         "www-data"
       end

group = case os[:family]
        when "freebsd"
          "www"
        else
          "www-data"
        end
log_dir = case os[:family]
          when "freebsd"
            "/var/log"
          else
            "/var/log/opensearch-dashboards"
          end
src_dir = "/var/dist"
src_dist_name = "opensearch-dashboards-1.1.0"
src_root_dir = "/var/www/opensearch-dashboards"
bin_dir = case os[:family]
          when "freebsd"
            "/usr/local/www/opensearch-dashboards/bin"
          when "ubuntu"
            "#{src_root_dir}/bin"
          end

case install_method
when "src"
  describe file src_dir do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
  end

  describe file src_root_dir do
    it { should exist }
    it { should be_directory }
    it { should be_mode 755 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
  end

  describe file "#{bin_dir}/opensearch-dashboards" do
    it { should exist }
    it { should be_file }
    it { should be_mode 775 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
  end

  %w[sig_verified key_verified key_imported src_extracted].each do |f|
    describe file "#{src_dir}/.#{f}-#{src_dist_name}" do
      it { should exist }
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by default_user }
      it { should be_grouped_into default_group }
    end
  end

  describe file "/etc/systemd/system/opensearch-dashboards.service" do
    it { should exist }
    it { should be_symlink }
  end

  describe file "/lib/systemd/system/opensearch-dashboards.service" do
    it { should exist }
    it { should be_file }
    it { should be_mode 644 }
    it { should be_owned_by default_user }
    it { should be_grouped_into default_group }
    its(:content) { should match(/Managed by ansible/) }
  end

  describe file "/home/vagrant/.gnupg" do
    it { should_not exist }
  end

  describe file "/root/.gnupg" do
    it { should exist }
    it { should be_directory }
  end
else
  describe package(package) do
    it { should be_installed }
  end
end

describe file(config) do
  it { should be_file }
  its(:content) { should match Regexp.escape("Managed by ansible") }
end

describe file data_dir do
  it { should exist }
  it { should be_directory }
  it { should be_owned_by user }
  it { should be_grouped_into group }
  it { should be_mode 755 }
end

describe file log_dir do
  it { should exist }
  it { should be_directory }
  if os[:family] != "freebsd"
    it { should exist }
    it { should be_directory }
    it { should be_owned_by user }
    it { should be_grouped_into group }
    it { should be_mode 755 }
  end
end

describe service(service) do
  it { should be_running }
  it { should be_enabled }
end

describe command "#{bin_dir}/opensearch-dashboards-plugin list" do
  let(:sudo_options) { "-u #{user} " }
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq "" }
  its(:stdout) { should match(/securityDashboards/) }
end

ports.each do |p|
  describe port(p) do
    it { should be_listening }
  end
end
