import UIKit
import NoiseView

class ViewController: UIViewController {
    private let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(NoiseView(frame: UIScreen.main.bounds, device: metalDevice))
    }
}
