//
//  ViewController.swift
//  sqliteDemo
//
//  Created by Agust Lofianto on 5/20/16.
//  Copyright © 2016 xiang. All rights reserved.
//

import UIKit
import SQLite
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    var datas: JSON = []
    
    func parseData() {
        let url = "http://forexeight.com/data.json"
        Alamofire.request(.GET, url).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    self.datas = json
                    //self.collectionView.reloadData()
                    //print("JSON: \(json)")
                    
                    for (_, data) in self.datas {
                        let nameJson: String = data["name"].stringValue
                        let emailJson: String = data["email"].stringValue
                        
                        self.database(nameJson, paramEmail: emailJson)
                    }
                }
            case .Failure(let error):
                print(error)
            }
        }
    }
    
    func database(paramName: String, paramEmail: String) {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .DocumentDirectory, .UserDomainMask, true
                ).first!
            
            let db = try Connection("\(path)/coba.sqlite3")
            
            //print("Successfully opened connection to database.")
            
            let users = Table("users")
            let id = Expression<Int64>("id")
            let name = Expression<String?>("name")
            let email = Expression<String>("email")
            
            try db.run(users.drop(ifExists: true))
            
            try db.run(users.create { t in
                t.column(id, primaryKey: true)
                t.column(name)
                t.column(email, unique: true)
            })
            
            let insert = users.insert(name <- paramName, email <- paramEmail)
            //let insert = users.insert(name <- Staff(name: "Riki"), email <- Staff(email: "riki.wtu@wavin.co.id"))
            //let insert2 = users.insert(name <- "Udin", email <- "nasrudin.wtu@wavin.co.id")
            //let insert3 = users.insert(name <- "Ferry", email <- "ferry.wtu@wavin.co.id")
            
            do {
                let _ = try db.run(insert)
                //let _ = try db.run(insert2)
                //let _ = try db.run(insert3)
            }
            catch {
                print("insert error")
            }
            
            for user in try db.prepare(users) {
                print("id: \(user[id]), name: \(user[name]!), email: \(user[email])")
            }
        }
        catch {
            print("error connection \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        parseData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

