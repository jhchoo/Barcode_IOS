//
//  ViewController.swift
//  BarcodeSample2
//
//  Created by jae hwan choo on 2022/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelScan: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // 이동시 델리게이트
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ScanViewController" {
            let vc = segue.destination as! ScanViewController
            vc.delegate = self
        }
    }
    
}

extension ViewController: ScanDataDelegate {
    // 스캔 결과값을 받는다.
    func scanData(data: String) {
        labelScan.text = data
    }
}
