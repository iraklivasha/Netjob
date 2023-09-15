Pod::Spec.new do |s|

  s.name         = "Netjob"
  s.version      = "1.0.0"
  s.summary      = "Networking SDK"
  s.homepage     = "Development only yet"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = "MRSOOL"
  s.platform     = :ios, "10.0"
  s.source_files  = 'Netjob/**/*.{swift}'
  s.module_name   = 'Netjob'
  s.source = { :path => '.' }
  s.swift_version = '5.0'
end