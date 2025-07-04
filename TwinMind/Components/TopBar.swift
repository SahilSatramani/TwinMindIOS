import SwiftUI

struct TopBar: View {
    var body: some View {
        HStack {
            // Profile Icon
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 36)
                .overlay(Text("S").bold())

            Spacer()

            // App Title + PRO Badge
            HStack(spacing: 4) {
                Text("TwinMind")
                    .font(.title2)
                    .bold()
                Text("PRO")
                    .font(.caption)
                    .padding(4)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }

            Spacer()

            // Help Button
            Button("Help") {
                // Help action
            }
            .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.top, 16)
    }
}
