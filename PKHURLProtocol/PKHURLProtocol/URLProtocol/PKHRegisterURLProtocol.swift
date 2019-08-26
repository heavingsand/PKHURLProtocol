//
//  RegisterURLProtocol.swift
//  mangobanker
//
//  Created by 潘柯宏 on 2019/3/28.
//  Copyright © 2019 潘柯宏. All rights reserved.
//

import UIKit

// 为了避免canInitWithRequest和canonicalRequestForRequest的死循环
private let RegisterURLProtocolKey = "RegisterURLProtocol"

class PKHRegisterURLProtocol: URLProtocol {

    var dataTask: URLSessionDataTask!
    var sessionDelegateQueue: OperationQueue!
    var response: URLResponse!
    
    // MARK: - Method
    
    /// 开始监听
    class func startMonitor() {
        let sessionConfiguration = PKHSessionConfiguration.defaultCenter()
        URLProtocol.registerClass(PKHRegisterURLProtocol.self)
        if !sessionConfiguration.isSwizzle {
            sessionConfiguration.load()
        }
    }
    
    /// 停止监听
    class func stopMonitor() {
        let sessionConfiguration = PKHSessionConfiguration.defaultCenter()
        URLProtocol.registerClass(PKHRegisterURLProtocol.self)
        if sessionConfiguration.isSwizzle {
            sessionConfiguration.unload()
        }
    }
    
    // MARK: - Override
    
    /// 在这里拦截或者放行接口请求
    ///
    /// - Parameter request: 本次请求
    /// - Returns: 是否需要监控
    override open class func canInit(with request: URLRequest) -> Bool {
        //  如果已经拦截过请求就放行，避免出现死循环
        if (URLProtocol.property(forKey: RegisterURLProtocolKey, in: request) != nil) {
            return false
        }
        
        /// 修改百度首页的logo
        if let requestStr = request.url?.absoluteString {
            if requestStr.contains("https://m.baidu.com/static/index/plus/plus_logo_web.png") {
                return true
            }
        }

        return false
    }
    
    /// 在这里设置拦截的请求, 可以在这里统一设置接口请求, 比如往请求头里面添加东西
    ///
    /// - Parameter request: 本次请求
    /// - Returns: 我们自定义的请求
    override open class func canonicalRequest(for request: URLRequest) -> URLRequest {
        let newRequest = request as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: RegisterURLProtocolKey, in: newRequest)
        print("request.URL.absoluteString = \(String(describing: request.url?.absoluteString))")
        if let data = newRequest.httpBody {
            let dataStr = String(data: data, encoding: .utf8)
            print("requst数据: \(dataStr)")
        }
        return newRequest as URLRequest
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    /// 重写父类开始加载
    override open func startLoading() {
        
//        print("request.URL.absoluteString = \(String(describing: request.url?.absoluteString))")
        
        let configuration = URLSessionConfiguration.default
        
        sessionDelegateQueue = OperationQueue()
        sessionDelegateQueue.maxConcurrentOperationCount = 1
        sessionDelegateQueue.name = "com.pankehong.session.queue"
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: sessionDelegateQueue)
        
        let requestNew = URLRequest(url: URL(string: "http://www.mangobanker.com/static/image/82a5b5f7-8389-49da-8b14-91b33c9882d8.png")!)
        
        dataTask = session.dataTask(with: requestNew)
        dataTask.resume()
        
    }
    
    /// 重写父类的重复加载
    override open func stopLoading() {
        if dataTask != nil {
            dataTask.cancel()
        }
    }
    
}

// MARK: - URLSessionDelegate代理
extension PKHRegisterURLProtocol: URLSessionDelegate, URLSessionDataDelegate {
    // 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截取
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        
        if let dataStr  = String(data: data, encoding: .utf8) {
            print("截取返回数据: \(dataStr)")
        }
        
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: URLCache.StoragePolicy.allowed)
        completionHandler(URLSession.ResponseDisposition.allow)
        self.response = response
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
        self.response = response
        client?.urlProtocol(self, wasRedirectedTo: request, redirectResponse: response)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        }else {
            client?.urlProtocolDidFinishLoading(self)
        }
        dataTask = nil
    }
    
}
