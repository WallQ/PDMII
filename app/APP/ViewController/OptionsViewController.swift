//
//  OptionsViewController.swift
//  APP
//
//  Created by André Pinto on 17/12/2021.
//

import UIKit
import CoreData

class OptionsViewController: UIViewController {

    @IBOutlet weak var lblCacheDays: UILabel!
    @IBOutlet weak var stepperCacheDays: UIStepper!
    
    @IBAction func onChangeCacheDays(_ sender: UIStepper) {
        lblCacheDays.text = String(stepperCacheDays.value)
        AppDelegate.shared().tempCashe = stepperCacheDays.value
    }
    
    @IBAction func onClickFetchAPItoCoreData(_ sender: UIButton) {
        //fecthNews()
        updateCoreData()
        //deletNews()
    }
    
    @IBAction func onClickWipeCache(_ sender: UIButton) {
        deletNews()
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblCacheDays.text = String(AppDelegate.shared().tempCashe)
        stepperCacheDays.value = AppDelegate.shared().tempCashe
        
    }
    
    func fecthNews(){
        do {
            let x = try context.fetch(NewsCoreData.fetchRequest())
            print("Core Data : \(x)")
        }
        catch {
            print("Error Geting Core data")
        }
        
    }
    func deletNews(){
        do {
            let x = try context.fetch(NewsCoreData.fetchRequest())
            
            for item in x{
                self.context.delete(item)
            }
            
            try! self.context.save()
            print("Core Data : \(x)")
        }
        catch {
            print("Error Deleting Core data")
        }
        
    }
    
    func updateCoreData(){
        APIService.shared.getTopArticles{ [weak self] result in
            switch result {
            case .success(let articles):
                
                for item in articles{
                    
                    let request = NewsCoreData.fetchRequest() as NSFetchRequest<NewsCoreData>
                    request.predicate = NSPredicate(format: "id == %i", item.id)
                    let findNews = try! self?.context.fetch(request)
                    
                    if(findNews!.isEmpty == false){
                        print("Vou Atualizar a Noticia")
                        let toUpdateNews = findNews![0] as NewsCoreData
                        toUpdateNews.id = item.id
                        toUpdateNews.url = item.url
                        toUpdateNews.newsSite = item.newsSite
                        toUpdateNews.updatedAt = item.updatedAt
                        toUpdateNews.publishedAt = item.publishedAt
                        toUpdateNews.imageUrl = item.imageUrl
                        toUpdateNews.summary = item.summary
                        toUpdateNews.title = item.title
                        
                    }else{
                        print("Vou Inserir a Noticia")
                        let newItem = NewsCoreData(context: self!.context)
                        newItem.id = item.id
                        newItem.url = item.url
                        newItem.newsSite = item.newsSite
                        newItem.updatedAt = item.updatedAt
                        newItem.publishedAt = item.publishedAt
                        newItem.imageUrl = item.imageUrl
                        newItem.summary = item.summary
                        newItem.title = item.title
                        //por default já é false
                        newItem.fav = false
                    }
                }
                try! self?.context.save()
                //self!.fecthNews()
            case .failure(let error):
                print("API ERROR: \(error)")
            }
        }
    }
    
    
}
