Pod::Spec.new do |s|
  s.name         = "SFHDebugToolKit"
  s.source       = { :git => "https://github.com/Econa77/SFHDebugToolKit.git" }
  s.platform = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'SFHDegubToolKit/SFHDebugToolKit.{h,m}'
  s.dependency = 'FLEX'
end
