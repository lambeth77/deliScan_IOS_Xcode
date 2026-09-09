import SwiftUI

struct ContentView: View {
    @StateObject private var model = SessionViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Image(systemName: "scope")
                    .font(.system(size: 54))
                    .foregroundStyle(.tint)

                Text("CourseScanner")
                    .font(.largeTitle.bold())

                Text(model.status)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                if let proposal = model.proposal {
                    VStack(spacing: 6) {
                        Text("Dernière proposition")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(proposal.amount.formatted)
                            .font(.title.bold())
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
                }

                Button("Démarrer ma session") {
                    Task { await model.startSession() }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                if model.shouldShowBroadcastPicker {
                    VStack(spacing: 10) {
                        Text("Touchez ce bouton puis « Démarrer la diffusion ». Ensuite, ouvrez l’app à analyser.")
                            .font(.callout)
                            .multilineTextAlignment(.center)
                        BroadcastPickerView(
                            preferredExtension: AppConfiguration.broadcastUploadExtensionIdentifier
                        )
                        .frame(width: 60, height: 60)
                    }
                }

                Button("Actualiser") { model.refresh() }
                    .font(.footnote)
            }
            .padding(28)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { model.refresh() }
        }
    }
}
