import Ably
import SwiftUI

struct ContentView: View {
    
    @State var showDeviceDetailsAlert = false
    @State var deviceDetails: ARTDeviceDetails?
    @State var deviceDetailsError: ARTErrorInfo?
    
    @State var showDeviceTokensAlert = false
    @State var defaultDeviceToken: String?
    @State var locationDeviceToken: String?
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Button("Activate Push") {
                    AblyHelper.shared.activatePush { token1, token2 in
                        defaultDeviceToken = token1
                        locationDeviceToken = token2
                        showDeviceTokensAlert = true
                    }
                }
                .alert(isPresented: $showDeviceTokensAlert) {
                    guard let defaultDeviceToken = defaultDeviceToken, let locationDeviceToken = locationDeviceToken else {
                        return Alert(title: Text("Device Tokens"), message: Text("Unknown result."))
                    }
                    return Alert(title: Text("Device Tokens"), message: Text("Default: \(defaultDeviceToken)\n\nLocation: \(locationDeviceToken)"))
                }
                .padding()
                Button("Dectivate") {
                    AblyHelper.shared.deactivatePush()
                }
                .padding()
                Button("Print Token") {
                    AblyHelper.shared.printIdentityToken()
                }
                .padding()
                Button("Device Details") {
                    AblyHelper.shared.getDeviceDetails { details, error in
                        deviceDetails = details
                        deviceDetailsError = error
                        showDeviceDetailsAlert = true
                    }
                }
                .alert(isPresented: $showDeviceDetailsAlert) {
                    if deviceDetails != nil {
                        return Alert(title: Text("Device Details"), message: Text("\(deviceDetails!)"))
                    }
                    else if deviceDetailsError != nil {
                        return Alert(title: Text("Device Details Error"), message: Text("\(deviceDetailsError!)"))
                    }
                    return Alert(title: Text("Device Details Error"), message: Text("Unknown result."))
                }
                .padding()
                Button("Send Push") {
                    AblyHelper.shared.sendAdminPush(title: "Hello", body: "This push was sent with deviceId")
                }
                .padding()
                NavigationLink {
                    LocationPushEventsView()
                } label: {
                    Text("List of location push events")
                }
                .padding()
                Spacer()
            }
            .navigationTitle("Ably Push Example")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
