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
Good job 👍

<h2>Want to keep your endpoints in more structured way ? </h2>

Here's what you can do:
 
```swift
struct Router {}

protocol MyEndpoint: Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
}

extension MyEndpoint {
    
    var url: String {
        return "https://yourrestapi.com/"
    }
    
    var method: HTTPMethod {
        .get
    }
}

struct Employee: Codable {
    var firstName: String
    var lastName: String
}

extension Router {
    enum employees: MyEndpoint {
        
        var path: String {
            switch self {
            case .fetch:
                return "employees"
            case .add(_):
                return "employees/add"
            }
        }
        
        var parameters: Any? {
            switch self {
            case .add(let params):
                return params
            default: return nil
            }
        }
        
        var method: HTTPMethod {
            switch self {
            case .fetch:
                return .get
            case .add(_):
                return .post
            }
        }
        
        case fetch
        case add(params: [String: Any])
    }
}


class API_Completions {
    
    public class func fetchEmployees(completion: @escaping (Swift.Result<Employee, NetjobError>) -> Void) -> CancellableTask? {
        let endpoint = Router.employees.fetch
        return endpoint.request(endpoint: endpoint, completion: completion)
    }
    
    public class func addEmployeePublisher(firstName: String,
                                           lastName: String,
                                           completion: @escaping (Swift.Result<Employee, NetjobError>) -> Void) -> CancellableTask? {
        let endpoint = Router.employees.add(params: [
            "firstName": firstName,
            "lastName": lastName
        ])
        return endpoint.request(endpoint: endpoint, completion: completion)
    }
}

class API_Publisher {
    public class func fetchEmployeesPublisher() -> AnyPublisher<[Employee], NetjobError> {
        let endpoint = Router.employees.fetch
        return endpoint.requestPublisher(endpoint: endpoint)
    }
    
    public class func addEmployeePublisher(firstName: String, lastName: String) -> AnyPublisher<Employee, NetjobError> {
        let endpoint = Router.employees.add(params: [
            "firstName": firstName,
            "lastName": lastName
        ])
        return endpoint.requestPublisher(endpoint: endpoint)
    }
}

```
