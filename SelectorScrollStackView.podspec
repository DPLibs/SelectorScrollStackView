Pod::Spec.new do |s|
  s.name             = 'SelectorScrollStackView'
  s.version          = '1.0.0'
  s.summary          = 'Selector Scroll Stack View'
  s.description      = 'A simple utility'
  s.homepage         = 'https://github.com/DPLibs/SelectorScrollStackView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dmitriy Polyakov' => 'dmitriyap11@gmail.com' }
  s.source           = { :git => 'https://github.com/DPLibs/SelectorScrollStackView.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'SelectorScrollStackView/**/*'
  s.swift_version = '5.0'
  
  s.dependency 'ScrollStackView'
end
