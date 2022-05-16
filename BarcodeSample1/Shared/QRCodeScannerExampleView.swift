//
//  QRCodeScannerExampleView.swift
//  BarcodeSample1
//
//  Created by jae hwan choo on 2022/05/16.
//

import SwiftUI

struct QRCodeScannerExampleView: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String?

    var body: some View {
            ZStack {
                if let scannedCode = self.scannedCode {
                    // NavigationLink("Next page", destination: NextView(scannedCode: scannedCode!), isActive: .constant(true)).hidden()
                    //Text("scanCode ; \(scannedCode)")
                    
//                    MyWebview(urlToLoad: scannedCode)
                    Text("scanCode : \(scannedCode)")
                } else {
//                    MyWebview(urlToLoad: "https://m.dhlottery.co.kr/")
                    Text("scanCode : 하단 버튼을 이용하여 코드 가져오기")
                }
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        self.isPresentingScanner = true
                    }) {
                        Text("바코드, QR 확인")
                            .fontWeight(.heavy)
                            .font(.system(size: 40))
                            .foregroundColor(Color.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(20)
                            .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.blue, lineWidth: 4)
                                )
                    }
                    .sheet(isPresented: $isPresentingScanner) {
                        self.scannerSheet
                    }
                    
                    Spacer().frame(height: 30)
                }
                
            }

    }

    var scannerSheet : some View {
        ZStack {
            CodeScannerView(
                codeTypes: [
                    .code39,
                    .code39Mod43,
                    .code93,
                    .code128,
                    .ean8,
                    .ean13,
                    .aztec,
                    .pdf417,
                    .itf14,
                    .dataMatrix,
                    .interleaved2of5,
                    .qr],
                completion: { result in
                    if case let .success(code) = result {
                        self.scannedCode = code
                        self.isPresentingScanner = false
                    }
                }
            )
            
            QRCodeGuideView()
        }
    }
}

struct QRCodeScannerExampleView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeScannerExampleView()
    }
}
