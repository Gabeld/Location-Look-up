//
//  GeocodingViewController.swift
//  SearchImplem
//
//  Created by Alex Dinu on 01/07/2018.
//  Copyright © 2018 Alex Dinu. All rights reserved.
//

import Foundation
import MapKit

class GeocodingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    let geocoder = CLGeocoder()
    var cities = [CLPlacemark]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cities = []
        guard searchText != "" else {
            tableView.reloadData()
            return
        }
        getLocation(city: searchText)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "geocodingCell", for: indexPath)
        cell.textLabel?.text = cities[indexPath.row].name
        cell.detailTextLabel?.text = cities[indexPath.row].country
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertVC = UIAlertController(title: "Coordinates", message: "lat: \(cities[indexPath.row].location?.coordinate.latitude ?? 0), long: \(cities[indexPath.row].location?.coordinate.longitude ?? 0)", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okButton)
        present(alertVC, animated: true, completion: nil)
    }
    
    func getLocation(city: String) {
        geocoder.geocodeAddressString(city, in: nil) { (placemarks, error) in
            if let error = error {
                print(error)
            } else {
                if let placemarks = placemarks, placemarks.count > 0 {
                    for placemark in placemarks {
                        self.cities.append(placemark)
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
}
