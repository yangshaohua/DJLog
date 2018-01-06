
Pod::Spec.new do |s|
  s.name             = 'DJLog'
  s.version          = '0.0.1'
  s.summary          = '速运日志组件'

  s.description      = <<-DESC
                    速运日志组件1
                       DESC

  s.homepage         = 'https://www.daojia.com'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yangshaohua' => 'yangshaohua@daojia.com' }
  s.source           = { :git => 'https://github.com/yangshaohua/DJLog.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'DJLog/Classes/**/*'

   s.public_header_files = 'DJLog/Classes/**/*.h'
   s.frameworks = 'UIKit'
   s.dependency 'SSZipArchive', '~> 1.8.1'
end
