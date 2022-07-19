import SwiftUI

struct SettingsPage: View {
    @EnvironmentObject var appModel: AppModel
    @State var showTreeHoleLogin = false
    @State var showTreeHoleActions = false
    
    var body: some View {
        NavigationView {
            List {
                Section("account") {
                    uisAccount
                    if appModel.hasAccount {
                        treeHoleAccount
                    } else {
                        treeHoleAccountNotLogged
                    }
                }
                
                Section("Others") {
                    Text("Setting 1")
                    Text("Setting 2")
                    Text("Setting 3")
                }
            }
            .navigationTitle("settings")
        }
    }
    
    private var uisAccount: some View {
        HStack {
            Button(action: {  }) {
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .font(.system(size: 42))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.accentColor, Color.accentColor.opacity(0.3))
            }.padding()
            VStack(alignment: .leading, spacing: 3.0) {
                Text("复旦UIS")
                    .fontWeight(.semibold)
                Text("已登录")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var treeHoleAccount: some View {
        HStack {
            Button(action: { showTreeHoleActions = true }) {
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .font(.system(size: 42))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.accentColor, Color.accentColor.opacity(0.3))
            }.padding()
            VStack(alignment: .leading, spacing: 3.0) {
                Text("fduholeAccount")
                    .fontWeight(.semibold)
                Text("ID: \(appModel.account?.user_id ?? 0)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .confirmationDialog("account", isPresented: $showTreeHoleActions) {
            Button("logout", role: .destructive) {
                // FIXME: 退出后有时菜单会再次弹出
                //showTreeHoleActions = false
                appModel.userCredential = nil
            }
        }
    }
    
    private var treeHoleAccountNotLogged: some View {
        HStack {
            Button(action: { showTreeHoleLogin = true }) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .font(.system(size: 42))
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.secondary, Color.secondary.opacity(0.3))
            }.padding()
            VStack(alignment: .leading, spacing: 3.0) {
                Text("fduholeAccount")
                    .fontWeight(.semibold)
                Text("notLoggedIn")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .sheet(isPresented: $showTreeHoleLogin) { TreeHoleLoginPage(showLoginPage: $showTreeHoleLogin)
        }
        
    }
}

struct SettingsPage_Previews: PreviewProvider {
    static let appModel = AppModel()
    
    static var previews: some View {
        Group {
            SettingsPage()
            SettingsPage()
                .preferredColorScheme(.dark)
        }
        .environmentObject(appModel)
    }
}
