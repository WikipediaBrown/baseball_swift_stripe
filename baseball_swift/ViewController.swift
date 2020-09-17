//
//  ViewController.swift
//  baseball_swift
//
//  Created by Ryan Jung on 9/1/20.
//  Copyright © 2020 Ryan Jung. All rights reserved.
//

import UIKit

// Protocol for main view controller to ensure we can handle updated name search and VORP calculation once
// valid inputs are received.
protocol BaseballVORP {
    var currPlayerName: String { get }
    var currPlayerId: Int { get }
    var startDate: String { get }
    var endDate: String { get }
    
    func nameFieldEditingChanged(_ sender: UITextField) -> Void
    func submitButtonPressed(_ sender: UIButton) -> Void
}

// Main View Controller for entering player's name and seeing their VORP over specified time period
class ViewController: UIViewController, BaseballVORP {

    @IBOutlet var playerName: UILabel!
    @IBOutlet var vorpLabel: UILabel!
    
    var currPlayerName: String = "" // will override this to be "Player's Name" in viewDidLoad() so it is in sync with label
    var currPlayerId: Int = 13110
    var startDate: String = "01/01/1970"
    var endDate: String = "12/31/2019"  // will override this with today's date in viewDidLoad()
    
    // URL session initialized for web services
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    // Date formatter to ensure proper formatting of date strings
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    // When text field changed, initiate a call to API to find closest matched name
    @IBAction func nameFieldEditingChanged(_ sender: UITextField) {
        let text: String? = sender.text
        if let paramText = text {
            let url = BaseballVorpAPI.baseballSearchURL(parameters: [paramText])
            let request = URLRequest(url: url)
            
            // Fetch data from URL and handle response in completion handler
            let task = session.dataTask(with: request) {
                (data, response, error) -> Void in
                
                if let jsonData = data {
                    do {
                        // Convert returned string to JSON
                        let text = try JSONSerialization.jsonObject(with: jsonData, options: [])
                        
                        // Parse JSON in expected format
                        if let jsonObject = text as? [String:Any] {
                            if let name = jsonObject["Name"] as? String {
                                self.currPlayerName = name
                                
                                // Have to run UI changes on main thread
                                OperationQueue.main.addOperation {
                                    self.playerName.text = name
                                }
                                
                                // Also save current player's ID
                                if let id = jsonObject["Id"] as? Int {
                                    self.currPlayerId = id
                                }
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
    
    // When entered text is a valid date format, store it as class property
    @IBAction func startDateTextEntered(_ sender: UITextField) {
        let text: String? = sender.text
        if (text != nil), let _ = dateFormatter.date(from: text!) {
            self.startDate = text!
        }
    }
    
    // When entered text is a valid date format, store it as class property
    @IBAction func endDateTextEntered(_ sender: UITextField) {
        let text: String? = sender.text
        if (text != nil), let _ = dateFormatter.date(from: text!) {
            self.endDate = text!
        }
    }
    
    // When submit button is pressed, check for required inputs and call API to calculate VORP
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        let idStr: String = String(self.currPlayerId)
        let url = BaseballVorpAPI.baseballScrapeURL(parameters: [self.startDate, self.endDate, idStr])
        let request = URLRequest(url: url)
        
        // Make call to API and handle response data
        let task = session.dataTask(with: request) {
            (data, response, error) -> Void in
                
            if let jsonData = data {
                do {
                    // Convert response data from String to JSON
                    let text = try JSONSerialization.jsonObject(with: jsonData, options: [])
                    
                    // Parse JSON based on expected format from API
                    if let jsonObject = text as? [String:Any] {
                        if let vorp = jsonObject["Vorp"] {
                            
                            // Convert Int in JSON to String value
                            let vorpStr: String = String(describing: vorp)
                            
                            // Process UI changes on main thread
                            OperationQueue.main.addOperation {
                                self.vorpLabel.text = vorpStr
                            }
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
    
    // Initialize property values when view loads
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.endDate = dateFormatter.string(from: Date())
        self.currPlayerName = "Player's Name"
        self.playerName.text = currPlayerName
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Handle passing player Name and ID to detailViewController via segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "detailSegue" segue
        switch segue.identifier {
        case "detailSegue"?:
            // Send player name and ID to destination viewController
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.currPlayerName = self.currPlayerName
            destinationVC.currPlayerId = self.currPlayerId
        case "paySegue"?:
            let _ = segue.destination
        default:
            preconditionFailure("Unexpected segue identifier")
        }
    }
    
}

