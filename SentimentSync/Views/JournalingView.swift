import SwiftUI
import UniformTypeIdentifiers
import MobileCoreServices

struct JournalingView: View {
    @State private var journalText = ""
    @State private var showingSaveOptions = false
    @State private var showingFileSaver = false
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var fileName = "Journal_\(formattedDate())"
    @State private var documentURL: URL?
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Date display
                HStack {
                    Text(currentDateFormatted())
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Journal text editor
                TextEditor(text: $journalText)
                    .font(.system(size: 16, design: .rounded))
                    .padding(10)
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // Placeholder text if journal is empty
                if journalText.isEmpty {
                    VStack {
                        HStack {
                            Text("Write your thoughts here...")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.gray)
                                .padding(.leading, 25)
                            Spacer()
                        }
                        Spacer()
                    }
                    .allowsHitTesting(false)
                }
                
                // Save button
                Button(action: {
                    if !journalText.isEmpty {
                        showingSaveOptions = true
                    } else {
                        alertTitle = "Empty Journal"
                        alertMessage = "Please write something before saving."
                        showingAlert = true
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Save Journal")
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.blue)
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .navigationTitle("Journaling")
            .navigationBarTitleDisplayMode(.inline)
            .actionSheet(isPresented: $showingSaveOptions) {
                ActionSheet(
                    title: Text("Save Journal"),
                    message: Text("Choose where to save your journal entry"),
                    buttons: [
                        .default(Text("Save to Notes App")) {
                            saveToNotes()
                        },
                        .default(Text("Save as File")) {
                            showingFileSaver = true
                        },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: $showingFileSaver) {
                FileSaverView(text: journalText, fileName: $fileName, documentURL: $documentURL, showingAlert: $showingAlert, alertTitle: $alertTitle, alertMessage: $alertMessage)
            }
            .alert(isPresented: $showingAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    // Format current date for display
    private func currentDateFormatted() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: Date())
    }
    
    // Format date for filename
    private static func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return formatter.string(from: Date())
    }
    
    // Save to Notes app using URL scheme
    private func saveToNotes() {
        let encodedText = journalText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let dateString = currentDateFormatted()
        let noteTitle = "Journal Entry - \(dateString)"
        let encodedTitle = noteTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: "mobilenotes://save?title=\(encodedTitle)&body=\(encodedText)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        // Notes app opened successfully
                        journalText = ""  // Clear the text field after saving
                    } else {
                        alertTitle = "Error"
                        alertMessage = "Could not open Notes app."
                        showingAlert = true
                    }
                }
            } else {
                // Fallback if Notes URL scheme isn't available
                UIPasteboard.general.string = journalText
                alertTitle = "Notes App Unavailable"
                alertMessage = "The journal text has been copied to your clipboard. You can manually paste it into the Notes app."
                showingAlert = true
            }
        }
    }
}

// View for saving to files
struct FileSaverView: UIViewControllerRepresentable {
    let text: String
    @Binding var fileName: String
    @Binding var documentURL: URL?
    @Binding var showingAlert: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(fileName).txt")
        documentURL = fileURL
        
        // Write text to the file
        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            alertTitle = "Error"
            alertMessage = "Could not create file: \(error.localizedDescription)"
            showingAlert = true
        }
        
        // Create document picker for exporting
        let picker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileSaverView
        
        init(_ parent: FileSaverView) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            // Clean up the temporary file
            if let tempURL = parent.documentURL {
                try? FileManager.default.removeItem(at: tempURL)
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
            
            // Clean up the temporary file
            if let tempURL = parent.documentURL {
                try? FileManager.default.removeItem(at: tempURL)
            }
        }
    }
}

#Preview {
    NavigationView {
        JournalingView()
    }
}