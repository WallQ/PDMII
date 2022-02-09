import UIKit
import CoreData

class DetailsNewsViewController: UIViewController {
    
    var article: NewsModel?
    private  var bookMarkToogle = false;
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var lblFonte: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblData: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnQrCode: UIButton!
    @IBOutlet weak var lblSummary: UITextView!    
    
    
    @IBAction func onClickBtnLike(_ sender: UIButton) {
        bookMarkToogle = !bookMarkToogle
        
        let request = NewsCoreData.fetchRequest() as NSFetchRequest<NewsCoreData>
        request.predicate = NSPredicate(format: "id == %i", self.article!.id)
        let findNews = try! self.context.fetch(request)
        
        if(findNews.isEmpty == false){
            let toUpdateNews = findNews[0] as NewsCoreData
            if(bookMarkToogle){
                print("Vou Colocar Favorito")
                btnLike.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
                toUpdateNews.fav = true
            }else{
                print("Retirei Favorito")
                btnLike.setImage(UIImage(systemName: "bookmark"), for: .normal)
                toUpdateNews.fav = false
            }
            
            try! self.context.save()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblFonte.text = article?.newsSite
        lblTitle.text = article?.title
        lblData.text = article?.updatedAt
        lblSummary.text = article?.summary
        lblData.text = String(self.article!.updatedAt.prefix(10))
        if(self.article?.fav ?? false){
            self.bookMarkToogle = true
            btnLike.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }else{
            self.bookMarkToogle = false
            btnLike.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        let url = URL(string: self.article!.imageUrl)!

        DispatchQueue.global(qos: .userInitiated).async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.image.image = UIImage(data: data)
                }
            }
        }
        print(article);

        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? QRCodeViewController{
            destination.newsID = self.article!.id
        }
    }
    

    

}
