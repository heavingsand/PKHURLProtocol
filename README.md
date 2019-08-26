# PKHURLProtocol
利用NSURLProtocol拦截UIWebView的网络请求

在app加载webview的时,我们可能需要对网页做一些特殊的处理，比如：拦截网页的接口请求修改后在转发，修改或者监听接口返回值，修改网页的图片等等。。。这时候就需要用到iOS提供的黑魔法NSURLProtocol。

根据官网的描述,在每一个 HTTP 请求开始时，系统会创建一个合适的 NSURLProtocol 对象处理对应的 URL 请求，因为 NSURLProtocol 是一个抽象类，所以我们需要做的就是写一个继承自 NSURLProtocol 的类，并通过 - registerClass: 方法注册我们的协议类，然后 URL 加载系统就会在请求发出时使用我们创建的协议对象对该请求进行处理。

```
URLProtocol.registerClass(PKHRegisterURLProtocol.self)
```
`URLProtocol.registerClass(PKHRegisterURLProtocol.self)`
