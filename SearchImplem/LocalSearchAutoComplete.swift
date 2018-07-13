//
//  LocalSearchAutoComplete.swift
//  SearchImplem
//
//  Created by Alex Dinu on 01/07/2018.
//  Copyright © 2018 Alex Dinu. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreLocation

class LocalSearchAutocomplete: UIViewController, UITableViewDataSource, UITableViewDelegate, MKLocalSearchCompleterDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    let searchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.filterType = .locationsOnly
        return completer
    }()
    
    var predictions = [City]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        defer { tableView.reloadData() }
        predictions = []
        guard searchText != "" else {
            return
        }
        searchCompleter.queryFragment = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        for item in completer.results {
            if item.title.contains(",") {
                let splitString = item.title.components(separatedBy: ", ")
                let newCity: City = {
                    let city = City()
                    if splitString.count == 3 {
                        city.name = splitString[0]
                        city.adminArea = splitString[1]
                        city.country = splitString[2]
                    } else {
                        city.name = splitString[0]
                        city.country = splitString[1]
                    }
                    return city
                }()
                predictions.append(newCity)
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "localSearchCell", for: indexPath)
        cell.textLabel?.text = predictions[indexPath.row].name
        cell.detailTextLabel?.text = predictions[indexPath.row].country
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return predictions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = searchCompleter.results[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: item)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error ) in
            DispatchQueue.main.async {
                if let placemark = response?.mapItems[0].placemark {
                    let name = placemark.locality ?? item.title
                    let coordinates = placemark.coordinate
                    
                    let alertVC = UIAlertController(title: "\(name) coordinates", message: "lat: \(coordinates.latitude ), long: \(coordinates.longitude )", preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okButton)
                    self.present(alertVC, animated: true, completion: nil)
                    
                } else {
                    if let error = error {
                        print("Placemark not found \(error)")
                    }
                }
            }
        }
    }
}
