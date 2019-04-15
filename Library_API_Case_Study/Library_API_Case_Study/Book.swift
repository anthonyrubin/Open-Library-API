//
//  Book.swift
//  Library_API_Case_Study
//
//  Created by Anthony Rubin on 4/12/19.
//  Copyright © 2019 Anthony Rubin. All rights reserved.
//
//all of the decodable structs can be found here
//these structs are the bones of the JSON Parsing
import Foundation

struct Books: Decodable{
    let object: [BookObject]
}
struct doc: Decodable{
    let title_suggest: String?
    let subtitle: String?
    let author_name: [String]?
    let first_publish_year: Int?
    let cover_i: Int?
    let publisher: [String]?
    let author_alternative_name: [String]?
    let ia: [String]?
    
    
}
struct BookObject: Decodable{
    let start: Int?
    let num_found: Int?
    let docs: [doc]
    
}

