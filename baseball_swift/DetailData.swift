//
//  DetailData.swift
//  baseball_swift
//
//  Created by Ryan Jung on 9/8/20.
//  Copyright © 2020 Ryan Jung. All rights reserved.
//

import Foundation

protocol BaseballVORPData {
    var currPlayerId: Int { get }
    var tableText: [String] { get }
    var startDates: [String] { get }
    var endDate: String { get }
    
    func initStartDates(todayDate: String) -> [String]
}

// Class for data needed for DetailViewController
class DetailData: NSObject, BaseballVORPData {
    var currPlayerId: Int = 13110
    var tableText: [String] = ["Career To Date", "Last 3 Seasons", "This Season", "This Month", "Last 2 Weeks"]
    var startDates: [String] = []
    var endDate: String = "12/31/2020"
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    // Initialization of data based on what is passed from main ViewController
    init(id: Int, endDate: String) {
        super.init()
        
        self.currPlayerId = id
        self.endDate = endDate
        
        // Create an array of start dates based on today's date for VORP calculations
        self.startDates = initStartDates(todayDate: self.endDate)
    }
    
    // Helper function for getting back dates to calculate start dates
    func subtractTimeInterval(startDate: String, timeInterval: Double) -> String {
        let startingTime: Date? = dateFormatter.date(from: startDate)
        let newTime = startingTime?.addingTimeInterval(-timeInterval)
        let newTimeFmt = dateFormatter.string(from: newTime!)
        return(String(describing: newTimeFmt))
    }
    
    // Calculate start dates
    func initStartDates(todayDate: String) -> [String] {
        let today = self.endDate
        var retArr: [String] = []
    
        // Break apart today's date so we can do some math
        let dateArr = today.components(separatedBy: "/")
        let month = dateArr[0]
        let year = dateArr[2]
    
        // Give date for career start
        retArr.append("01/01/1970")
    
        // Calculate first day of 3 seasons ago
        if let thisYearInt: Int = Int(year) {
            let threeYearsAgo: Int = thisYearInt - 3
            let threeYearsAgoStart: String = "01/01/" + String(threeYearsAgo)
            retArr.append(String(threeYearsAgoStart))
        } else {
            print("Can't figure out what year it is")
            retArr.append("01/01/2017")
        }
    
        // Calculate first day of this season
        let firstDayThisSeason: String = "01/01/" + year
        retArr.append(firstDayThisSeason)
    
        // Calculate date of first day of this month
        let firstDayThisMonth: String = month + "/01/" + year
        retArr.append(firstDayThisMonth)
    
        // Calculate date of two weeks ago
        let twoWksAgo = subtractTimeInterval(startDate: today, timeInterval: 60*60*24*14)
        retArr.append(twoWksAgo)
    
        return(retArr)
    }
}
