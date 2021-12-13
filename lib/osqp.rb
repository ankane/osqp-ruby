# stdlib
require "fiddle/import"

# modules
require "osqp/solver"
require "osqp/version"

module OSQP
  class Error < StandardError; end

  class << self
    attr_accessor :ffi_lib
  end
  lib_name =
    if Gem.win_platform?
      "libosqp.dll"
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      if RbConfig::CONFIG["host_cpu"] =~ /arm|aarch64/i
        "libosqp.arm64.dylib"
      else
        "libosqp.dylib"
      end
    else
      "libosqp.so"
    end
  vendor_lib = File.expand_path("../vendor/#{lib_name}", __dir__)
  self.ffi_lib = [vendor_lib]

  # friendlier error message
  autoload :FFI, "osqp/ffi"

  def self.lib_version
    FFI.osqp_version.to_s
  end
end
