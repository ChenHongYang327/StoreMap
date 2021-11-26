

import UIKit
import WebKit
import SnapKit


struct Info: Codable {
    var storeId: String?
    var timestamp: Date?
    var snapshot: Data?
}

protocol StoreMapToolViewControllerDelegate: AnyObject {
    func getResultInfo(info: Info?)
}

class StoreMapToolViewController: UIViewController {
    
    public weak var delegate: StoreMapToolViewControllerDelegate?
    
    private var familyConfig: FamilyMartConfig?
    private var sevenConfig: SevenElevenConfig?
    private var current: StoreMapConfig?
    private var redirectDownloadUrlStr: String?

    private let wKwebView: WKWebView = {
        let wkwebView = WKWebView()
        return wkwebView
    }()
    
    private let topView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        return view
    }()
    
    // 返回按鈕
    private let backButton: MainThemeButton = {
        let button = MainThemeButton()
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    // 跳轉至senenStore Button
    private let sevenStoreButton: MainThemeButton = {
        let button = MainThemeButton()
        button.setTitle("7-ELEVEN", for: .normal)
        return button
    }()
    
    // 跳轉至FamilyStore Button
    private let familyStoreButton: MainThemeButton = {
        let button = MainThemeButton()
        button.backgroundColor = .green
        button.setTitle("FamilyMark", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    // 可以設定delegate 方法
    // 但不建議此，因為保留彈性給使用者
//    static func showChoseStoreButton<T: UIViewController & StoreMapToolViewControllerDelegate>(from vc: T) {
//        // 使用present 開啟 ViewControll
//        let storeMapToolVC = StoreMapToolViewController()
//        storeMapToolVC.delegate = vc
//        storeMapToolVC.modalPresentationStyle = .fullScreen
//        vc.present(storeMapToolVC, animated: false)
//    }

    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray
        
        wKwebView.navigationDelegate = self
        
        view.addSubview(topView)
        topView.addSubview(backButton)
        
        view.addSubview(sevenStoreButton)
        view.addSubview(familyStoreButton)
        view.addSubview(wKwebView)
        addButtonTarget()
        
        setLayout()
        
        // 把wkwebView 隱藏，需要時再顯示
        wKwebView.isHidden = true
        familyStoreButton.isHidden = familyConfig == nil
        sevenStoreButton.isHidden = sevenConfig == nil
        
    }
    
    private func addButtonTarget(){
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        sevenStoreButton.addTarget(self, action: #selector(didTapSevenStoreButton), for: .touchUpInside)
        familyStoreButton.addTarget(self, action: #selector(didTapFamilyStoreButton), for: .touchUpInside)
    }
    
    private func setLayout(){
        
        topView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(view.frame.width/6)
            make.top.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.width.equalTo(44)
            make.right.equalTo(topView.snp.right).offset(-8)
            make.bottom.equalTo(topView.snp.bottom)
        }
        
        familyStoreButton.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: view.frame.height/4, height: view.frame.height/4))
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-view.frame.height/6)
        }
        
        sevenStoreButton.snp.makeConstraints { make in
            make.size.equalTo(familyStoreButton)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(view.frame.height/5)
        }
        
        wKwebView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
    }
    
    // MARK: Button Setter
    public func setButton(config: FamilyMartConfig) {
        familyConfig = config
    }
    
    public func setButton(config: SevenElevenConfig) {
        sevenConfig = config
    }

    
    // MARK: Button Action
    
    // Seven Button
    @objc private func didTapSevenStoreButton(){
        showWkWebView(config: sevenConfig)
    }
    
    // Family Button
    @objc private func didTapFamilyStoreButton(){
        showWkWebView(config: familyConfig)
    }
    
    // BackButton
    @objc private func didTapBackButton(){
        
        dismiss(animated: false, completion: nil)
    }
    
    // 顯示wkwebView畫面
    private func showWkWebView(config: StoreMapConfig?){
        current = config
        if let request = config?.request {
            wKwebView.load(request)
        }
        wKwebView.isHidden = false
    }
    
}

// MARK: WKwebViewDelegate
extension StoreMapToolViewController: WKNavigationDelegate, WKUIDelegate {
    
    // finish download url
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        guard let startURL = webView.url?.absoluteString else { return }
        print("starturl::\(startURL)")
            
        switch current {
        case is FamilyMartConfig where startURL.contains("retrieve") && startURL.contains("searchWord="):
            sendValueAndDissmiss(urlStr: startURL)
        case let config as SevenElevenConfig where startURL.contains(config.replyURL) :
            sendValueAndDissmiss(urlStr: config.lastRedirectURL)
        default:
            break
        }
        
    }
        
    // start download url
//    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//
//    }
    
   
    // 抓取轉導 URL
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        if navigationAction.navigationType == .other {
            
            guard let url = navigationAction.request.url else {
                print("Transform URL Fail")
                decisionHandler(.cancel)
                return
            }
            
            if let config = current as? SevenElevenConfig {
                config.saveStoreId(from: url)
            }
        }
        decisionHandler(.allow)
        
    }
    
}

extension StoreMapToolViewController {
    
    // 螢幕截圖
    private func getScreenShot(uiElement: UIView)->UIImage{
        let renderer = UIGraphicsImageRenderer(bounds: uiElement.bounds)
        return renderer.image { rendererContext in
            uiElement.layer.render(in: rendererContext.cgContext)
        }
    }
    
    // 把值傳回，並返回
    private func sendValueAndDissmiss (urlStr: String){
        
        let captureTextArray = urlStr.components(separatedBy: "?")
        let queryItem = captureTextArray.last!
        
        let imageJpegData = getScreenShot(uiElement: wKwebView).jpegData(compressionQuality: 0.6)!
        
        let infoItem = Info(storeId: queryItem, timestamp: Date(), snapshot: imageJpegData)
        delegate?.getResultInfo(info: infoItem)
        dismiss(animated: false, completion: nil)
        
    }
    
    // Button theme
    class MainThemeButton: UIButton {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            layer.cornerRadius = 10
            clipsToBounds = true
            titleLabel?.font = .systemFont(ofSize: 30)
            titleLabel?.textAlignment = .center
            setTitleColor(.white, for: .normal)
            backgroundColor = .red
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
