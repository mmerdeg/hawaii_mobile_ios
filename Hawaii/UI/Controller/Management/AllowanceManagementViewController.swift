import Foundation
import Eureka

protocol UpdateAllowanceProtocol: class {
    func didUpdateAllowance(user: User)
}

class AllowanceManagementViewController: BaseFormViewController {
    
    var user: User?
    
    weak var updateAllowanceDelegate: UpdateAllowanceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = LocalizedKeys.UserManagement.allowance.localized()
        self.tableView.backgroundColor = UIColor.darkPrimaryColor

        guard let allowances = user?.allowances else {
            return
        }
        
        var sections: [Section] = []
        
        for allowance in allowances {
            guard let year = allowance.year,
                let annual = allowance.annual,
                let manual = allowance.manualAdjust else {
                    return
            }
            
            sections.append(Section(String(year)) {
                $0 <<< LabelRow("annual" + String(year)) {
                    $0.value = String(annual)
                    $0.tag = LocalizedKeys.UserManagement.annual.localized() + String(year)
                    $0.title = LocalizedKeys.UserManagement.annual.localized()
                }
                
                $0 <<< IntRow("manual" + String(year)) {
                    $0.value = manual
                    $0.tag = LocalizedKeys.UserManagement.manual.localized() + String(year)
                    $0.title = LocalizedKeys.UserManagement.manual.localized()
                    $0.placeholder = LocalizedKeys.UserManagement.allowancePlaceholder.localized()
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
                }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
                })

            })
        }
        
        sections.forEach({ section in
            form.append(section)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateUser()
        guard let user = user else {
            return
        }
        updateAllowanceDelegate?.didUpdateAllowance(user: user)
    }
    
    func updateUser() {
        guard let user = user,
        let userAllowances = user.allowances else {
            return
        }

        let formValues = self.form.values()
        var newAllowances: [Allowance] = []
        
        for allowance in userAllowances {
            guard let year = allowance.year,
                let newManual = formValues[LocalizedKeys.UserManagement.manual.localized() + String(year)] as? Int else {
                return
            }
            
            newAllowances.append(Allowance(allowance: allowance,
                                        manualAdjust: newManual))
        }
        
        self.user = User(user: user, allowances: newAllowances)
    }
}
