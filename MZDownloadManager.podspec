#
# Be sure to run `pod lib lint MZDownloadManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "MZDownloadManager"
  s.version          = "0.1.0"
  s.summary          = "NSURLSession based download manager."

  s.description      = "Download large files even in background, download multiple files, resume interrupted downloads."


  s.homepage         = "https://github.com/mzeeshanid/MZDownloadManager"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'BSD'
  s.author           = { "Muhammad Zeeshan" => "mzeeshanid@yahoo.com" }
  s.source           = { :git => "https://github.com/mzeeshanid/MZDownloadManager.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/mzeeshanid'

  s.ios.deployment_target = '8.0'

  s.source_files = 'MZDownloadManager/Classes/**/*'
  s.resource_bundles = {
    'MZDownloadManager' => ['MZDownloadManager/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.{swift}'
  s.frameworks = 'Foundation'
end
