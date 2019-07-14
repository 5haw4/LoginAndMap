//
//  RegisterViewController.swift
//  LoginAndMap
//
//  Created by shawn on 04/07/2018.
//  Copyright © 2018 Shawn. All rights reserved.
//

import UIKit
import GoogleMaps

class RegisterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btn_register: UIButton!
    //using this constraint to adjust the off set of the button so the keyboard won't hide it
    @IBOutlet weak var constraint_btn_register: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_age: UILabel!
    var ageSelected = 0
    let agePickerView: UIPickerView = UIPickerView()
    
    @IBOutlet weak var lbl_profession: UILabel!
    var professionSelected = "-"
    var professionTableView = UITableView()

    @IBOutlet weak var lbl_first_name: UILabel!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lbl_last_name: UILabel!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var lbl_email: UILabel!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var btn_help: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setAgePickerData()

        //using notification for keyboard to get the height of the keyboard and adjust the off set of the registration button so the keyboard won't cover it
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil)
        //using to know when the keyboard closes in order to reset the off set of the button
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardNotification),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil)
        
        //detecting changes in TextFields
        firstNameTF.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)
        lastNameTF.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)
        emailTF.addTarget(self, action: "textFieldDidChange:", for: UIControlEvents.editingChanged)

    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            if !isKeyboardShowing {
                //keyboard closed - reseting off set
                constraint_btn_register?.constant = 0
            } else {
                //keyboard opened - setting off set the same size of the keyboard so it won't cover the "register" button
                constraint_btn_register?.constant = keyboardFrame!.height
            }
            //animating the change of the constraint (the movement of the button upwards with the keyboard)
            UIView.animate(withDuration: 0,
                           delay: 0,
                           options: UIViewAnimationOptions.curveEaseOut,
                           animations: { self.view.layoutIfNeeded() },
                           completion: {(completed) in })
        }
    }
    
    //hide keyboard when user click the "return" key
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // after the user clicks on the age button - setting up alert and adding to it the age picker
    @IBAction func btn_age(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select Your Age:", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.alert)

        self.agePickerView.frame = CGRect(x: 0,y: 50,width: 270,height: 162)
        self.agePickerView.dataSource = self
        self.agePickerView.delegate = self
        self.agePickerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)

        
        alert.addAction(UIAlertAction(title: "OK", style:  UIAlertActionStyle.default, handler: { action in
            if self.ageSelected != 0 && self.ageSelected > 17 && self.ageSelected < 81 {
                self.lbl_age.text = "\(self.ageSelected) Years Old"
            } else {
                self.lbl_age.text = "-"
            }
            self.checkTextFieldsAndLabels()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alert.view.addSubview(agePickerView)

        self.present(alert, animated: true, completion: {
            self.agePickerView.frame.size.width = alert.view.frame.size.width
        })
        
    }
    
    //##### Beginning of UIPickerView functions #####//
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    var agePickerArray = [Int]()
    func setAgePickerData() {
        for i in 17...80 {
            agePickerArray.append(i)
        }
    
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return agePickerArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "-"
        } else {
        return "\(agePickerArray[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ageSelected = agePickerArray[row]
    }
    
    //##### End of UIPickerView functions #####//
    
    
    
    //after the user clicks the "select profession" button - setting up and showing alert with table view containing professions
    @IBAction func btn_profession(_ sender: Any) {
        
        let alert = UIAlertController(title: "Select Your Profession:", message: "\n\n\n\n\n\n\n\n\n", preferredStyle: UIAlertControllerStyle.alert)
        self.professionTableView.frame = CGRect(x: 0,y: 50,width: 270,height: 162)
        self.professionTableView.dataSource = self
        self.professionTableView.delegate = self
        self.professionTableView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        
        alert.addAction(UIAlertAction(title: "OK", style:  UIAlertActionStyle.default, handler: { action in
            //checking if the user selected a profession from the table view
            if self.professionSelected != "-" {
                self.lbl_profession.text = self.professionSelected
            } else {
                self.lbl_profession.text = "-"
            }
            self.checkTextFieldsAndLabels()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        //adding the table view to to teh alert as subview
        alert.view.addSubview(self.professionTableView)
        
        self.present(alert, animated: true, completion: {
            self.professionTableView.frame.size.width = alert.view.frame.size.width
        })
        
    }
    //##### Beginning of profession TableView funcs #####//
    var professionArray = ["IOS Developer","Android Developer", "C# Developer", "Java Developer", "Web Designer", "Unity Developer", "Blender 3D Designer", "PHP Developer"]
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return professionArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = professionArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        professionSelected = professionArray[indexPath.row]
    }
    //##### End of profession TableView funcs #####//

    //checking if the user enters currect info every time there's a change in the text in any TextField
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkTextFieldsAndLabels()
    }
    
    
    func checkTextFieldsAndLabels() -> String {
        var error = ""
        //checking to see if the text the user entered is valid to the First Name and Last name use
        error += checkString(textField: firstNameTF, fieldName: "First Name")
        error += checkString(textField: lastNameTF, fieldName: "Last Name")
        
        //checking email validity
        
        let textEmail = emailTF.text
        
        var atCount = 0
        for c in textEmail! {
            if c == "@" { atCount += 1 }
        }
        if !(textEmail?.contains("@"))! ||
            !(textEmail?.contains("."))! ||
            (textEmail?.contains("#"))! ||
            (textEmail?.contains(" "))! ||
            (textEmail?.contains("'"))! ||
            atCount > 1 {
            //invalid email address
            error += "Invalid Email address.\n"
            lbl_email.textColor = UIColor.red
        } else {
            lbl_email.textColor = UIColor.black
        }
        
        //changing lbls color to red if there's still something wrong with the user's inserted text so they will know to change it
        
        if lbl_age.text == "-" {
            //age not selected
            error += "Select Your Age.\n"
            lbl_age.textColor = UIColor.red
        } else {
            //age selected
            lbl_age.textColor = UIColor.black
        }
        
        if lbl_profession.text == "-" {
            //profession not selected
            error += "Select Your Profession.\n"
            lbl_profession.textColor = UIColor.red
        } else {
            //profession selected
            lbl_profession.textColor = UIColor.black
        }
        
        //enabling the register button if all's good and disabling if not
        //also showing "help" button that on click will show alert with explanations regarding the insterted text's error/s
        if error != "" {
            btn_help.isHidden = false
            btn_register.isEnabled = false
        } else {
            btn_help.isHidden = true
            btn_register.isEnabled = true
        }
        //returning error:String to show in the "help" alert after clicking the "help" button (if there are no errors it will be "")
        return error
    }
    //checking the validity of the text field and returning error:String if there are any
    func checkString(textField: UITextField, fieldName: String) -> String {
        var error = ""
        let text:String = textField.text!
        var wordsCount = 0
        for c in Array(text) {
            if c == " " { wordsCount += 1 }
        }
        if wordsCount > 1 {
            //not allowed - can use up to 2 words
            error += "Use up to 2 words in your \(fieldName).\n"
        }
        if text.count < 2 {
            //not allowed - need more letters
            error += "Use 2 or more letters in your \(fieldName).\n"
        }
        
        var color:UIColor = UIColor()
        if error == "" {
            color = UIColor.black
        } else {
            color = UIColor.red
        }
        
        switch fieldName {
        case "First Name":
            lbl_first_name.textColor = color
            break
        default:
            lbl_last_name.textColor = color
            break
        }

        
        return error
    }

    //showing alert with explanation to the user what TextFields they filled up wrong
    @IBAction func btn_help(_ sender: Any) {
        let error = checkTextFieldsAndLabels()
        if error != "" {
            let alert = UIAlertController(title: "Error:", message: "\n" + error, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
}
