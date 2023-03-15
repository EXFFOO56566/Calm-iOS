import Parse
import SwiftUI
import Foundation
import Apps4World

/// This is the main data manager responsible to fetch data
public class AppManager {
    
    static var shared = AppManager()
    var categoryImageFiles = [String: PFFileObject]()
    
    /// This will fetch the meditation and sounds categories
    public func fetchDatabaseData(completion: @escaping (_ meditation: [CategoryModel], _ sounds: [CategoryModel]) -> Void) {
        var meditationCategories = MeditationCategory.categoryModels
        var soundCategories = SoundCategory.categoryModels
        
        let meditationQuery = PFQuery(className: "MeditationCategory")
        meditationQuery.findObjectsInBackground { (meditationObjects, _) in
            
            /// Append the categories from backend to the local/default categories
            meditationCategories.append(contentsOf: self.parseCategoryModels(fromObjects: meditationObjects))
            
            /// Fetch sounds categories
            let soundQuery = PFQuery(className: "SoundCategory")
            soundQuery.findObjectsInBackground { (soundObjects, _) in
                soundCategories.append(contentsOf: self.parseCategoryModels(fromObjects: soundObjects))
                
                completion(meditationCategories, soundCategories)
            }
        }
    }
 
    /// This will fetch the sound files for a given category from the backend and also append local sound files to the array
    public func fetchPlaylist(category: CategoryModel, completion: @escaping (_ items: [String]) -> Void) {
        let localMeditationPlaylist = MeditationCategory(rawValue: category.title)?.playlist
        let localSoundsPlaylist = SoundCategory(rawValue: category.title)?.playlist
        var localPlaylist = localMeditationPlaylist ?? localSoundsPlaylist ?? [String]()
        let soundFiles = PFQuery(className: "SoundFiles")
        soundFiles.whereKey("category", equalTo: category.title)
        soundFiles.findObjectsInBackground { (soundObjects, _) in
            localPlaylist.append(contentsOf: self.parseSoundFiles(fromObjects: soundObjects))
            completion(localPlaylist)
        }
    }
}

// MARK: - Parse database data
extension AppManager {
    
    /// Parse categories from backend
    func parseCategoryModels(fromObjects objects: [PFObject]?) -> [CategoryModel] {
        var models = [CategoryModel]()
        objects?.forEach({ (categoryObject) in
            guard let id = categoryObject.objectId else { return }
            
            var dictionary = [String: Any]()
            dictionary["id"] = id
            categoryObject.allKeys.forEach { (key) in
                if let value = categoryObject[key] as? String {
                    dictionary[key] = value
                } else if let imageFile = categoryObject[key] as? PFFileObject, let title = categoryObject["title"] as? String {
                    AppManager.shared.categoryImageFiles[title] = imageFile
                }
            }
            
            if let title = dictionary["title"] as? String {
                let subtitle = dictionary["subtitle"] as? String
                models.append(CategoryModel(id: id, title: title, subtitle: subtitle))
            }
        })
        return models
    }
    
    /// Parse sound files from backend
    func parseSoundFiles(fromObjects objects: [PFObject]?) -> [String] {
        var fileNames = [String]()
        objects?.forEach({ (soundFile) in
            if let fileName = soundFile.value(forKey: "title") as? String,
               let fileObject = soundFile.object(forKey: "mp3") as? PFFileObject, let fileURL = fileObject.url {
                fileNames.append(fileName)
                PlayerManager.shared.soundMP3Files[fileName] = fileURL
            }
        })
        return fileNames
    }
}

// MARK: - Custom image view class to load images from web
public struct RemoteImage: View {
    @ObservedObject var remoteImageUrl: RemoteImageUrl
    private var usePlaceholder: String = "image_placeholder"
    private var imageName: String = ""

    public init(placeholder: String = "image_placeholder", imageUrl: String) {
        imageName = imageUrl
        usePlaceholder = placeholder
        remoteImageUrl = RemoteImageUrl(imageUrl: imageUrl)
    }

    public var body: some View {
        Image(uiImage: UIImage(named: imageName) ?? UIImage(data: remoteImageUrl.data) ?? ImageCache.localImages[imageName] ?? UIImage(named: usePlaceholder)!)
            .resizable().aspectRatio(contentMode: .fill)
    }
}

// MARK: - Load image from URL
class RemoteImageUrl: ObservableObject {
    @Published var data = Data()
    var imageCache = ImageCache.getImageCache()
    
    init(imageUrl: String) {
        if let cacheImage = imageCache.get(forKey: imageUrl)?.pngData() {
            DispatchQueue.main.async { self.data = cacheImage }
        } else {
            if let documentsFolderImage = imageCache.loadImageFromDocumentDirectory(fileName: imageUrl)?.jpegData(compressionQuality: 1.0) {
                DispatchQueue.main.async { self.data = documentsFolderImage }
            }
            AppManager.shared.categoryImageFiles[imageUrl]?.getDataInBackground(block: { (data, _) in
                if let imageData = data, let image = UIImage(data: imageData) {
                    self.data = imageData
                    self.imageCache.set(forKey: imageUrl, image: image)
                }
            })
        }
    }
}
