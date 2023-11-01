#!/usr/bin/env ruby

require 'zlib'
require 'etc'
require 'date'

@known_users = {}

def load_etc_release
  file = File.read('/etc/os-release')
  file.each_line do |line|
    line = line.chomp
    key = line.split('=')[0].to_s
    value = line.split('=')[1].to_s
    next if key.empty?

    ENV[key] = value.gsub('"', '')
  end
end

def log_dir
  if ENV['ID_LIKE'].to_s == 'fedora'
    if ENV['VERSION_ID'].to_s < '8.0'
      '/var/log/httpd24'
    else
      '/var/log/httpd'
    end
  else
    '/var/log/apache2'
  end
end

def etc_dir
  if ENV['ID_LIKE'].to_s == 'fedora'
    if ENV['VERSION_ID'].to_s < '8.0'
      '/opt/rh/httpd24/root/etc/httpd'
    else
      '/etc/httpd'
    end
  else
    '/etc/apache2'
  end
end

def all_logs
  Dir.glob("#{log_dir}/*_access*.log*").reject do |logfile|
    File.basename(logfile).to_s.start_with?('localhost')
  end
end

def user_index
  @user_index ||= begin
    log_format = `grep -rh LogFormat #{etc_dir} 2>/dev/null | grep combined | grep -v combinedio | head -n 1`.to_s
    log_format.split(' ').each_with_index.map do |token, index|
      token.to_s == '%u' ? index-1 : nil
    end.compact.first
  end
end

def oldest_log_date
  all_logs.reduce(DateTime.now) do |oldest, log|
    basename = File.basename(log)
    date = basename[/.*.log-(\d+).*$/, 1] # -- 20231011
    next(oldest) if date.nil?

    logdate = DateTime.strptime(date, '%Y%m%d')

    if logdate < oldest
      logdate
    else
      oldest
    end
  end.strftime('%m-%d-%Y')
end

# 123.456.789.123 cool.host.edu - johrstrom 443
# ip                servername  -  user      ?
def parse_line(line)
  tokens = line.split(' ')
  username = tokens[user_index]
  @known_users[username] = 'found' if real_user?(username)
end

def real_user?(username)
  return false if ['-', '""'].include?(username)

  begin
    Etc.getpwnam(username)
    true
  rescue ArgumentError
    false
  end
end

def parse_logs
  all_logs.each do |logfile|
    if logfile.end_with?('gz')
      Zlib::GzipReader.new(File.open(logfile)).each_line do |line|
        parse_line(line)
      end
    else
      File.read(logfile).each_line do |line|
        parse_line(line)
      end
    end
  end
end

load_etc_release
parse_logs

puts "#{@known_users.size} users have logged into this system since #{oldest_log_date}"
