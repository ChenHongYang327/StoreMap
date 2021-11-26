

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let screenShotImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private let choseStoreButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .green
        button.setTitle("ChooseStore", for: .normal)
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 25)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()
    
    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .yellow
        textView.isSelectable = false
        textView.textColor = .black
        return textView
    }()

    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(choseStoreButton)
        view.addSubview(resultTextView)
        view.addSubview(screenShotImageView)
        
        choseStoreButton.addTarget(self, action: #selector(didTabChoseStoreButton), for: .touchUpInside)
        
        choseStoreButton.snp.makeConstraints { make in
            make.centerX.equalTo(view)
            make.centerY.equalTo(view).offset(-view.frame.height/3)
            make.size.equalTo(CGSize(width: view.frame.width/2, height: view.frame.height/15))
        }
        
        resultTextView.snp.makeConstraints { make in
            make.top.equalTo(choseStoreButton.snp.bottom).offset(16)
            make.centerX.equalTo(view)
            make.width.equalTo(choseStoreButton)
            make.height.equalTo(view.frame.height/3)
        }
        
        screenShotImageView.snp.makeConstraints { make in
            make.width.equalTo(150)
            make.height.equalTo(250)
            make.top.equalTo(resultTextView.snp.bottom).offset(16)
            make.centerX.equalTo(view)
        }
        
    }

    @objc private func didTabChoseStoreButton(){
        
        // 使用present 開啟 ViewControll
        let storeMapToolVC = StoreMapToolViewController()
        storeMapToolVC.delegate = self
        storeMapToolVC.setButton(config: FamilyMartConfig(
            cvsname: "www.shinsoft.com.tw",
            cvsid: UUID().uuidString,
            cvstemp: "供EC廠商傳遞保留的資訊",
            exchange: true
        ))
        storeMapToolVC.setButton(config: SevenElevenConfig(
            eshopid: "851",
            storeid: nil,
            showtype: 2,
            tempvar: UUID().uuidString,
            url: "https://webhook.site/202e305d-f22f-4795-aa21-ca0720a5ab1a"
        ))
        storeMapToolVC.modalPresentationStyle = .fullScreen
        present(storeMapToolVC, animated: false)
    }
    
}

// MARK: StoreMapToolDelegate:
extension ViewController: StoreMapToolViewControllerDelegate {
    
    func getResultInfo(info: Info?) {
        if let info = info {
            screenShotImageView.image = UIImage(data: info.snapshot!)

            let text = "StoreId : \(info.storeId!)\n\nTimestamp : \(info.timestamp!)\n\nSnapShot : \((info.snapshot?.base64EncodedString())!)"
            self.resultTextView.text = text
        }
        
    }
    
}
