require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

shared_libraries = %w(libosqp.so libosqp.dylib libosqp.arm64.dylib libosqp.dll)

# ensure vendor files exist
task :ensure_vendor do
  shared_libraries.each do |file|
    raise "Missing file: #{file}" unless File.exist?("vendor/#{file}")
  end
end

Rake::Task["build"].enhance [:ensure_vendor]

def version
  "0.6.2"
end

def download_official(library, file)
  require "fileutils"
  require "open-uri"
  require "tmpdir"

  raise "No longer available"

  url = "https://bintray.com/bstellato/generic/download_file?file_path=OSQP%2F#{version}%2F#{file}"
  puts "Downloading #{file}..."
  dir = Dir.mktmpdir
  Dir.chdir(dir) do
    File.binwrite(file, URI.open(url).read)
    command = "tar xf"
    system "#{command} #{file}"
    path = "#{dir}/#{file[0..-8]}/lib/#{library}"
    FileUtils.cp(path, File.expand_path("vendor/#{library}", __dir__))
    puts "Saved vendor/#{library}"
  end
end

def download_file(file)
  require "open-uri"

  url = "https://github.com/ankane/ml-builds/releases/download/osqp-#{version}/#{file}"
  puts "Downloading #{file}..."
  dest = "vendor/#{file}"
  File.binwrite(dest, URI.open(url).read)
  puts "Saved #{dest}"
end

# https://bintray.com/bstellato/generic/OSQP
namespace :vendor do
  task :linux do
    download_official("libosqp.so", "osqp-#{version}-linux64.tar.gz")
  end

  task :mac do
    download_official("libosqp.dylib", "osqp-#{version}-mac64.tar.gz")
    download_file("libosqp.arm64.dylib")
  end

  task :windows do
    download_official("libosqp.dll", "osqp-#{version}-windows64.tar.gz")
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
