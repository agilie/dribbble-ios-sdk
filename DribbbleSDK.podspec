#
# Be sure to run `pod lib lint AGLocationDispatcher.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = "DribbbleSDK"
    s.version          = "0.0.3"
    s.platform         = :ios, '7.0'
    s.summary          = "Unofficial Dribbble iOS SDK"
    s.description      = <<-DESC
Uses latest Dribbble HTTP API !

    * Markdown format.
    * Don't worry about the indent, we strip it!
    DESC
    s.homepage         = "https://github.com/agilie/dribbble-ios-sdk"
    # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.authors           = { 'Agilie' => 'info@agilie.com' }
    s.source           = { :git => "https://github.com/agilie/dribbble-ios-sdk.git",
                            :tag => s.version.to_s,
                            :branch => "master"
                        }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.requires_arc = true

    s.source_files = 'DribbbleSDK/**/*.{c,h,m}'
    # s.resource_bundles = {
    #                     'AGLocationDispatcher' => ['Pod/Assets/*.png']
    #                     }

    s.public_header_files = 'DribbbleSDK/**/*.h'
#s.source_files = 'Pod/Classes/*.h'
    s.frameworks = 'Foundation'
    s.dependency 'AFNetworking', '~> 2.3'
    s.dependency 'BlocksKit'
    s.dependency 'NXOAuth2Client'
    s.dependency 'JSONModel'
end
