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
    
    var searchResults = [MKLocalSearchCompletion]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchCompleter.delegate = self
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = []
        guard searchText != "" else {
            tableView.reloadData()
            return
        }
        searchCompleter.queryFragment = searchText
        tableView.reloadData()
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        for item in completer.results {
            if item.title.contains(",") {
                searchResults.append(item)
            }
        }
        tableView.reloadData()
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = searchResults[indexPath.row].title
        return cell
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = searchResults[indexPath.row]
        let searchRequest = MKLocalSearchRequest(completion: item)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { (response, error ) in
            if let placemark = response?.mapItems[0].placemark {
                let city = placemark.locality!
                let countryCode = placemark.isoCountryCode!
                print("City name: \(city)", "Country: \(countryCode)")
            } else {
                if let error = error {
                    print("Placemark not found \(error)")
                }
            }
        }
    }
}
