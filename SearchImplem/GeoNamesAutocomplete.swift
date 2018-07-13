//
//  GeoNamesAutocomplete.swift
//  SearchImplem
//
//  Created by Alex Dinu on 01/07/2018.
//  Copyright © 2018 Alex Dinu. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GeoNamesAutocomplete: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var task: URLSessionDataTask?
    var cities = [City]()
    
    
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cities = []
        guard searchText != "" else {
            tableView.reloadData()
            return
        }
        searchCity(city: searchText)
        tableView.reloadData()
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "geoNamesCell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row].name
        cell.detailTextLabel?.text = cities[indexPath.row].country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertVC = UIAlertController(title: "\(cities[indexPath.row].name ?? "") coordinates", message: "lat: \(cities[indexPath.row].coordinates?.0 ?? 0 ), long: \(cities[indexPath.row].coordinates?.1 ?? 0 )", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okButton)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    func searchCity(city: String) {
        let key = "gabel.dinu"
        
        var queryItems = [URLQueryItem]()
        let parameters = [
            "featureClass": "P",
            "name_startsWith": city,
            "username": key]
        
        for (key, value) in parameters {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = "api.geonames.org"
        urlComponents.path = "/searchJSON"
        urlComponents.queryItems = queryItems
        
        guard let cityURL = urlComponents.url else {
            return
        }
    
        let request = URLRequest(url: cityURL)
        task?.cancel()
        task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let jsonData = data {
                do {
                    guard
                        let jsonDictionary = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: AnyObject],
                        let cityDict = jsonDictionary["geonames"] as? [[String: AnyObject]]  else {
                            return
                    }
                    
                    for item in cityDict {
                        let name = item["toponymName"] as! String
                        let countryName = item["countryName"] as! String
                        let adminName = item["adminName1"] as! String
                        let lat = item["lat"] as! String
                        let long = item["lng"] as! String
                        let newCity: City = {
                            let city = City()
                            city.name = name
                            city.country = countryName
                            city.adminArea = adminName
                            city.coordinates = (Double(lat) ?? 0, Double(long) ?? 0)
                            return city
                        }()
                        // remove duplicates
                        var present = false
                        for item in self.cities {
                            if item.name == newCity.name && item.country == newCity.country  {
                                present = true
                            }
                        }
                        if !present {
                            self.cities.append(newCity)
                        }
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                catch let error {
                    print(error)
                }
            } else {
                print("There was an error")
            }
        }
        task?.resume()
    }
    
}
