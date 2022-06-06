require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

directories = %w(x86_64-linux aarch64-linux x86_64-darwin aarch64-darwin x86_64-windows)

# ensure vendor files exist
task :ensure_vendor do
  directories.each do |dir|
    raise "Missing directory: #{dir}" unless Dir.exist?("vendor/#{dir}")
  end
end

Rake::Task["build"].enhance [:ensure_vendor]

def download_file(target, sha256)
  version = "0.6.2"

  require "fileutils"
  require "open-uri"
  require "tmpdir"

  file = "osqp-#{version}-#{target}.zip"
  url = "https://github.com/ankane/ml-builds/releases/download/osqp-#{version}-1/#{file}"
  puts "Downloading #{file}..."
  contents = URI.open(url).read

  computed_sha256 = Digest::SHA256.hexdigest(contents)
  raise "Bad hash: #{computed_sha256}" if computed_sha256 != sha256

  vendor = File.expand_path("vendor", __dir__)
  FileUtils.mkdir_p(vendor)

  Dir.chdir(Dir.mktmpdir) do
    File.binwrite(file, contents)
    dest = File.join(vendor, target)
    FileUtils.rm_r(dest) if Dir.exist?(dest)
    # run apt install unzip on Linux
    system "unzip", "-q", file, "-d", dest, exception: true
  end
end

namespace :vendor do
  task :linux do
    download_file("x86_64-linux", "330639ffb8082020819a43c5a196c28eb85c209ff518e198fe716bae6a8a1e1d")
    download_file("aarch64-linux", "8ef1ce28264eca91c14c9c9f2ce92b970f6a50db7db1665d185c7c740b4ce88b")
  end

  task :mac do
    download_file("x86_64-darwin", "58d03466345c3c1f0e79968fb1fa42b6ccfb28d40625c4310cb8b57432a2a98c")
    download_file("aarch64-darwin", "2c95b23e7842c82a6a883c2a38c5a89301f33a96f34f4adf35f41021343e8abe")
  end

  task :windows do
    download_file("x86_64-windows", "52be51b3921a7cd480d1466956f4649ec88750d0882d2245f8f01e56e986b345")
  end

  task all: [:linux, :mac, :windows]

  task :platform do
    if Gem.win_platform?
      Rake::Task["vendor:windows"].invoke
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      Rake::Task["vendor:mac"].invoke
    else
      Rake::Task["vendor:linux"].invoke
    end
  end
end
