
Pod::Spec.new do |s|
  s.name             = 'StepProcessing'
  s.version          = '0.1.0'
  s.summary          = 'A short description of StepProcesser.'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/iaovchinnikov/stepprocesser'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Igor' => 'igorexguitar@yandex.ru' }
  s.source           = { :git => 'https://github.com/iaovchinnikov/stepprocesser.git' }

  s.ios.deployment_target = '8.0'

  s.source_files = 'StepProcesser/Classes/**/*'
  
  # s.resource_bundles = {
  #   'StepProcesser' => ['StepProcesser/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
