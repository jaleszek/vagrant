require "fileutils"
require 'optparse'

module VagrantPlugins
  module CommandBox
    module Command
      class Repackage < Vagrant.plugin("1", :command)
        def execute
          options = {}

          opts = OptionParser.new do |opts|
            opts.banner = "Usage: vagrant box repackage <name> <provider>"
          end

          # Parse the options
          argv = parse_options(opts)
          return if !argv
          raise Vagrant::Errors::CLIInvalidUsage, :help => opts.help.chomp if argv.length < 2

          box_name     = argv[0]
          box_provider = argv[1].to_sym

          # Verify the box exists that we want to repackage
          box = nil
          begin
            box = @env.boxes.find(box_name, box_provider)
          rescue Vagrant::Errors::BoxUpgradeRequired
            @env.boxes.upgrade(box_name)
            retry
          end

          raise Vagrant::Errors::BoxNotFound, :name => box_name if !box

          # Repackage the box
          output_path = File.expand_path(@env.config.global.package.name, FileUtils.pwd)
          box.repackage(output_path)

          # Success, exit status 0
          0
        end
      end
    end
  end
end
