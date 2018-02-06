//
//  FlowerClassifier+Fritz.swift
//  WhatFlower
//
//  Created by Eric Hsiao on 2/6/18.
//  Copyright © 2018 Chad A. Rutherford. All rights reserved.
//

import Fritz

extension FlowerClassifier: SwiftIdentifiedModel {

    static let modelIdentifier = "<insert model id>"

    static let packagedModelVersion = 1

    static let session = Session(appToken: "<insert app token>")
}
