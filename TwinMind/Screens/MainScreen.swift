import SwiftUI

enum MainTab: String, CaseIterable {
    case memories = "Memories"
    case questions = "Questions"
}

struct MainScreen: View {
    @State private var selectedTab: MainTab = .questions

    var body: some View {
        VStack(spacing: 0) {
            // Top Section
            TopBar()

            Divider()

            // Tabs
            HStack {
                ForEach(MainTab.allCases, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        VStack {
                            Text(tab.rawValue)
                                .foregroundColor(selectedTab == tab ? .blue : .gray)
                                .fontWeight(selectedTab == tab ? .bold : .regular)
                            if selectedTab == tab {
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.blue)
                            } else {
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(.clear)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 8)

            Divider()

            //Placeholder for tab content (to be implemented later)
            Spacer()

            //Bottom Section
            BottomBar()
                .padding(.bottom, 8)
                .padding(.horizontal)
        }
    }
}

#Preview {
    MainScreen()
}
