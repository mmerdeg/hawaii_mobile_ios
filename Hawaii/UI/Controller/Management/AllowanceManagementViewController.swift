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
        
        guard let allowances = user?.allowances else {
            return
        }
        
        var sections: [Section] = []
        
        for allowance in allowances {
            guard let year = allowance.year,
                let annual = allowance.annual,
                let training = allowance.training else {
                    return
            }
            
            sections.append(Section(String(year)) {
                $0 <<< IntRow("annual" + String(year)) {
                    $0.value = annual
                    $0.tag = LocalizedKeys.UserManagement.annual.localized() + String(year)
                    $0.title = LocalizedKeys.UserManagement.annual.localized()
                    $0.placeholder = LocalizedKeys.UserManagement.allowancePlaceholder.localized()
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                }.cellSetup({ cell, row in
                    self.setIntInput(cell: cell, row: row)
                }).cellUpdate({ cell, row in
                    self.setIntInput(cell: cell, row: row)
                })
                
                $0 <<< IntRow("training") {
                    $0.value = training
                    $0.tag = LocalizedKeys.RemainingDays.training.localized() + String(year)
                    $0.title = LocalizedKeys.RemainingDays.training.localized()
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
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
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
                let newAnnual = formValues["annual" + String(year)] as? Int,
                let newTraining = formValues["training" + String(year)] as? Int else {
                return
            }
            
            newAllowances.append(Allowance(allowance: allowance,
                                        annual: newAnnual,
                                        training: newTraining))
        }
        
        self.user = User(user: user, allowances: newAllowances)
    }
}
