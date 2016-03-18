# MaterialLoader

As an Apple fan, Google's design guidelines called [Material Design](https://www.google.com/design/spec/material-design) really impressed me a lot, and I found myself falling in love with it!

Although there is an awesome repo implemented lots of Material style views ([MaterialKit](https://github.com/nghialv/MaterialKit) by @nghialv), I'm here to make my own.

(Oh I found a [better framework](https://github.com/CosmicMind/Material.git))


Well, the animation is a little bit crappy, but it's not that bad right? :p


Here's how it looks like:


![alt tag](https://raw.github.com/CaptainTeemo/MaterialLoader/master/demo.gif)


### Simple to use

use as HUD
```swift
let loader = MaterialLoader.showInView(view)
// dismiss after 5 seconds
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5)), dispatch_get_main_queue()) { () -> Void in
    loader.dismiss()
}
```

or pull to refresh

```swift
MaterialLoader.addRefreshHeader(scrollView) { () -> Void in
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 5)), dispatch_get_main_queue()) { () -> Void in
        self.scrollView.endRefreshing()
    }
}
```
