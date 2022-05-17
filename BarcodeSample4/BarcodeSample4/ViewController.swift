//
//  ViewController.swift
//  BarcodeSample4
//
//  Created by jae hwan choo on 2022/05/17.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var labelScan: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // 스캔
    @IBAction func actionScan(_ sender: Any) {
        guard let navi = self.navigationController else {
            return
        }
        
        // 네비게이션 이동
        let vc = ScanViewController()
        vc.delegate = self
        navi.present(vc, animated: true)
    }
    
}

extension ViewController: BarcodeScanDelegate {
    func scanner(didCaptureCode code: String) {
        labelScan.text = code
    }
}
