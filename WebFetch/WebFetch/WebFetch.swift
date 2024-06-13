import Foundation
import WebKit

public class WebFetch: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    private var webView: WKWebView!
    private var completionHandler: ((Result<String, Error>) -> Void)?

    public override init() {
        super.init()
        setupWebView()
    }

    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        
        // Add the message handler
        webConfiguration.userContentController.add(self, name: "fetchHandler")
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        
        // Load an empty HTML page
        webView.loadHTMLString("<html><body></body></html>", baseURL: nil)
        
        // Inject the fetch polyfill when the page loads
        let fetchPolyfill = """
        (function(global) {
            'use strict';

            if (global.fetch) {
                return;
            }

            function fetch(url, options) {
                return new Promise(function(resolve, reject) {
                    var request = new XMLHttpRequest();
                    request.open(options.method || 'GET', url);

                    for (var i in options.headers) {
                        request.setRequestHeader(i, options.headers[i]);
                    }

                    request.onload = function() {
                        if (request.status >= 200 && request.status < 300) {
                            resolve({
                                ok: true,
                                status: request.status,
                                statusText: request.statusText,
                                json: function() { return Promise.resolve(JSON.parse(request.responseText)); },
                                text: function() { return Promise.resolve(request.responseText); },
                            });
                        } else {
                            reject(new Error(request.statusText));
                        }
                    };

                    request.onerror = function() {
                        reject(new Error('Network Error'));
                    };

                    request.send(options.body || null);
                });
            }

            global.fetch = fetch;
        })(this);
        """
        
        webView.evaluateJavaScript(fetchPolyfill) { (result, error) in
            if let error = error {
                print("Error injecting fetch polyfill: \(error.localizedDescription)")
            } else {
                print("Fetch polyfill injected successfully")
            }
        }
    }

    public func performFetch(url: String, method: String = "GET", headers: [String: String]? = nil, body: String? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        let headersString = headers?.map { "\"\($0.key)\": \"\($0.value)\"" }.joined(separator: ",") ?? ""
        let bodyString = body ?? "null"
        
        let fetchScript = """
        fetch('\(url)', {
            method: '\(method)',
            headers: { \(headersString) },
            body: \(bodyString)
        })
        .then(response => response.text())
        .then(data => { window.webkit.messageHandlers.fetchHandler.postMessage(data); })
        .catch(error => { window.webkit.messageHandlers.fetchHandler.postMessage('Error: ' + error.message); });
        """
        
        self.completionHandler = completion
        webView.evaluateJavaScript(fetchScript)
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView finished loading")
    }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "fetchHandler" {
            if let messageBody = message.body as? String {
                if messageBody.starts(with: "Error: ") {
                    let errorMessage = String(messageBody.dropFirst(7))
                    completionHandler?(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                } else {
                    completionHandler?(.success(messageBody))
                }
            }
        }
    }
}
