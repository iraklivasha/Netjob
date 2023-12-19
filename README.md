<h1 align="center"> Simplify networking </h1>
<p align="center">
  <img height="200" src="https://github.com/iraklivasha/Netjob/blob/main/Resources/rocket.png">
</p>

Are you just starting? <br/>
Want to quickly succeed in calling the real rest API endpoint? <br/>
Or simply just test your code using mocked responses? <br/>

<h2 align="center"> You are at right station 🚃 </h2>

Installation: 

```ruby
pod "Netjob", :git => 'https://github.com/iraklivasha/Netjob.git', :branch => 'main'
```

Use:

```swift
Netjob
  .url("https://yourendpointurl.com/path")
  .request { (response: Result<Employee, NetjobError>) in
    switch response {
      case .success(let emp):
      break
      case .failure(let error):
      break
  }
}
```

That's all. Congratulations! 🥂

<h2>But wait, </h2>

If that's not enough, try typing `with` before `request`, XCode will tell you the rest 🤩

```swift
Netjob
  .url("https://yourendpointurl.com/path")
  .withMethod(.post)
  .withHeaders(["Authorization": "Bearer token"])
  .withCachePolicy(.reloadIgnoringLocalCacheData)
  .withParameters(["key": "value"])
  .withURLParameters(["key": "value"])
  .withCallbackQueue(.main)
  .withMockResponsePath("fake_response")
  .request { (response: Result<Employee, NetjobError>) in
      switch response {
          case .success(let emp):
          break
          case .failure(let error):
          break
  }
}
``` 

Ah, are you a Combine framework lover? 
Just replace `request` with `requestPublisher`

```swift
Netjob
  .url("https://yourendpointurl.com/path")
  .withMethod(.post)
  .withHeaders(["Authorization": "Bearer token"])
  .withCachePolicy(.reloadIgnoringLocalCacheData)
  .withParameters(["key": "value"])
  .withURLParameters(["key": "value"])
  .withCallbackQueue(.main)
  .withMockResponsePath("fake_response")
  .requestPublisher(type: Employee.self)
``` 

