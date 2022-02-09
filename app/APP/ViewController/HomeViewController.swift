import UIKit
import CoreData
import UserNotifications
import AVFoundation

class HomeViewController: UIViewController{
    let refreshController = UIRefreshControl()
    
    
    @IBAction func btnScan(_ sender: UIButton) {
        print("Entrei no SCAN")
        verifyAutorizationStatus()
    }
    @objc func refresh(){
        updateCoreData()
        tableViewNews.reloadData()
        refreshController.endRefreshing()
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    @IBOutlet weak var tableViewNews: UITableView!
    
    //Variaveis para a camara
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    
    var myData = [NewsModel]()
    private var viewModelData = [NewsModel]()
    
    let cellReuseIdentifier = "NewsTableViewCell";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Notifications
        handlePermissionForNotification()
        scheduleNotification()
        
        
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewNews.addSubview(refreshController)

        tableViewNews.register(UINib(nibName: cellReuseIdentifier, bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableViewNews.delegate = self
        tableViewNews.dataSource = self
        tableViewNews.allowsSelection = true
        
        fetchData()
                                        
    }
    
    
    func fetchData(){
        do {
            let request = NewsCoreData.fetchRequest() as NSFetchRequest<NewsCoreData>
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
                self!.fetchData()
                //self!.fecthNews()
            case .failure(let error):
                print("API ERROR: \(error)")
            }
        }
    }
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Title"
        content.body = "Body!"
        
        //Fire in 90 sec
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        //create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        //Schedule the request whith the system
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request){ (error) in
            if error != nil{
                print("error on notification")
            }
            print("notification add ok")
            
        }
    }
    
    func handlePermissionForNotification(){
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge, .provisional]) { (granted, error) in
            if let error = error {
                print(error)
            }
            print("Tenho permissoes?: \(granted)")
        }
    
    }
    
    func verifyAutorizationStatus(){
        switch AVCaptureDevice.authorizationStatus(for: .video){
        case .authorized:
            self.setupCaptureSession()
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if(granted){
                    print("Tenho permissoes para a camara")
                    self.setupCaptureSession()
                }
            }
        case .denied:
            return
            
        case.restricted:
            return
        
        @unknown default:
            print("Unexpected authorization status found")
        }
    }
    
    func setupCaptureSession(){
        self.setupCaptureDeviceInput()
        self.setupCaptureDeviceOutput()
        self.initialVideoPreview()
        
        //move the message lable and topbar to de front
        //view.bringSubviewToFront()
        //view.bringSubviewToFront(topbar)
        
        return
    }
    
    func setupCaptureDeviceInput(){
        let deviceDescoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDescoverySession.devices.first
        else{
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch{
            print(error)
            return
        }
    }
    func setupCaptureDeviceOutput(){
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
    func initialVideoPreview(){
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer!)
        
        captureSession.startRunning()
    }
    
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate, AVCaptureMetadataOutputObjectsDelegate{
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
        performSegue(withIdentifier: "HomeToDetailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailsNewsViewController{
            destination.article = viewModelData[(tableViewNews.indexPathForSelectedRow?.row)!]
        }
    }
    
    //Camara
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            //no QR code is detected
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr{
            let barcodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barcodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                print(metadataObj.stringValue)
            }
        }
    }
    
}

