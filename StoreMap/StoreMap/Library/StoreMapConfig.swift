

import Foundation

protocol StoreMapConfig {
    var request: URLRequest { get set }
}

class FamilyMartConfig: StoreMapConfig {
    var request: URLRequest
    
    init(cvsname: String, cvsid: String, cvstemp: String, exchange: Bool) {
        
        let queryItems: [URLQueryItem] = [
            .init(name: "cvsname", value: cvsname),
            .init(name: "cvsid", value: cvsid),
            .init(name: "cvstemp", value: cvstemp.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)),
            .init(name: "exchange", value: String(exchange)),
        ]
        
        var urlString = "https://mfme.map.com.tw/default.aspx?"
        for item in queryItems {
            if let value = item.value {
                urlString += item.name + "=" + value + "&"
            }
        }
        
        let baseURL = URL(string: urlString)!
        request = URLRequest(url: baseURL)
    }
}

class SevenElevenConfig: StoreMapConfig {
    var request: URLRequest
    
    // userDefault 的 key
    private enum UserDefaultKeyName: String {
        case storeidSeven
    }
    
    var lastRedirectURL: String = ""
    let replyURL: String
    
    init(eshopid: String, storeid: String?, showtype: Int, tempvar: String, url: String) {
        
        var storeidValue = storeid
        var showtypeValue = String(showtype)
        switch showtype {
        case 1:
            storeidValue = nil
        case 2:
            if let storeid = storeidValue ?? UserDefaults.standard.object(forKey: UserDefaultKeyName.storeidSeven.rawValue) as? String {
                storeidValue = storeid
            } else {
                showtypeValue = "1"
            }
        default:
            showtypeValue = "1"
        }
        
        var components = URLComponents()
        components.queryItems = [
            .init(name: "eshopid", value: eshopid),
            .init(name: "storeid", value: storeidValue),
            .init(name: "showtype", value: showtypeValue),
            .init(name: "tempvar", value: String(tempvar)),
            .init(name: "url", value: url),
        ]
        
        let baseURL = URL(string: "https://emap.presco.com.tw/c2cemapm-u.ashx")!
        request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        replyURL = url
    }
    
    func saveStoreId(from redirectURL: URL) {
        if redirectURL.absoluteString.contains("emap.pcsc.com.tw/mobilemap/Info/Default.aspx"),
           let components = URLComponents(url: redirectURL, resolvingAgainstBaseURL: true),
           let storeId = components.queryItems?.first(where: { $0.name == "StoreId" })?.value {
            
            lastRedirectURL = redirectURL.absoluteString
            UserDefaults.standard.set(storeId, forKey: UserDefaultKeyName.storeidSeven.rawValue)
        }
    }
}

