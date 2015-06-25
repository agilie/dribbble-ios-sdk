source 'https://github.com/CocoaPods/Specs'

workspace 'DribbbleSDK'

inhibit_all_warnings!

def do_import
    pod 'DribbbleSDK', path => './'
    platform :ios, '7.0'
end

target :DribbbleSDKExample do
    xcodeproj 'DribbbleSDKExample/DribbbleSDKExample'
    do_import
end

target :'DribbbleSDK Tests' do
    xcodeproj 'DribbbleSDK Tests/DribbbleSDK Tests'
    do_import
end