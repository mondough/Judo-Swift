#
# Be sure to run `pod lib lint Judo-swift.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Judo'
  s.version          = '1.1.0'
  s.summary          = 'Judo Pay iOS Client SDK'
  s.homepage         = 'http://judopay.com/'
  s.license          = 'MIT'
  s.author           = { "Hamon Ben Riazy" => 'hamon.riazy@judopayments.com' }
  s.source           = { :git => 'https://github.com/JudoPay/Judo-Swift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.ios.platform          = '9.0'

  s.requires_arc     = true

  s.source_files     = 'Source/**/*.swift'

end
