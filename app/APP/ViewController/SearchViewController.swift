import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableViewNews: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    let cellReuseIdentifier = "NewsTableViewCell";
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var viewModelData = [NewsModel]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        tableViewNews.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableViewNews.delegate = self
        tableViewNews.dataSource = self
        tableViewNews.allowsSelection = true

        // Do any additional setup after loading the view.
    }
    
    func searchAndStore(textToSearch: String){
        APIService.shared.searchByTitle(text: textToSearch){[weak self] result in
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
                self!.viewModelData = articles
                
                DispatchQueue.main.async {
                    self!.tableViewNews.reloadData()
                }
                print("API DATA: \(articles)")
            case .failure(let error):
                print("API ERROR: \(error)")
            }
        }
        
        
    }
    

    

}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate{
    //Numero de items
    func tableView(_ tableViewNews: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    //Render das Cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! NewsTableViewCell
        cell.render(with: viewModelData[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "SearchToDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsNewsViewController{
            destination.article = viewModelData[(tableViewNews.indexPathForSelectedRow?.row)!]
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else{
            return
        }
        print(text)
        searchAndStore(textToSearch: text)
    }
    
}
