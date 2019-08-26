# PKHURLProtocol
##利用NSURLProtocol拦截UIWebView的网络请求

在app加载webview的时,我们可能需要对网页做一些特殊的处理，比如：拦截网页的接口请求修改后在转发，修改或者监听接口返回值，修改网页的图片等等。。。这时候就需要用到iOS提供的黑魔法NSURLProtocol。

根据官网的描述,在每一个 HTTP 请求开始时，系统会创建一个合适的 NSURLProtocol 对象处理对应的 URL 请求，因为 NSURLProtocol 是一个抽象类，所以我们需要做的就是写一个继承自 NSURLProtocol 的类，并通过 - registerClass: 方法注册我们的协议类，然后 URL 加载系统就会在请求发出时使用我们创建的协议对象对该请求进行处理。

首先，我们需要在加载webview的页面注册我们的URLProtocol类

```
URLProtocol.registerClass(PKHRegisterURLProtocol.self)
```
在我们继承自URLProtocol的类中，重写canInit方法来选择性的拦截网络请求，也可以全部拦截：
```
/// 在这里拦截或者放行接口请求
    ///
    /// - Parameter request: 本次请求
    /// - Returns: 是否需要监控
    override open class func canInit(with request: URLRequest) -> Bool {
        //  如果已经拦截过请求就放行，避免出现死循环
        if (URLProtocol.property(forKey: RegisterURLProtocolKey, in: request) != nil) {
            return false
        }
        return false
    }
```
然后，重写canonicalRequest来对请求做设置，返回新的请求：
```
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
```
在startLoading和stopLoading做接口请求相关的工作，比如在startLoading中开始网络请求，在stopLoading中结束网络请求：
```
/// 重写父类开始加载
    override open func startLoading() {
        
        let configuration = URLSessionConfiguration.default
        
        sessionDelegateQueue = OperationQueue()
        sessionDelegateQueue.maxConcurrentOperationCount = 1
        sessionDelegateQueue.name = "com.pankehong.session.queue"
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: sessionDelegateQueue)
        dataTask = session.dataTask(with: request)
        dataTask.resume()
        
    }
    
    /// 重写父类的重复加载
    override open func stopLoading() {
        if dataTask != nil {
            dataTask.cancel()
        }
    }
```

最后实现URLSessionDelegate，URLSessionDataDelegate的代理，就可以对网络请求返回的数据做相应的处理了
```
// 当服务端返回信息时，这个回调函数会被ULS调用，在这里实现http返回信息的截取
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
        
        if let dataStr  = String(data: data, encoding: .utf8) {
            print("截取返回数据: \(dataStr)")
        }
        
    }
```
这只是URLProtocol的简单应用，喜欢的朋友点个👍
