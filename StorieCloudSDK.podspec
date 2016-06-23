Pod::Spec.new do |spec|
spec.name = "StorieCloudSDK"
spec.version = "0.0.9"
spec.summary = "Storie Cloud SDK"
spec.homepage = "https://api.storie.com"
spec.license      = { :type => 'Commercial', :text => 'Please refer to https://github.com/Storie/StorieCloudSDK/blob/master/LICENSE'}
spec.author       = { 'Storie, Inc' => 'support@storie.com' }
spec.social_media_url = "http://twitter.com/storie"

spec.platform = :ios, "8"
spec.requires_arc = true
spec.source = { git: "https://github.com/Storie/StorieCloudSDK.git", tag: "v#{spec.version}", submodules: true }
spec.source_files = "StorieCloudSDK/**/*.{h,m,swift}", "distribute.framework/Headers/*.h"

spec.ios.vendored_frameworks = "distribute.framework"
spec.public_header_files = "distribute.framework/Headers/*.h"

spec.dependency "Alamofire", "~> 3.3"
spec.dependency "SwiftyJSON", "~> 2.3"
spec.dependency "RxSwift", "~> 2.0"
spec.dependency "RxCocoa", "~> 2.0"
spec.dependency "Moya/RxSwift", "~> 6.4"
spec.dependency "SwiftyBeaver", "~> 0.5"
spec.dependency "FileMD5Hash", "~> 2.0"

end
