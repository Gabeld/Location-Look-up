//
//  GoogleAutocomplete.swift
//  SearchImplem
//
//  Created by Alex Dinu on 29/06/2018.
//  Copyright © 2018 Alex Dinu. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class GoogleAutocomplete: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var predictions = [String]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        predictions = []
        guard searchText != "" else {
            tableView.reloadData()
            return
        }
        getPlaceAutocomplete(userInput: searchText)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = predictions[indexPath.row]
        return cell
    }
    
    func getPlaceAutocomplete(userInput: String) {
        let apiKey:String = "AIzaSyAj4WP8kwzjstnDvWqGMNehJ9YNSxIh_Fs"
        var queryItems = [URLQueryItem]()
        let parameters = [
            "input": userInput,
            "types":"(cities)",
            "key": apiKey
        ]
        
        for (key, value) in parameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/place/autocomplete/json"
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return
        }
        print(url)
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonData = data {
                do {
                    guard
                        let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject],
                        let placePredictions = jsonDictionary["predictions"] as? [[String: AnyObject]]
                        else {
                            return
                    }
                    for item in placePredictions {
                        let placeDescription = item["description"] as! String
                        self.predictions.append(placeDescription)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch let error {
                    // handle error
                }
            }
        }
        task.resume()
    }
    
}

