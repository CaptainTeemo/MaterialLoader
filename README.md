# MaterialLoader
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Build Status](https://travis-ci.org/CaptainTeemo/MaterialLoader.svg?branch=master)](https://travis-ci.org/CaptainTeemo/MaterialLoader)

As an Apple fan, Google's design guidelines called [Material Design](https://www.google.com/design/spec/material-design) really impressed me a lot, and I found myself falling in love with it!

Although there is an awesome framework implemented lots of Material components ([Material](https://github.com/CosmicMind/Material.git) by @CosmicMind), I'm here to make my own.


~~Well, the animation is a little bit crappy, but it's not that bad right? :p~~

**Finally I've got a better animation.**

Here's how it looks like:


![alt tag](https://raw.github.com/CaptainTeemo/MaterialLoader/master/demo.gif)


### Simple to use

```swift
func after(_ seconds: Double, action: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(NSEC_PER_SEC) * Int64(seconds)) / Double(NSEC_PER_SEC), execute: action)
}
```

use as HUD
```swift
let loader = MaterialLoader.showInView(view)
after(5, action: { () -> Void in
    loader.dismiss()
})
```

or pull to refresh

```swift
MaterialLoader.addRefreshHeader(scrollView) { () -> Void in
    after(5, action: { () -> Void in
        self.scrollView.endRefreshing()
    })
}
```

## Requirements
* iOS 8.0+
* Xcode 7.2+

## Carthage
Put `github "CaptainTeemo/MaterialLoader"` in your cartfile and run `carthage update` from terminal, then drag built framework to you project.

Hope you like it.
