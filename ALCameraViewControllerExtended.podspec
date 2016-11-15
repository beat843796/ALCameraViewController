Pod::Spec.new do |spec|
  spec.name               = "ALCameraViewControllerExtended"
  spec.version            = "2.3"
  spec.summary            = "A camera view controller with custom image picker and image cropping. Written in Swift."
  spec.source             = { :git => "https://github.com/beat843796/ALCameraViewController.git", :tag => spec.version.to_s }
  spec.requires_arc       = true
  spec.platform           = :ios, "9.0"
  spec.license            = "MIT"
  spec.source_files       = "ALCameraViewController/*.{swift}"
  spec.resources          = ["ALCameraViewController/CameraViewAssets.xcassets", "ALCameraViewController/en.lproj/Localizable.strings", "ALCameraViewController/de.lproj/Localizable.strings"]
  spec.homepage           = "https://github.com/AlexLittlejohn/ALCameraViewController"
  spec.author             = { "Alex Littlejohn" => "alexlittlejohn@me.com" }
end
