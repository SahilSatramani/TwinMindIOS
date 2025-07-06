


import SwiftUI

struct QAResponseSheet: View {
    let qaItem: QAItem
    @Binding var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Close button
            HStack {
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }

            // Question title
            Text(qaItem.question)
                .font(.title2)
                .bold()
                .padding(.horizontal)

            Divider()

            // Scrollable answer
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Answer:")
                        .font(.headline)
                        .padding(.bottom, 4)
                    Text(qaItem.answer)
                        .font(.body)
                }
                .padding(.horizontal)
            }

            Spacer()

            // Follow-up CTA
            Button(action: {
                // You can optionally prefill another question screen
            }) {
                Text("Ask follow up...")
                    .foregroundColor(.blue)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
}
