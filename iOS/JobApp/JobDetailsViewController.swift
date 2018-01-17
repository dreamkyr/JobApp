//
//  JobDetailsViewController.swift
//  JobApp
//
//  Created by JaonMicle on 22/06/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import UIKit
import Toaster
import Alamofire
import SwiftyJSON
import SDWebImage
import Kingfisher
import MessageUI

import QuickLook




class JobDetailsViewController: UIViewController, MFMailComposeViewControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate,QLPreviewControllerDelegate, QLPreviewControllerDataSource {

    private var job: Job! = nil;
    public var type: String = "FindJob"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var mainContentView: UIView!
    @IBOutlet weak var titleText: PlaceHolderTextField!
    @IBOutlet weak var employerNameText: PlaceHolderTextField!
    @IBOutlet weak var skillsText: PlaceHolderTextField!
    @IBOutlet weak var locationText: PlaceHolderTextField!
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var salaryText: PlaceHolderTextField!
    @IBOutlet weak var typeText: PlaceHolderTextField!
    @IBOutlet weak var contentText: UITextView!
    @IBOutlet weak var hremailorphoneText: PlaceHolderTextField!
    @IBOutlet weak var applyDlg: DialogView!
    @IBOutlet weak var profilePhoto: ExtentionImageView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    @IBOutlet weak var fileSizeLabel: UILabel!
    
    @IBOutlet weak var docView: UIStackView!
    @IBOutlet weak var docTypeImage: UIImageView!
    
    @IBOutlet weak var viewUnfavorite: UIView!
    
    var presentedItemURL: URL? = nil
    
    @IBAction func unselectResume(_ sender: Any) {
        docView.isHidden = true
        resumeButton.isHidden = false
        presentedItemURL = nil
    }
    
    @IBAction func previewDoc(_ sender: Any) {
        
        
        let preview = QLPreviewController()
        preview.delegate = self
        preview.dataSource = self
        if let parentController = self.parent as? UINavigationController {
            parentController.title = presentedItemURL?.lastPathComponent

            
            self.addChildViewController(preview)
            preview.view.frame = self.view.frame
            self.view.addSubview(preview.view)
            preview.didMove(toParentViewController: self)
        }
        else {
            self.present(preview, animated: true) { () -> Void in
                // do nothing
            }
        }
        
    }
    
    
    public var currentEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.job != nil{
            self.initView();
        }
        
        self.flagImage.layer.cornerRadius = self.flagImage.frame.size.width / 2
        self.flagImage.clipsToBounds = true
        
        docView.isHidden = true
        self.setDismissKeyboard()
    }
    
    public func setData(params: Any!){
        if params != nil{
            self.job = params as! Job
        }
    }
    
    public func initView(){
        self.employerNameText.text = CtrCommon.convertNiltoEmpty(string: self.job.employer_name, defaultstr: "")
        self.titleText.text = CtrCommon.convertNiltoEmpty(string: self.job.title, defaultstr: "")
        var skillStr = "";
        for skill in self.job.skills{
            skillStr += ", " + skill
        }
        self.skillsText.text = skillStr.substring(from: 1)
        self.locationText.text = CtrCommon.convertNiltoEmpty(string: self.job.country, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.job.state, defaultstr: "") + " " + CtrCommon.convertNiltoEmpty(string: self.job.city, defaultstr: "")
        if self.job.country != nil{
            if self.job.country != ""{
                self.flagImage.image = UIImage(named: "Frameworks/MICountryPicker.framework/assets.bundle/\(job.country!.components(separatedBy: "(")[1].components(separatedBy: ")")[0].lowercased())")
            }
            
        }
        self.salaryText.text = CtrCommon.convertNiltoEmpty(string: self.job.salary, defaultstr: "")
        self.typeText.text = CtrCommon.convertNiltoEmpty(string: self.job.type, defaultstr: "")
        self.contentText.text = CtrCommon.convertNiltoEmpty(string: self.job.description, defaultstr: "")
        self.hremailorphoneText.text = CtrCommon.convertNiltoEmpty(string: self.job.hremailorphone, defaultstr: "")
        if self.type != "FindJob"{
            self.viewUnfavorite.isHidden = false
            self.mainContentView.frame = CGRect(x: self.mainContentView.frame.origin.x, y: 0, width: self.mainContentView.frame.size.width, height: 670)
            self.mainScrollView.contentSize = CGSize(width: self.mainContentView.frame.size.width, height: self.mainContentView.frame.size.height)
        } else {
            self.viewUnfavorite.isHidden = true
            self.mainContentView.frame = CGRect(x: self.mainContentView.frame.origin.x, y: 0, width: self.mainContentView.frame.size.width, height: 780)
            self.mainScrollView.contentSize = CGSize(width: self.mainContentView.frame.size.width, height: self.mainContentView.frame.size.height)
        }
    }
    
    
    @IBAction func applyDlgCancelAction(_ sender: UIButton) {
        self.applyDlg.hide();
    }
    
    func getResumeData() -> Data? {
        do {
            if let urlok = self.presentedItemURL {
            let data = try Data(contentsOf: urlok)
                return data
            }else {
            return nil
            }
        } catch (let error) {
            print("🙅 \(error)")
            return nil
        }
    }
    
    func getResumeFileName() -> String? {
     
            if let urlok = self.presentedItemURL {
                let data =  fileNameFromUrl(url: urlok)
                return data
            }else {
                return nil
            }
    }
    
    func getResumeMimeType() -> String? {
    
        if let urlok = self.presentedItemURL {
            let ext = urlok.pathExtension
            
            switch ext {
            case "doc":
                return "application/msword"
            case "docx":
                return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            case "pdf":
                return "application/pdf"
            default:
                return nil
            }
            
            
        }else {
            return nil
        }
    
    }
    
    @IBAction func applyDlgOkAction(_ sender: UIButton) {
        var param: [String: Any] = [:]
        param["job_id"] = self.job.id
        let jsonParma = JSON(self.job.id);
        let jsonstrParma = jsonParma.rawString();
        CtrCommon.startRunProcess(viewController: self, completion: {
         // print(self.getResumeData())
           //  CtrCommon.stopRunProcess();
            
            JobsProvider.request(.jobProposeResume(job_id: jsonstrParma!.data(using: String.Encoding.utf8)!, resume: self.getResumeData(), filename: self.getResumeFileName(), type: self.getResumeMimeType()  ), queue: DispatchQueue.main,
                                 progress: { response in
                                    
            },
                                 completion: { result in
                                    CtrCommon.stopRunProcess();
                                    switch result {
                                    case .success(let response):
                                        
                                        let jsonData = JSON(response.data)
                                        if jsonData["code"].intValue == 200{
                                            AppCommon.instance.appliedJobs.append(self.job)
                                        }
                                        Toast(text: jsonData["message"].stringValue).show()

                                        
                                    case .failure(let error):
                                        Toast(text: error.localizedDescription).show()
                                    }
                                    
                                    
            } )
            
            /*
            Alamofire.request(Constant.JOB_APPLY_URL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON(completionHandler: { (response) in
                CtrCommon.stopRunProcess()
                switch response.result{
                case .success(let data):
                    let jsonData = JSON(data)
                    if jsonData["code"].intValue == 200{
                        AppCommon.instance.appliedJobs.append(self.job)
                    }
                    Toast(text: jsonData["message"].stringValue).show()
                    break;
                case .failure(let error):
                    Toast(text: error.localizedDescription).show()
                    break;
                }
            })*/
            
            
        })
        self.applyDlg.hide()
    }
    
    @IBAction func selectResume(_ sender: Any) {
      //  let menuVC = UIDocumentMenuViewController(documentTypes: ["public.content"], in: UIDocumentPickerMode.open)
       // self.present(menuVC, animated: false, completion: nil)
        
        let types: [Any]? = ["com.adobe.pdf", "com.microsoft.word.doc", "org.openxmlformats.wordprocessingml.document"]
        //Create a object of document picker view and set the mode to Import
        let docPicker = UIDocumentPickerViewController(documentTypes: types as! [String], in: .import)
        //Set the delegate
        docPicker.delegate = self
        //present the document picker
        present(docPicker, animated: true, completion: { _ in })
    }

    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    func fileNameFromUrl(url:URL) -> String {
        let rawLink = url.absoluteString
        let components = rawLink.components(separatedBy: "/")
        return (components.count >= 2) ? components.last!.removingPercentEncoding! : rawLink
    }
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.presentedItemURL! as QLPreviewItem
    }
    
    

    @available(iOS 4.0, *)
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        print(url)
        
        // present document here
        if self.presentedItemURL != nil {
            self.presentedItemURL!.stopAccessingSecurityScopedResource()
        }
        self.presentedItemURL = url
        
        let absString: String = url.absoluteString
        print(absString)
        let relString: String = url.relativeString
        print(relString)
        let relPath: String = url.relativePath
        print(relPath)
        let Path: String = url.path
        print(Path)
        
         let fileSize : UInt64 = sizeForLocalFilePath(filePath: Path)
        
        let ext = url.pathExtension
        
        switch ext {
        case "doc":
            docTypeImage.image = UIImage(named: "word")
        case "docx":
            docTypeImage.image = UIImage(named: "word")
        case "pdf":
            docTypeImage.image = UIImage(named: "pdf")
        default:
            print("no image")
        }
        
        print("\(ext) fileSize: \(fileSize) \(covertToFileString(with: fileSize)) \(fileNameFromUrl(url: url))")
        
        fileNameLabel.text = fileNameFromUrl(url: url)
        fileSizeLabel.text = covertToFileString(with: fileSize)
        
        docView.isHidden = false
        resumeButton.isHidden = true
        


        
    }
    

    
    func documentMenuWasCancelled(documentMenu: UIDocumentMenuViewController) {
         print("--- cancelled ---")
    }
    
    @IBAction func reviewProfile(_ sender: UIButton) {
        self.goto(to: Constant.PROFILESETTING_VC, params: nil)
    }
    
    @IBAction func addFavoriteAction(_ sender: UIButton) {
        if self.type == "FindJob"{
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_ADDFAVORITE_URL, method: .post, parameters: ["job_id": self.job.id], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data);
                        Toast(text: jsonData["message"].stringValue).show()
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                    }
                }
            })
        }else{
            let params: [String:Any] = ["job_id": self.job.id]
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_REMOVEFAVORITE_URL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        Toast(text: JSON(data)["message"].stringValue).show();
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                        break;
                    }
                }
            })

        }
    }
    
    @IBAction func shareAction(_ sender: UIButton) {
        if !AppCommon.instance.isShared(job: self.job){
            CtrCommon.startRunProcess(viewController: self, completion: {
                Alamofire.request(Constant.JOB_ADDSHARE_URL, method: .post, parameters: ["job_id": self.job.id], encoding: JSONEncoding.default, headers: ["Authorization": "Bearer \(SharedKeycard.token)"]).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data);
                        if jsonData["code"].intValue == 200{
                            AppCommon.instance.sharedJobs.append(self.job)
                        }
                        Toast(text: jsonData["message"].stringValue).show()
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                    }
                }
            })
        }else{
            Toast(text: "You shared already.").show()
        }
    }

    @IBAction func contactPhoneAction(_ sender: UIButton) {
        if self.hremailorphoneText.text!.isValidatePhone(){
            UIApplication.shared.openURL(NSURL(string: "tel://" + self.job.hremailorphone)! as URL)
        }else{
            Toast(text: "Phone number of HR doesn't exist").show()
        }
    }
    
    @IBAction func contactEmailAction(_ sender: UIButton) {
        if self.hremailorphoneText.text!.isValidEmail(){
            self.currentEmail = self.job.hremailorphone
            let mailComposeViewController = configureMailController()
            if MFMailComposeViewController.canSendMail(){
                self.present(mailComposeViewController, animated: false, completion: nil);
            }else{
                showMailError()
            }
        }else{
            Toast(text: "Email of HR doesn't exist").show()
        }
    }
    
    @IBAction func chatAction(_ sender: UIButton) {
        if AppCommon.instance.getChatList(id: self.job.referrer.user_id) != nil{
            self.goto(to: Constant.CHATS_VC, params: self.job.referrer)
        }else{
            CtrCommon.startRunProcess(viewController: self, completion: {
                
                
                //
                ChatlistProvider.request(.chatlistAdd(linked_users:  [self.job.referrer.user_id])) { result in
                    CtrCommon.stopRunProcess();
                    switch result {
                    case .success(let response):
                        let jsonData = JSON(response.data)
                        switch response.statusCode {
                        case 200:
                            
                            AppCommon.instance.chatLinkUsers = [];
                            for chatlistdata in jsonData["data"].arrayValue{
                                AppCommon.instance.chatLinkUsers.append(ChatList(chatlistdata.dictionaryObject!))
                            }
                            DispatchQueue.main.async {
                                self.goto(to: Constant.CHATS_VC, params: self.job.referrer)
                            }
                            
                        default:
                            Toast(text: jsonData["message"].stringValue).show()
                            return;
                        }
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show();
                    }
                }
                //
                /*
                Alamofire.request(Constant.ADDCHATLIST_URL, method: .post, parameters: ["linked_users": [self.job.referrer.user_id]], encoding: JSONEncoding.default).responseJSON { (response) in
                    CtrCommon.stopRunProcess();
                    switch response.result{
                    case .success(let data):
                        let jsonData = JSON(data)
                        if jsonData["code"].intValue == 200{
                            AppCommon.instance.chatLinkUsers = [];
                            for chatlistdata in jsonData["data"].arrayValue{
                                AppCommon.instance.chatLinkUsers.append(ChatList(chatlistdata.dictionaryObject!))
                            }
                            DispatchQueue.main.async {
                                self.goto(to: Constant.CHATS_VC, params: self.job.referrer)
                            }
                        }
                        break;
                    case .failure(let error):
                        Toast(text: error.localizedDescription).show()
                        break;
                    }
                }*/
                
                
            })
        }
    }
    
    @IBAction func applyAction(_ sender: UIButton) {
        if !AppCommon.instance.isApplied(job: self.job){
            if let urlStr = AppCommon.instance.profile.photo{
                if let url = URL(string: urlStr){
                    self.profilePhoto.sd_setImage(with: url)
                }
            }
            self.applyDlg.show();
        }else{
            Toast(text: "You applied already.").show()
        }
    }
    
    
    @IBAction func backAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //**************** email process *************//

    private func configureMailController()->MFMailComposeViewController{
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([self.currentEmail])
        mailComposerVC.setSubject("")
        mailComposerVC.setMessageBody("", isHTML: false)

        return mailComposerVC
    }

    private func showMailError(){
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }
    //***********//

    public func goto(to : String, params: Any!){
        DispatchQueue.main.async {
            if to == Constant.CHATS_VC{
                let toVc: UINavigationController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: to) as! UINavigationController
                let chatVc: ChatsViewController = toVc.viewControllers.first as! ChatsViewController
                chatVc.setChatUsers(user: (params as! Profile))
                self.present(toVc, animated: true, completion: nil)
            }else if to == Constant.PROFILESETTING_VC{
                let toVc: ProfileSettingViewController = UIStoryboard(name: "ProfileSetting", bundle: nil).instantiateViewController(withIdentifier: to) as! ProfileSettingViewController;
                self.present(toVc, animated: true, completion: nil);
            }
        }
    }
    
}

extension JobDetailsViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
}
