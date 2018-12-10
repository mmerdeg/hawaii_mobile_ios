import Foundation

struct Allowance: Codable {
    let id: Int?
    let year: Int?
    let annual: Int?
    let takenAnnual: Int?
    let pendingAnnual: Int?
    let sickness: Int?
    let bonus: Int?
    let carriedOver: Int?
    let manualAdjust: Int?
    let training: Int?
    let pendingTraining: Int?
    let takenTraining: Int?
    
}

extension Allowance {
    init(allowance: Allowance? = nil, id: Int? = nil, year: Int? = nil,
         annual: Int? = nil, takenAnnual: Int? = nil, pendingAnnual: Int? = nil,
         sickness: Int? = nil, bonus: Int? = nil, carriedOver: Int? = nil, manualAdjust: Int? = nil,
         training: Int? = nil, pendingTraining: Int? = nil, takenTraining: Int? = nil) {
        self.id = id ?? allowance?.id
        self.year = year ?? allowance?.year
        self.annual = annual ?? allowance?.annual
        self.takenAnnual = takenAnnual ?? allowance?.takenAnnual
        self.pendingAnnual = pendingAnnual ?? allowance?.pendingAnnual
        self.sickness = sickness ?? allowance?.sickness
        self.bonus = bonus ?? allowance?.bonus
        self.carriedOver = carriedOver ?? allowance?.carriedOver
        self.manualAdjust = manualAdjust ?? allowance?.manualAdjust
        self.training = training ?? allowance?.training
        self.pendingTraining = pendingTraining ?? allowance?.pendingTraining
        self.takenTraining = takenTraining ?? allowance?.takenTraining
    }
}
