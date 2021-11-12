//
//  ExhibitionsImageLoader.swift
//  Auctix
//
//  Created by Евгений Башун on 07.11.2021.
//

import UIKit
import FirebaseStorage

final class ExhibitionsImageLoader {
    let storage = Storage.storage().reference()
    static let shared = ExhibitionsImageLoader()
 
    func image(with name: String, completion: @escaping (UIImage?) -> Void) {
        storage.child(name).getData(maxSize: 15 * 1024 * 1024) { data, error in
            if let data = data {
                completion(UIImage(data: data))
            } else {
                completion(.init(named: "default"))
            }
        }
    }
}
