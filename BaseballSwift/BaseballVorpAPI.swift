//
//  BaseballVorpAPI.swift
//  baseball_swift
//
//  Created by Ryan Jung on 9/1/20.
//  Copyright © 2020 Ryan Jung. All rights reserved.
//

import Foundation

// Different endpoints of our API
enum Endpoint: String {
    case search = "search"
    case scrape = "scrape"
}

// Struct for handling API calls
struct BaseballVorpAPI {
    private static let baseURLString = "http://192.168.1.67:3308/"

    // Generic function to construct URL based on given parameters and return it in escaped form
    private static func baseballVorpURL(endpoint: Endpoint, parameters: [String]?) -> URL {
        var queryStr = endpoint.rawValue
        if let params = parameters {
            for p in params {
                queryStr.append("/" + p)
            }
            let urlStr = baseURLString + queryStr
            let escapedUrlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return(URLComponents(string: escapedUrlString!)!.url!)
        }
        
        return URLComponents(string: baseURLString)!.url!
    }
    
    // Wrapper function for search API
    static func baseballSearchURL(parameters: [String]?) -> URL {
        return baseballVorpURL(endpoint: Endpoint.search, parameters: parameters)
    }
    
    // Wrapper function for scrape API
    static func baseballScrapeURL(parameters: [String]?) -> URL {
        return baseballVorpURL(endpoint: Endpoint.scrape, parameters: parameters)
    }
    
}
