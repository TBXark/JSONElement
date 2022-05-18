Pod::Spec.new do |s|
	s.name     = 'JSONElement'
	s.version  = '1.5.0'

	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'JSONElement/JSONMapper makes it easier and safer to use JSON'
	s.homepage = 'https://github.com/TBXark/JSONElement'
	s.author   = { 'TBXark' => 'tbxark@outlook.com' }
	s.source   = { :git => 'https://github.com/TBXark/JSONElement.git', :tag => "#{s.version}" }
	s.module_name = 'JSONElement'

	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'

	s.source_files = 'Sources/JSONElement/*.swift'
	s.framework = 'Foundation'
	s.swift_version = '4.0'
end
