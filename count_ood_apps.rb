#!/usr/bin/env ruby

require 'pathname'
require 'etc'

def basedir
  '/var/www/ood/apps'
end

def username
  Etc.getlogin
end

def version
  File.read('/opt/ood/VERSION').chomp
end

def run
  no_sys, all_sys_apps = sys_apps
  no_usr, _all_usr_apps = usr_apps

  puts "The user #{username} has access to these Open OnDemand #{version} apps:"
  puts "  #{no_sys} system installed applications."
  puts "  #{no_usr} shared applications."
  puts ''
  puts 'system installed apps are:'
  puts ''
  all_sys_apps.each { |app| puts app }
end

def usr_apps
  Dir.children("#{basedir}/usr").reduce(0) do |sum, dir|
    full_dir = Pathname.new("#{basedir}/usr/#{dir}/gateway/")

    if full_dir.readable?
      sum + full_dir.children.select { |p| Pathname.new(p).readable? }.size
    else
      sum
    end
  end
end

def sys_apps
  app_hash = Dir.children("#{basedir}/sys").map do |dir|
    full_dir = Pathname.new("#{basedir}/sys/#{dir}")

    [dir, true] if full_dir.readable?
  end.compact.to_h

  [app_hash.size, app_hash.keys]
end

run
