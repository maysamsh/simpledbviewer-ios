import SwiftUI

struct HomeEmptyView: View {
    var body: some View {
        ContentUnavailableView(
            "No Domains",
            systemImage: "tray",
            description: Text("This account does not have any domains yet.")
        )
    }
}

#Preview {
    HomeEmptyView()
}
