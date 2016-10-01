#!/usr/bin/ruby
# puppetlabs/centos-6.6-64-nocm
# puppetlabs/ubuntu-12.04-64-nocm


def return_url(arg)
  if arg.empty? 
    puts "USAGE:   #{$0} vagrantbox"
    puts "EXAMPLE: #{$0} puppetlabs/centos-6.6-64-nocm"
    exit 1
  end

  full = arg.downcase.chomp

  unless full.match(/^puppetlabs/i)
      puts "Not using a puppetlabs vagrant box, please set variable arch in Vagrantfile"
      exit 1
  end

  values = full.split('/')
  box = values[1]

  data = box.split('-')

  os = data[0]
  vers = data[1]
  arch = data[2]

  unless arch == "64"
    puts "Puppet Master only support 64-bit architecture. Please use another box"
    exit 1
  end

  # https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=latest
  # https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=ubuntu&rel=16.04&arch=amd64&ver=latest
  # https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=sles&rel=12&arch=x86_64&ver=latest

  case os 
  when "centos"
    $dist = "el"
  when "ubuntu"
    $dist = "ubuntu"
  when "sles"
    $dist = "sles"
  else
    puts "OS not supported as Puppet Master. Please use another box"
    exit 1
  end

  if os == "ubuntu"
    $rel = vers
    $arch = "amd64"
  elsif os == "centos" 
    realvers = vers.split(".")
    versmaj = realvers[0]
    versmin = realvers[1]
    $rel = versmaj
    $arch = "x86_64"
  elsif os == "sles"
    $rel = vers
    $arch = "x86_64"
  else
    puts "OS not supported as Puppet Master. Please use another box"
    exit 1
  end

  return "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=#{$dist}&rel=#{$rel}&arch=#{$arch}&ver="
  exit 0

end
