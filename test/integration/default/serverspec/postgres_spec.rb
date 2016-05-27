require "serverspec"

describe service("postgresql") do
  it { should be_enabled }
  it { should be_running }
end

describe port("5432") do
  it { should be_listening }
end

describe file("/srv/my_tablespace") do
  it { should be_directory }
  it { should be_mode 755 }
  it { should be_owned_by "postgres" }
  it { should be_grouped_into "postgres" }
end
