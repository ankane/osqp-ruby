# stdlib
require "fiddle/import"

# modules
require_relative "osqp/matrix"
require_relative "osqp/solver"
require_relative "osqp/version"

module OSQP
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  lib_path =
    if Gem.win_platform?
      "x64-mingw/osqp.dll"
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "arm64-darwin/libosqp.dylib"
      else
        "x86_64-darwin/libosqp.dylib"
      end
    else
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "aarch64-linux/libosqp.so"
      else
        "x86_64-linux/libosqp.so"
      end
    end
  vendor_lib = File.expand_path("../vendor/#{lib_path}", __dir__)
  self.ffi_lib = [vendor_lib]

  # friendlier error message
  autoload :FFI, "osqp/ffi"

  def self.lib_version
    FFI.osqp_version.to_s
  end
end
