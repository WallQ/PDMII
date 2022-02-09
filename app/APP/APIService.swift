//
//  APIService.swift
//  APP
//
//  Created by André Pinto on 21/12/2021.
//

import Foundation

final class APIService{
    static let shared = APIService()
    
    struct Constants {
        static let topHeadlinesURL = URL(string: "https://api.spaceflightnewsapi.net/v3/articles")
    }
    
    private init() {}
    
    public func getTopArticles(completion: @escaping (Result<[NewsModel], Error>)-> Void){
        guard let url = Constants.topHeadlinesURL else{
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("REQUEST ERROR ON START")
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode([NewsModel].self, from: data)
                    print("REQUEST: \(result.count)")
                    completion(.success(result))
                }
                catch{
                    print("REQUEST ERRORrrrrrrr")
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
    
    public func searchByTitle(text: String, completion: @escaping (Result<[NewsModel], Error>)-> Void){
        
        let url = URL(string: "https://api.spaceflightnewsapi.net/v3/articles?title_contains=" + text)
        
        let task = URLSession.shared.dataTask(with: url!) { data, _, error in
            if let error = error {
                print("REQUEST ERROR ON START")
                completion(.failure(error))
            }
            else if let data = data {
                do {
                    let result = try JSONDecoder().decode([NewsModel].self, from: data)
                    print("REQUEST: \(result.count)")
                    completion(.success(result))
                }
                catch{
                    print("REQUEST ERRORrrrrrrr")
                    completion(.failure(error))
                }
            }
            
        }
        task.resume()
    }
    
    
    
}


