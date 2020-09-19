//
//  DetailViewController.swift
//  baseball_swift
//
//  Created by Ryan Jung on 9/5/20.
//  Copyright © 2020 Ryan Jung. All rights reserved.
//

import UIKit

protocol BaseballVORPDetail {
    var currPlayerId: Int { get }
    var todayDate: String { get }
    
    func getVorp(startDate: String, completion: @escaping (String) -> UITableViewCell)
}

// Table View that will show VORPs for set of time periods for player
class DetailViewController: UITableViewController, BaseballVORPDetail {
    // Get name passsed from main ViewController and set title of view controller
    var currPlayerName: String! {
        didSet{
            navigationItem.title = currPlayerName
        }
    }
    var currPlayerId: Int = 13110
    var todayDate: String = "12/31/2020"
    
    // Property for detailViewController's data
    var data: DetailData!
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    // Initialize today's date and detail data
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.todayDate = dateFormatter.string(from: Date())
        self.data = DetailData(id: self.currPlayerId, endDate: self.todayDate)
    }
    
    // First required function for UITableView to override so it knows how many rows to construct
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.startDates.count
    }
    
    // Second required function for UITableView to override to fill each row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "UITableViewCell")
        
        // Get initial text describing time interval from data
        let key = self.data.tableText[indexPath.row]
        
        // Get start date from data for VORP query
        let start: String = self.data.startDates[indexPath.row]
        
        // Call getVorp and pass in completion handler to deal with async API call
        getVorp(startDate: start) {
            (result) -> UITableViewCell in
            
            OperationQueue.main.addOperation {
                cell.textLabel?.text = key
                cell.detailTextLabel?.text = result
            }
            return cell
        }
        
        return cell
    }
    
    // Function that wraps scrape call with start date, today's date, and player ID
    func getVorp(startDate: String, completion: @escaping (String) -> UITableViewCell) {
        let idStr: String = String(self.currPlayerId)
        let url = BaseballVorpAPI.baseballScrapeURL(parameters: [startDate, self.todayDate, idStr])
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
                
            if let jsonData = data {
                do {
                    let text = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    if let jsonObject = text as? [String:Any] {
                        if let vorp = jsonObject["Vorp"] as? Double {
                            let vorpStr: String = String(describing: vorp)
                            completion(vorpStr)
                        }
                    }
                } catch let error {
                    print("Error creating JSON object: \(error)")
                }
            } else if let requestError = error {
                print("Error fetching baseball player name: \(requestError)")
            } else {
                print("Unexpected error with the request")
            }
        }
        task.resume()
    }
}
