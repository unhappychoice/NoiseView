# NoiseView

NoiseView is a view renders random noise like [Noise (video) - Wikipedia](https://en.wikipedia.org/wiki/Noise_(video)).

![[Noise](/Images/noise.gif)](/Images/noise.gif)

Warning ⚠️: Due to using Metal API, this view does not render the noise correctly on simulators or some devices.
 
## Installation

### Carthage
```
github "unhappychoice/NoiseView"
```

### Add metal lib

Make sure to add default.metallib to your Copy Bundle Resources section.

![[](/Images/lib_dependency.png)](/Images/lib_dependency.png)

## Usage

```swift
class ViewController: UIViewController {
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(NoiseView(frame: UIScreen.main.bounds, device: metalDevice))
    }
}
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/unhappychoice/NoiseView.

## License
The library is available as open source under the terms of the MIT License.
