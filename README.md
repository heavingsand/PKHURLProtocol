# PKHURLProtocol
利用NSURLProtocol拦截UIWebView的网络请求

在app加载啊webview的时,我们可能需要对网页做一些特殊的处理,比如:拦截网页的接口请求修改后在转发,修改或者监听接口返回值,修改网页的图片等等...这时候就需要用到iOS提供的黑魔法NSURLProtocol.
```
/*!
 * @brief 把格式化的JSON格式的字符串转换成字典
 * @param jsonString JSON格式的字符串
 * @return 返回字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
     
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
```
