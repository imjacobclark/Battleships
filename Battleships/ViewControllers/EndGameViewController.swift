import UIKit

class EndGameViewController: UIViewController {
    
    @IBOutlet weak var winnerLabel: UILabel!
    
    var winner: Player = Player.None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        winnerLabel.text = winner == Player.P1 ? "P1 Won" : "AI Won"
    }
}
