#
# Be sure to run `pod lib lint AutoCompleteTextField.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AutoCompleteTextField"
  s.version          = "0.1.0"
  s.summary          = "A TextField Subclass that has auto completion feature from suggestion filtered from the data source provided by the user."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                       DESC

  s.homepage         = "https://github.com/<GITHUB_USERNAME>/AutoCompleteTextField"
  # s.screenshots     = "http://imgur.com/Hm0jK9C", "http://imgur.com/Rq1mOZ5"
  s.license          = 'MIT'
  s.author           = { "Neil Francis Ramirez Hipona" => "nferocious76@gmail.com" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/AutoCompleteTextField.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/nferocious76'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AutoCompleteTextField' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
