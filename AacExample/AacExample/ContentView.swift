
import SwiftUI
import WebKit
import AutomaticAssessmentConfiguration

#if os(iOS)
typealias WebViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias WebViewRepresentable = NSViewRepresentable
#endif

struct ContentView: View {

    public static var webView: AoeWebView?

    var body: some View {
        VStack {
            HStack {
                Button("Toggle assessment lock", action: toggleLock)
                    .padding()
            }
            AoeWebView()
        }
        .padding()
    }

    func toggleLock() {
        if ContentView.webView!.aacSession!.isActive {
            ContentView.webView?.aacSession?.end()
        } else {
            ContentView.webView?.aacSession?.begin()
        }
    }
}

class AoeWKWebView: WKWebView {

}


struct AoeWebView: WebViewRepresentable {
    private var webView: WKWebView
    public var aacSession: AEAssessmentSession?
    private var aacDelegate: AACDelegate?

    public init() {

        print("init")

        let config = AEAssessmentConfiguration()
        if self.aacSession == nil { self.aacSession = AEAssessmentSession(configuration: config) }

        let configuration = WKWebViewConfiguration()
        self.webView = AoeWKWebView(frame: CGRect.zero, configuration: configuration)

        if #available(macOS 13.3, iOS 16.4, *) {
            self.webView.isInspectable = true
        }

        let aacDelegate = AACDelegate(owner: self)
        self.aacDelegate = aacDelegate
        self.aacSession?.delegate = aacDelegate

        ContentView.webView = self
    }

#if os(iOS)
    public func makeUIView(context: Context) -> WKWebView {
        print("makeUIView")
        return makeView(context: context)
    }

    public func updateUIView(_ uiView: WKWebView, context: Context) {
    }
#endif

#if os(macOS)
    public func makeNSView(context: Context) -> WKWebView {
        return makeView(context: context)
    }
    public func updateNSView(_ view: WKWebView, context: Context) {}
#endif

    func makeView(context: Context) -> WKWebView {
        let userScript = WKUserScript(source: "", injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        self.webView.configuration.userContentController.addUserScript(userScript)
        self.webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        print("webView.load")

        let data = """
<html>
<body style="font-size: 1em">
    <script>
    </script>
    <form>
        <ol>
            <li>Turn on the assesment lock above.</li>
            <li>Type in the fields.</li>
            <li>Touch the "Touch to remove focus"</li>
            <li>Wait a few seconds (&gt;3?).</li>
            <li>Touch text fields randomly.</li>
            <li>Repeat steps 2-5. Eventually, touching a text field should crash the app.</li>
        </ol>
        <button>Touch to remove focus</button>
        <br/>
        <p><input type="text" name="field1" style="font-size: 1em" /></p>
        <p><input type="text" name="field2" style="font-size: 1em" /></p>
    </form>
</body>
</html>
"""

        self.webView.loadHTMLString(data, baseURL: Bundle.main.resourceURL)
        return self.webView
    }

    class AACDelegate : NSObject, AEAssessmentSessionDelegate {

        var owner: AoeWebView

        init(owner: AoeWebView) {
            self.owner = owner
        }

        // Log that assessment delegate events happened.
         func assessmentSessionDidBegin(_ session: AEAssessmentSession) {
             print("assessmentSessionDidBegin")
         }

         func assessmentSession(_ session: AEAssessmentSession, failedToBeginWithError error: Error) {
             let errdesc = "failedToBeginWithError: " + error.localizedDescription;
             print("Session failed to begin - \(errdesc)")
         }

        func assessmentSession(_ session: AEAssessmentSession, wasInterruptedWithError error: Error) {
            print("Session Interrupted - \(error.localizedDescription)")
            print("Ending session")

        }

        func assessmentSessionDidEnd(_ session: AEAssessmentSession) {
            print("assessmentSessionDidEnd")
        }

    }
}


