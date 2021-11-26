

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
    
    private var redirectDownloadUrlStr: String?
    private var returnURLString: String = "https://webhook.site/3e1ca09d-38d6-4682-a84e-e591652087bb"
    private var isSevenCanSave = false

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

    convenience init(returnURLString: String?){
        self.init()
        
        if returnURLString != nil && returnURLString != "" {
            self.returnURLString = returnURLString!
        }
        
    }
    
    // MARK: Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray
        
        isSevenCanSave = false
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
    
    // MARK: Constant
    
    enum StoreBaseUrlStr: String {
        case seven = "https://emap.presco.com.tw/c2cemapm-u.ashx"
        case family = "https://mfme.map.com.tw/default.aspx?cvsname=www.shi nsoft.com.tw&cvsid=111&cvstemp=%A8%FA%B3f%A9%B 1%ACd%B8%DF%B4%FA%B8%D5&exchange=true"
        
//        func getStoreID() -> String {
//            switch self {
//            case .seven:
//                <#code#>
//            case .family:
//                <#code#>
//            case .family2:
//                <#code#>
//            }
//        }
    }
    
    // userDefault 的 key
    enum UserDefaultKeyName: String {
        case storeidSeven
    }
    
    // MARK: Button Action
    
    // Seven Button
    @objc private func didTapSevenStoreButton(){
        
        // 顯示wKwebview
        wKwebView.isHidden = false
        
        let baseURL = URL(string: StoreBaseUrlStr.seven.rawValue)!
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "eshopid", value: "851"),
            URLQueryItem(name: "tempvar", value: UUID().uuidString),
            URLQueryItem(name: "url", value: returnURLString)
        ]
        
        // 判斷是否要預帶資料
        if let storeid = UserDefaults.standard.object(forKey: UserDefaultKeyName.storeidSeven.rawValue) as? String {
            // 需帶資料
            // storeid -> storeid
            // showtype -> 2
            components?.queryItems?.append(contentsOf: [
                URLQueryItem(name: "storeid", value: storeid),
                URLQueryItem(name: "showtype", value: "2")
            ])
        } else {
            // 重新選擇
            components?.queryItems?.append(contentsOf: [
                URLQueryItem(name: "storeid", value: nil),
                URLQueryItem(name: "showtype", value: "1")
            ])
        }
        let url = components?.url
        showWkWebView(storeURL: url)
        
    }
    
    // Family Button
    @objc private func didTapFamilyStoreButton(){
        // 顯示wKwebview
        wKwebView.isHidden = false
        
        let url = URL(string: StoreBaseUrlStr.family.rawValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        showWkWebView(storeURL: url)
        
    }
    
    // BackButton
    @objc private func didTapBackButton(){
        
        dismiss(animated: false, completion: nil)
    }
    
    // 顯示wkwebView畫面
    private func showWkWebView(storeURL: URL?){
        if let url = storeURL {
            let request = URLRequest(url: url)
            wKwebView.load(request)
        }
    }
    
}

// MARK: WKwebViewDelegate
extension StoreMapToolViewController: WKNavigationDelegate, WKUIDelegate {
    
    // finish download url
//    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        if let url = wKwebView.url {
//            print("finishurl::\(url.absoluteString)")
//        }
//    }
        
    // start download url
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        var startdownloadWebUrlStr: String?
        
        if let url = webView.url {
            startdownloadWebUrlStr = url.absoluteString
//            print("starturl::\(startdownloadWebUrlStr!)")
            
            // For family use
            if startdownloadWebUrlStr!.contains("retrieve") , startdownloadWebUrlStr!.contains("searchWord=") {
                
                sendValueAndDissmiss(urlStr: startdownloadWebUrlStr!, timestamp: Date(), snapshotImage: getScreenShot(uiElement: wKwebView))
            }
            
            // For seven use
            if isSevenCanSave {
                if startdownloadWebUrlStr!.contains(returnURLString) {
                    
                    sendValueAndDissmiss(urlStr: redirectDownloadUrlStr!, timestamp: Date(), snapshotImage: getScreenShot(uiElement: wKwebView))
                }
            }
            
        }
        
    }
    
   
    // 抓取轉導 URL
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Swift.Void) {
        
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url {
                redirectDownloadUrlStr = url.absoluteString
//                print("Transurl::\(url)")
                
                // 判斷是否選擇商店(for seven)
                if redirectDownloadUrlStr!.contains("emap.pcsc.com.tw/mobilemap/Info/Default.aspx") {
                    isSevenCanSave = true
                    
                    // 存storeID to Userdefault (for seven store)
                    /// regular expression
                    let storeId = redirectDownloadUrlStr!.components(separatedBy: "&").first?.components(separatedBy: "=").last
                    UserDefaults.standard.set(storeId!, forKey: UserDefaultKeyName.storeidSeven.rawValue)
                }
                
            } else {
                print("Transform URL Fail")
                decisionHandler(.cancel)
                return
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
    private func sendValueAndDissmiss (urlStr: String, timestamp: Date, snapshotImage: UIImage){
        
        let captureTextArray = urlStr.components(separatedBy: "?")
        let queryItem = captureTextArray.last!
        
        let imageJpegData = snapshotImage.jpegData(compressionQuality: 0.6)!
        
        let infoItem = Info(storeId: queryItem, timestamp: timestamp, snapshot: imageJpegData)
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
