import UIKit
import CoreData

class BookMarksViewController: UIViewController {

    @IBOutlet weak var tableViewNews: UITableView!
    
    let refreshController = UIRefreshControl()
    
    
    @objc func refresh(){
        fetchData()
        tableViewNews.reloadData()
        refreshController.endRefreshing()
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private var viewModelData = [NewsModel]()
    
    let cellReuseIdentifier = "NewsTableViewCell";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewNews.addSubview(refreshController)
        
        tableViewNews.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableViewNews.delegate = self
        tableViewNews.dataSource = self
        tableViewNews.allowsSelection = true

        //Get Data From Core data dos dados que estao nos favoritos
        fetchData()
    }
    
    func fetchData(){
        do {
            let request = NewsCoreData.fetchRequest() as NSFetchRequest<NewsCoreData>
            request.predicate = NSPredicate(format: "fav == %@", NSNumber(value: true))
            let fetchedData = try context.fetch(request)
            self.viewModelData = fetchedData.compactMap({
    
                NewsModel(
                    id: $0.id,
                    title: $0.title!,
                    url: $0.url!,
                    imageUrl: $0.imageUrl!,
                    newsSite: $0.newsSite!,
                    summary: $0.summary!,
                    publishedAt: $0.publishedAt,
                    updatedAt: $0.updatedAt!,
                    fav: $0.fav
                    )
            })
            
            DispatchQueue.main.async {
                self.tableViewNews.reloadData()
            }
        }
        catch {
            print("Error Geting Core data")
        }
    }
    
}

extension BookMarksViewController: UITableViewDelegate, UITableViewDataSource{
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
        //cell.lblTitle.text = "asdasdsadas"
        //cell.textLabel?.text = myData[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "BookMarksToDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsNewsViewController{
            destination.article = viewModelData[(tableViewNews.indexPathForSelectedRow?.row)!]
        }
    }
    
}

