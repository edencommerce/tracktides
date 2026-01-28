import SwiftUI

struct HomeView: View {
    @State private var showingAddShot: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                // Content will go here
            }
            .background(Color(.systemBackground))
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddShot = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                    .accessibilityLabel("Add shot")
                }
            }
            .sheet(isPresented: $showingAddShot) {
                AddShotView()
            }
        }
    }
}

#Preview {
    HomeView()
}
