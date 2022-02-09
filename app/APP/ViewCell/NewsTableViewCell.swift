import UIKit
import CoreData


class NewsTableViewCell: UITableViewCell {
    var bookMarkToogle = false;
    var data : NewsModel?;
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var lblFont: UILabel!
    @IBOutlet weak var lblTitle: UITextView!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var lblData: UILabel!

    
    @IBAction func onClickLike(_ sender: Any) {
        bookMarkToogle = !bookMarkToogle
        print(self.data!)
        let request = NewsCoreData.fetchRequest() as NSFetchRequest<NewsCoreData>
        request.predicate = NSPredicate(format: "id == %i", self.data!.id)
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgCover.layer.cornerRadius = 20
        imgCover.clipsToBounds = true
        
        // Create URL
        
        // Initialization code
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func render (with viewModel: NewsModel){
        //print("View MODEL DATA\(viewModel)")
        self.data = viewModel
        lblFont.text = viewModel.summary
        lblTitle.text = viewModel.title
        if((viewModel.fav ?? false)){
            self.bookMarkToogle = true
            btnLike.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        }else{
            self.bookMarkToogle = false
            btnLike.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        
        //let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "dd-MM-yyyy"
        //let date = dateFormatter.date(from: viewModel.publishedAt)
        
        //print("View MODEL DATA\(date)")
        //if(date != nil){
            //lblData.text = dateFormatter.string(from: date ?? Date())
        //}
        
        lblData.text = String(viewModel.updatedAt.prefix(10))
        
        
        let url = URL(string: viewModel.imageUrl)!

        DispatchQueue.global(qos: .userInitiated).async {
            // Fetch Image Data
            if let data = try? Data(contentsOf: url) {
                DispatchQueue.main.async {
                    // Create Image and Update Image View
                    self.imgCover.image = UIImage(data: data)
                }
            }
        }
        //btnLike: UIButton!
        //lblData: UILabel!
    }
    
    func getImage( img: String){
        let url = URL(string: img)!

        DispatchQueue.global(qos: .userInitiated).async {
                // Fetch Image Data
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        // Create Image and Update Image View
                        self.imgCover.image = UIImage(data: data)
                    }
                }
            }
    }
    
}
