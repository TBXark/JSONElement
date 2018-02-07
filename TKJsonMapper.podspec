Pod::Spec.new do |s|
	s.name     = 'TKJsonMapper'
	s.version  = '0.1.2'

	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'JsonMapper is a simple, fast and secure way to access Json Edit'
	s.homepage = 'https://github.com/TBXark/JsonMapper'
	s.author   = { 'TBXark' => 'tbxark@outlook.com' }
	s.source   = { :git => 'https://github.com/TBXark/JsonMapper.git', :tag => "#{s.version}" }
	s.module_name = 'JsonMapper'

	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = '3.0'

	s.source_files = 'JsonMapper/*.swift'
	s.framework = 'Foundation'
end
