Pod::Spec.new do |s|
  s.name             = 'DraggableModalTransition'
  s.version          = '0.0.1'
  s.summary          = 'Enables dragging interaction similar to Facebook Messenger app'
  s.description      = <<-DESC
DraggableModalTransition enables dragging interaction and animation of scrollView in a similar way to Facebook Messenger app.
                       DESC
  s.homepage         = 'https://github.com/shingt/DraggableModalTransition'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shingt' => 'shingtshin@gmail.com' }
  s.source           = { :git => 'https://github.com/shingt/DraggableModalTransition.git', :tag => s.version.to_s }
  s.ios.deployment_target = '9.0'
  s.source_files = 'Sources/*'
end
