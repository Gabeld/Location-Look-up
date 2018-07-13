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
    var predictions = [City]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        defer { tableView.reloadData() }
        
        predictions = []
        guard searchText != "" else {
            return
        }
        getPlaceAutocomplete(userInput: searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "googleCell", for: indexPath)
        cell.textLabel?.text = predictions[indexPath.row].name
        cell.detailTextLabel?.text = predictions[indexPath.row].country
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertVC = UIAlertController(title: "\(predictions[indexPath.row].name ?? "") coordinates", message: "lat: \(predictions[indexPath.row].coordinates?.0 ?? 0), long: \(predictions[indexPath.row].coordinates?.1 ?? 0)", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okButton)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func getPlaceAutocomplete(userInput: String) {
        let apiKey:String = "AIzaSyAj4WP8kwzjstnDvWqGMNehJ9YNSxIh_Fs"
        let queryItems = [URLQueryItem(name: "input", value: userInput), URLQueryItem(name: "types", value: "(cities)"), URLQueryItem(name: "key", value: apiKey)]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/place/autocomplete/json"
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return
        }
        
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
                        let googleID = item["place_id"] as! String
                        let separatedStrings = placeDescription.components(separatedBy: ", ")
                        let city = City()
                        city.googleLocationID = googleID
                        self.getPlaceDetails(id: city.googleLocationID!)
                        switch separatedStrings.count {
                        case 1:
                            city.name = separatedStrings[0]
                        case 2:
                            city.name = separatedStrings[0]
                            city.country = separatedStrings[1]
                        case 3:
                            city.name = separatedStrings[0]
                            city.adminArea = separatedStrings[1]
                            city.country = separatedStrings[2]
                        default:
                            break
                        }
                        self.predictions.append(city)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch let error {
                    print(error)  // handle error
                }
            }
        }
        task.resume()
    }
    func getPlaceDetails(id: String) {
        let apiKey:String = "AIzaSyAj4WP8kwzjstnDvWqGMNehJ9YNSxIh_Fs"
        let queryItems = [URLQueryItem(name: "placeid", value: id), URLQueryItem(name: "key", value: apiKey)]
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "maps.googleapis.com"
        urlComponents.path = "/maps/api/place/details/json"
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return
        }
        
        let request = URLRequest(url: url)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonData = data {
                do {
                    guard
                        let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String:AnyObject],
                        let result = jsonDictionary["result"] as? [String: AnyObject],
                        let geometry = result["geometry"] as? [String: AnyObject],
                        let location = geometry["location"] as? [String: Double]
                        else {
                            return
                    }
                    let lat = location["lat"]
                    let long = location["lng"]
                    let coordinates = (lat, long)
                    
                    for city in self.predictions {
                        if let currentID = city.googleLocationID, currentID == id  {
                            city.coordinates = coordinates as? (Double, Double)
                        }
                    }
                }
                catch let error {
                    print(error)  // handle error
                }
            }
        }
        task.resume()
    }
    
}

