import Foundation

public struct LocalizedKeys {
    
    struct General {
        static let errorTitle = "general.alert.errorTitle"
        static let cancel = "general.alert.cancel"
        static let ok = "general.alert.ok"
    }

    struct Request {
        static let pending = "request.status.pending"
        static let approved = "request.status.approved"
        static let rejected = "request.status.rejected"
        static let canceled = "request.status.canceled"
        static let cancelationPending = "request.status.cancelationPending"
        static let fullDay = "request.duration.fullDay"
        static let morning = "request.duration.morning"
        static let afternoon = "request.duration.afternoon"
        static let afternoonFirst = "request.duration.afternoonFirst"
        static let morningLast = "request.duration.morningLast"
        static let morningAndAfternoon = "request.duration.morningAndAfternoon"
        static let leaveType = "request.table.leaveType"
        static let sicknessType = "request.table.sicknessType"
        static let duration = "request.table.duration"
        static let startDate = "request.startDate"
        static let endDate = "request.endDate"
        static let reasonPlaceholder = "request.reasonPlaceholder"
        static let leaveRequest = "request.leaveRequest"
        static let sicknessRequest = "request.sicknessRequest"
        static let bonusRequest = "request.bonusRequest"
        static let leave = "request.leave"
        static let sickness = "request.sickness"
        static let bonus = "request.bonus"
    }
    
    struct Api {
        static let tooManyDays = "api.response.tooManyDays"
        static let alreadyExists = "api.response.alreadyExists"
    }
    
    struct RemainingDays {
        static let taken = "remainingDays.taken"
        static let pending = "remainingDays.pending"
        static let remaining = "remainingDays.remainig"
        static let days = "remainingDays.days"
        static let leave = "remainingDays.leave"
        static let training = "remainingDays.training"
    }
    
    struct Summary {
        static let datesRequested = "summary.datesRequested"
        static let leaveRequested = "summary.leaveRequested"
        static let leaveRemaining = "summary.leaveRemaining"
        static let leaveType = "summary.leavetype"
        static let reason = "summary.reason"
        static let submit = "summary.submit"
    }
    
    struct Filter {
        static let year = "filter.year"
        static let filter = "filter.filter"
    }
    
    struct Dashboard {
        static let title = "dashboard.title"
    }
    
    struct History {
        static let title = "history.title"
    }
    
    struct Team {
        static let title = "team.title"
        static let tabItemTitle = "team.tabItemTitle"
    }
    
    struct Approval {
        static let title = "approval.title"
        static let tabItemTitle = "approval.tabItemTitle"
    }
    
    struct More {
        static let title = "more.title"
        static let signOut = "more.signOut"
    }
}
