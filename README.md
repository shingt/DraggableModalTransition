# DraggableModalTransition

[![CI Status](http://img.shields.io/travis/shingt/DraggableModalTransition.svg?style=flat)](https://travis-ci.org/shingt/DraggableModalTransition)
[![Version](https://img.shields.io/cocoapods/v/DraggableModalTransition.svg?style=flat)](http://cocoapods.org/pods/DraggableModalTransition)
[![License](https://img.shields.io/cocoapods/l/DraggableModalTransition.svg?style=flat)](http://cocoapods.org/pods/DraggableModalTransition)
![Xcode 8.2+](https://img.shields.io/badge/Xcode-8.2%2B-blue.svg)
![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)
![Swift 3.0+](https://img.shields.io/badge/Swift-3.0%2B-orange.svg)

## Introduction

DraggableModalTransition enables dragging interaction and animation of scrollView in a similar way to Facebook Messenger app.  
Inspired by [zoonooz/ZFDragableModalTransition](https://github.com/zoonooz/ZFDragableModalTransition). Key difference is you can **continue dragging scrollView after you have finished scrolling to top of it** (See example below).

## Example

<img src="https://cloud.githubusercontent.com/assets/1391330/22452012/930df092-e7b6-11e6-814a-76f5dde45d01.gif" width="260">

Example project is available at `Example/DraggableModalTransition.xcodeproj`.

## Usage

Set an instance of `DraggableModalTransition` to `transitioningDelegate` of viewController you want to present.  
Note that you have to keep an instance of `DraggableModalTransition` even after view is presented.

```swift
func presentModalView() {
    let controller = ModalViewController()
    let navigationController = UINavigationController(rootViewController: controller)
 
    modalTransition = DraggableModalTransition(with: controller)
    navigationController.transitioningDelegate = modalTransition
    controller.modalViewControllerDelegate = modalTransition
    present(navigationController, animated: true, completion: nil)
}
```

For now you also need to call `modalViewDidScroll`. (Hopefully it will be fixed soon.)

```swift
class ModalViewController {
    weak var modalViewControllerDelegate: ModalViewControllerDelegate?
    ...
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        modalViewControllerDelegate?.modalViewDidScroll(scrollView)
    }
} 
```

See example project for more details.

## Requirements

* iOS9+
* Swift 3.0+
* Xcode 8.0+

## Installation

DraggableModalTransition is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DraggableModalTransition"
```

## Author

shingt

## License

DraggableModalTransition is available under the MIT license. See the LICENSE file for more info.
