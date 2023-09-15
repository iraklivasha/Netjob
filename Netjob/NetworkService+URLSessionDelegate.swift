//
//  NetworkService+URLSessionDelegate.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/06/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

extension NetworkService: URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                
                var isTrusted = false
                if #available(iOS 12.0, *) {
                    isTrusted = SecTrustEvaluateWithError(serverTrust, nil)
                } else {
                    var secresult = SecTrustResultType.invalid
                    let status = SecTrustEvaluate(serverTrust, &secresult)
                    isTrusted = errSecSuccess == status
                }
                
                if (isTrusted) {
                    if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                        let serverCertificateData = SecCertificateCopyData(serverCertificate)
                        let data = CFDataGetBytePtr(serverCertificateData);
                        let size = CFDataGetLength(serverCertificateData);
                        let cert1 = NSData(bytes: data, length: size)
                        let file_der = Bundle.main.path(forResource: "ssl", ofType: "der")
                        
                        if let file = file_der {
                            if let cert2 = NSData(contentsOfFile: file) {
                                if cert1.isEqual(to: cert2 as Data) {
                                    completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust:serverTrust))
                                    return
                                }
                            }
                        }
                    }
                }
            } else {
                // Pinning failed
                completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
        }
    }
}
