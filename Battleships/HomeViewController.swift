import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "Easy") {
            let vc = segue.destination as! GameViewController
            vc.difficulty = Level.Easy
        }
    }
}
