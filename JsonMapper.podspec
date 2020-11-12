Pod::Spec.new do |s|
	s.name     = 'TKJsonMapper'
	s.version  = '1.2.0'

	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'JSONMapper/JSONElement makes it easier and safer to use JSON'
	s.homepage = 'https://github.com/TBXark/JsonMapper'
	s.author   = { 'TBXark' => 'tbxark@outlook.com' }
	s.source   = { :git => 'https://github.com/TBXark/JsonMapper.git', :tag => "#{s.version}" }
	s.module_name = 'JSONMapper'

	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = '3.0'

	s.source_files = 'Sources/JsonMapper/*.swift'
	s.framework = 'Foundation'
end
