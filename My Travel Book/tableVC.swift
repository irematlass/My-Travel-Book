//
//  tableVC.swift
//  My Travel Book
//
//  Created by Mac9 on 2.05.2019.
//  Copyright © 2019 Mac9. All rights reserved.
//

import UIKit
import CoreData
class tableVC: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var titleArray=[String]()
    var subtitleArray=[String]()
    var latitudeArray=[Double]()
    var longitudeArray=[Double]()
    
    var selectedTitle=""
    var selectedSubtitle=""
    var selectedLatitude:Double=0
    var selectedLongitude:Double=0
    

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate=self
        tableView.dataSource=self
        
        fetchData()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,selector:#selector(tableVC.fetchData),name:NSNotification.Name(rawValue: "newPlace"),object:nil)
    }
    @objc func fetchData(){
        
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
        request.returnsObjectsAsFaults=false
        
        do{
            let results=try context.fetch(request)
            
            if results.count>0{
                
                self.titleArray.removeAll(keepingCapacity: false)
                self.subtitleArray.removeAll(keepingCapacity: false)
                self.latitudeArray.removeAll(keepingCapacity: false)
                self.longitudeArray.removeAll(keepingCapacity: false)
                
                for result in results as![NSManagedObject]{
                    if let title=result.value(forKey:"title") as? String{
                        self.titleArray.append(title)
                    }
                    
                    if let subtitle=result.value(forKey:"subtitle") as? String{
                        self.subtitleArray.append(subtitle)
                    }
                    
                    if let latitude=result.value(forKey:"latitude") as? Double{
                        self.latitudeArray.append(latitude)
                    }
                    
                    if let longitude=result.value(forKey:"longitude") as? Double{
                        self.longitudeArray.append(longitude)
                    }
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedTitle=titleArray[indexPath.row]
        selectedSubtitle=subtitleArray[indexPath.row]
        selectedLatitude=latitudeArray[indexPath.row]
        selectedLongitude=longitudeArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapVc", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier=="toMapVc"{
            let destinationVC=segue.destination as! mapVC
            destinationVC.selectedTitle=self.selectedTitle
            destinationVC.selectedSubtitle=self.selectedSubtitle
            destinationVC.selectedLatitude=self.selectedLatitude
            destinationVC.selectedLongitude=self.selectedLongitude
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        cell.textLabel?.text=titleArray[indexPath.row]
        return cell
    }

    @IBAction func add(_ sender: Any) {
        selectedTitle=""
        performSegue(withIdentifier: "toMapVc", sender: nil)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
        let context=appDelegate.persistentContainer.viewContext
        
        let request=NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            do{
                let results=try context.fetch(request)
                
                for result in results as![NSManagedObject]{
                    if let title=result.value(forKey: "title") as? String{
                        if title==titleArray[indexPath.row]{
                            context.delete(result)
                            titleArray.remove(at: indexPath.row)
                            subtitleArray.remove(at: indexPath.row)
                            latitudeArray.remove(at: indexPath.row)
                            longitudeArray.remove(at: indexPath.row)
                            self.tableView.reloadData()
                            do{
                              try context.save()
                            }catch{
                                
                            }
                            break
                        }
                    }
                }
                
            }catch{
                
            }
        }
    
    }
    
}
