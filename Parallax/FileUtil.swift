//
//  FileUtil.swift
//  Parallax
//
//  Created by 王亮 on 2019/10/23.
//  Copyright © 2019 王亮. All rights reserved.
//

import Foundation
import UIKit

struct Photo: Identifiable {
    var id = UUID()
    var url: URL
    var isPortrait: Bool
    var image: UIImage
}

extension FileManager {
    func urls(for directory: FileManager.SearchPathDirectory, skipsHiddenFiles: Bool = true ) -> [URL]? {
        let documentsURL = urls(for: directory, in: .userDomainMask)[0]
        let fileURLs = try? contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: skipsHiddenFiles ? .skipsHiddenFiles : [] )
        return fileURLs
    }
}

class FileUtil {
    public static var photoList:[Photo] = []
    
    public static func onLaunch() {
        self.photoList = self.getPhotoList()
    }
    
    public static func storeImageToDocumentDirectory(image: UIImage, fileName: String) -> Void {
        guard let data = image.pngData() else {
            return
        }
        let fileURL = self.fileURLInDocumentDirectory(fileName)
        do {
            try data.write(to: fileURL)
        } catch {
            
        }
    }
    
    public static func getPhotoList() -> [Photo] {
        var urls = FileManager.default.urls(for: .documentDirectory) ?? []
        urls.sort {(a, b) -> Bool in
            return a.path > b.path
        }
        var list: [Photo] = []
        for url in urls {
            let photo = Photo(url: url, isPortrait: url.path.contains("portrait"), image: UIImage(contentsOfFile: url.path)!)
            list.append(photo)
        }
        
        return list
    }
    
    public static func getLastPhoto() -> UIImage {
        var urls = FileManager.default.urls(for: .documentDirectory) ?? []
        urls.sort {(a, b) -> Bool in
            return a.path > b.path
        }
        
        if urls.count > 0 {
            return ImageUtil.cropImageToSquare(image: UIImage(contentsOfFile: urls[0].path)!)
        }
        return UIImage(imageLiteralResourceName: "AppIcon")
    }
    
    public static func deletePhoto(url: URL) -> Void {
        let fileManager = FileManager()
        do {
            try fileManager.removeItem(atPath: url.path)
        } catch {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
    public static func deletePhoto(urls: [URL]) -> Void {
        for url in urls {
            self.deletePhoto(url: url)
        }
    }

    public static func saveToPhotoLibrary(url: URL) -> Void {
        let image = UIImage(contentsOfFile: url.path)!
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    public static func saveToPhotoLibrary(urls: [URL]) -> Void {
        for url in urls {
            let image = UIImage(contentsOfFile: url.path)!
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    public static var documentsDirectoryURL: URL {
        return FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)[0]
    }
    
    public static func fileURLInDocumentDirectory(_ fileName: String) -> URL {
        return self.documentsDirectoryURL.appendingPathComponent(fileName)
    }
}


func getCGImage(name: String, ext: String) -> CGImage {
    guard
        let url = Bundle.main.url(forResource: name, withExtension: ext),
        let imageSource = CGImageSourceCreateWithURL(url as NSURL, nil),
        let image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil)
    else {
        fatalError("Couldn't load image \(name).\(ext) from main bundle.")
    }
    return image
}

extension UIImage {
    func resize(toTargetSize targetSize: CGSize) -> UIImage {
        // inspired by Hamptin Catlin
        // https://gist.github.com/licvido/55d12a8eb76a8103c753

        let newScale = self.scale // change this if you want the output image to have a different scale
        let originalSize = self.size

        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height

        // Figure out what our orientation is, and use that to form the rectangle
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(origin: .zero, size: newSize)

        // Actually do the resizing to the rect using the ImageContext stuff
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
            self.draw(in: rect)
        }

        return newImage
    }
}
