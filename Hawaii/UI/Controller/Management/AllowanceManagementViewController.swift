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
        self.createForm(allowances)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateUser()
        guard let user = user else {
            return
        }
        updateAllowanceDelegate?.didUpdateAllowance(user: user)
    }
    
    func createForm(_ allowances: [Allowance]) {
        var sections: [Section] = []
        
        for allowance in allowances {
            
            guard let year = allowance.year,
                let annual = allowance.annual,
                let manual = allowance.manualAdjust else {
                    return
            }
            sections.append(Section(String(year)) {
                $0 <<< self.createAnnualRow(year, annual)
                $0 <<< self.createManualAdjustRow(year, manual, annual)
                $0 <<< self.createSumRow(year, annual + manual)
            })
        }
        sections.forEach({ section in
            form.append(section)
        })
    }
    
    func createAnnualRow(_ year: Int, _ annual: Int) -> LabelRow {
        return LabelRow {
            $0.value = String(annual)
            $0.tag = LocalizedKeys.UserManagement.annual.localized() + String(year)
            $0.title = LocalizedKeys.UserManagement.annual.localized()
        }.cellSetup({ cell, _ in
            self.cellSetup(cell: cell)
        }).cellUpdate({ cell, _ in
            self.cellSetup(cell: cell)
        })
    }
    
    func createManualAdjustRow(_ year: Int, _ manual: Int, _ annual: Int) -> StepperRow {
        return StepperRow {
            $0.value = Double(manual)
            $0.tag = LocalizedKeys.UserManagement.manual.localized() + String(year)
            $0.title = LocalizedKeys.UserManagement.manual.localized()
            $0.add(rule: RuleRequired())
            $0.cell.stepper.minimumValue = Double(0 - annual)
            $0.cell.stepper.maximumValue = 1000.0
            $0.validationOptions = .validatesOnChange
        }.cellSetup({ cell, row in
            self.cellSetup(cell: cell)
            cell.valueLabel?.text = "\(Int(row.value ?? 0))"
        }).cellUpdate({ cell, row in
            self.cellSetup(cell: cell)
            cell.valueLabel?.text = "\(Int(row.value ?? 0))"
                
            guard let sumRow = self.form.rowBy(tag: LocalizedKeys.UserManagement.sum.localized()
                + String(year)) as? IntRow else {
                    return
            }
            sumRow.value = annual + Int(row.value ?? 0)
            sumRow.reload()
        })
    }
    
    func createSumRow(_ year: Int, _ sum: Int) -> IntRow {
        return IntRow {
            $0.value = sum
            $0.tag = LocalizedKeys.UserManagement.sum.localized() + String(year)
            $0.title = LocalizedKeys.UserManagement.sum.localized()
            $0.disabled = true
            $0.validationOptions = .validatesOnChange
        }.cellSetup({ cell, row in
            self.setIntInput(cell: cell, row: row)
        }).cellUpdate({ cell, row in
            self.setIntInput(cell: cell, row: row)
        })
    }
    
    func cellSetup(cell: BaseCell) {
        cell.backgroundColor = UIColor.primaryColor
        cell.textLabel?.textColor = UIColor.primaryTextColor
        cell.tintColor = UIColor.primaryTextColor
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
                let newManual = formValues[LocalizedKeys.UserManagement.manual.localized()
                    + String(year)] as? Double else {
                return
            }
            newAllowances.append(Allowance(allowance: allowance, manualAdjust: Int(newManual)))
        }
        self.user = User(user: user, allowances: newAllowances)
    }
}
