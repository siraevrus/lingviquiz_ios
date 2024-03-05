import Foundation

enum PlistName: String {
    case englishWords = "englishWords"
    case russianWords = "russianWords"
}

final class PlistManager {
    
    static let shared = PlistManager()
    
    private init() {}
    
    private func getPlistURL(plistName: String) -> URL? {
        // Get the URL for the Documents directory in the user's home directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            return documentsDirectory.appendingPathComponent(plistName).appendingPathExtension("plist")
        }
        return nil
    }
    
    func saveDataToPlist(data: QuestionsData, plistName: String) {
        do {
            let encoder = PropertyListEncoder()
            let plistData = try encoder.encode(data)
            
            // Get the URL for the plist file
            if let plistURL = getPlistURL(plistName: plistName) {
                // Create a file at the specified URL with the data
                try plistData.write(to: plistURL)
            }
        } catch {
            print("Error saving data to plist: \(error)")
        }
    }
    
    func loadDataFromPlist(plistName: String) -> QuestionsData? {
        // Get the URL for the plist file
        if let plistURL = getPlistURL(plistName: plistName) {
            do {
                // Read the data from the plist file
                let plistData = try Data(contentsOf: plistURL)
                
                // Decode the data into a QuestionsData object
                let decoder = PropertyListDecoder()
                let data = try decoder.decode(QuestionsData.self, from: plistData)
                
                return data
            } catch {
                print("Error loading data from plist: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
    func deleteAllPlists() {
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsDirectory, includingPropertiesForKeys: nil)
            for url in fileURLs {
                // Check if the file is a plist
                if url.pathExtension == "plist" {
                    // Delete the plist file
                    try fileManager.removeItem(at: url)
                }
            }
            print("All plists deleted successfully.")
        } catch {
            print("Error deleting plists: \(error)")
        }
    }

}

