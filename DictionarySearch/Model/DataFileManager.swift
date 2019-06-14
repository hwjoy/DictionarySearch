//
//  DataFileManager.swift
//  DictionarySearch
//
//  Created by hwjoy on 2019/5/26.
//  Copyright © 2019 redant. All rights reserved.
//

import UIKit

class DataFileManager: NSObject {

    class func getFilePath(fileName: String?) -> String? {
        guard let fileName = fileName else {
            return nil
        }
        let filePath = Bundle.main.path(forResource: fileName, ofType: "txt")
        return filePath
    }
    
    class func deleteFile(fileName: String?) -> Bool {
        guard let filePath = getFilePath(fileName: fileName) else {
            return false
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: filePath) {
            return false
        }
        
        do {
            try fileManager.removeItem(atPath: filePath)
            return true
        } catch {
            return false
        }
    }
    
}
