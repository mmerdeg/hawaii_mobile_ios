import Foundation

public struct LocalizedKeys {
    
    struct General {
        static let errorTitle = "general.alert.errorTitle"
        static let cancel = "general.alert.cancel"
        static let ok = "general.alert.ok"
        static let yes = "general.alert.yes"
        static let no = "general.alert.no"
        static let trickMessage = "general.alert.trickMessage"
        static let reasonRequired = "general.alert.reasonRequired"
        static let cancelRequestMessage = "general.alert.cancelRequestMessage"
        static let canceledRequestMessage = "general.alert.canceledRequestMessage"
        static let approveRequestMessage = "general.alert.approveRequestMessage"
        static let approvedRequestMessage = "general.alert.approvedRequestMessage"
        static let rejectRequestMessage = "general.alert.rejectRequestMessage"
        static let rejectedRequestMessage = "general.alert.rejectedRequestMessage"
        static let approve = "general.approve"
        static let reject = "general.reject"
        static let wait = "general.wait"
        static let next = "general.next"
        static let newRequestMenu = "general.newRequestMenu"
        static let success = "general.success"
        static let confirm = "general.confirm"
        static let refresh = "general.refresh"
        static let signIn = "general.signIn"
        static let close = "general.close"
        static let back = "general.back"
        static let accept = "general.accept"
        static let decline = "general.decline"
        static let emptyToken = "general.emptyToken"
        static let equalToken = "general.equalToken"
        static let deleteMessage = "general.alert.deleteMessage"
        static let delete = "general.delete"
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
        static let notes = "request.notes"
        static let date = "request.date"
        static let cancelationPendingDescription = "request.cancelationPendingDescription"
        static let addMessage = "request.addMessage"
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
        static let days = "summary.days"
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
        static let segmentAll = "history.segmentAll"
        static let emptyTitle = "history.emptyTitle"
        static let emptyDescription = "history.emptyDescription"
    }
    
    struct Team {
        static let title = "team.title"
        static let tabItemTitle = "team.tabItemTitle"
        static let loadMore = "team.loadMore"
        static let loadingMore = "team.loadingMore"
        static let searchTitle = "team.searchTitle"
        static let segmentAll = "team.segmentAll"
        static let segmentTeam = "team.segmentTeam"
        static let segmentPerson = "team.segmentPerson"
        static let emptyTitle = "team.emptyTitle"
        static let emptyDescription = "team.emptyDescription"
    }
    
    struct Approval {
        static let title = "approval.title"
        static let tabItemTitle = "approval.tabItemTitle"
        static let emptyTitle = "approval.emptyTitle"
        static let emptyDescription = "approval.emptyDescription"
    }
    
    struct More {
        static let title = "more.title"
        static let signOut = "more.signOut"
        static let manageUsers = "more.manageUsers"
        static let manageTeams = "more.manageTeams"
        static let manageHolidays = "more.manageHolidays"
        static let manageLeaveProfiles = "more.manageLeaveProfiles"
        static let manageDevices = "more.manageDevices"
        static let theme = "more.theme"
        static let tokenScreenTitle = "more.tokenScreenTitle"
    }
    
    struct TeamManagement {
        static let nameTitle = "teamManagement.nameTitle"
        static let namePlaceholder = "teamManagement.namePlaceholder"
        static let emailTitle = "teamManagement.emailTitle"
        static let emailPlaceholder = "teamManagement.emailPlaceholder"
        static let deletedEnabled = "teamManagement.deletedEnabled"
        static let deletedDisabled = "teamManagement.deletedDisabled"
        static let teamApproverTitle = "teamManagement.teamApproverTitle"
        static let teamApproverPlaceholder = "teamManagement.teamApproverPlaceholder"
    }
    
    struct UserManagement {
        static let fullNameTitle = "userManagement.fullNameTitle"
        static let fullNamePlaceholder = "userManagement.fullNamePlaceholder"
        static let emailTitle = "userManagement.emailTitle"
        static let emailPlaceholder = "userManagement.emailPlaceholder"
        static let deletedEnabled = "userManagement.deletedEnabled"
        static let deletedDisabled = "userManagement.deletedDisabled"
        static let activeEnabled = "userManagement.activeEnabled"
        static let activeDisabled = "userManagement.activeDisabled"
        static let jobTitleTitle = "userManagement.jobTitleTitle"
        static let jobTitlePlaceholder = "userManagement.jobTitlePlaceholder"
        static let userRoleTitle = "userManagement.userRoleTitle"
        static let userRolePlaceholder = "userManagement.userRolePlaceholder"
        static let yearsOfServiceTitle = "userManagement.yearsOfServiceTitle"
        static let yearsOfServicePlaceholder = "userManagement.yearsOfServicePlaceholder"
        static let teamTitle = "userManagement.teamTitle"
        static let teamPlaceholder = "userManagement.teamPlaceholder"
        static let leaveProfileTitle = "userManagement.leaveProfileTitle"
        static let leaveProfilePlaceholder = "userManagement.leaveProfilePlaceholder"
        static let basicSection = "userManagement.basicSection"
        static let additionalSection = "userManagement.additionalSection"
        static let companySection = "userManagement.companySection"
        static let allowance = "userManagement.allowance"
        static let allowancePlaceholder = "userManagement.allowancePlaceholder"
        static let annual = "userManagement.annual"
        static let manual = "userManagement.manual"
        static let sum = "userManagement.sum"
    }
    
    struct Token {
        static let deviceName = "token.deviceName"
        static let notificationToken = "token.notificationToken"
        static let platform = "token.platform"
        static let createdDate = "token.createdDate"
        
    }
    
    struct HolidayManagement {
        static let infoSection = "holiday.infoSection"
        static let nameTitle = "holiday.nameTitle"
        static let namePlaceholder = "holiday.namePlaceholder"
        static let date = "holiday.date"
        static let deletedEnabled = "userManagement.deletedEnabled"
        static let deletedDisabled = "userManagement.deletedDisabled"
    }
    
    struct LeaveProfileManagement {
        static let infoSection = "leaveProfile.infoSection"
        static let nameTitle = "leaveProfile.nameTitle"
        static let namePlaceholder = "leaveProfile.namePlaceholder"
        static let commentTitle = "leaveProfile.commentTitle"
        static let commentPlaceholder = "leaveProfile.commentPlaceholder"
        static let entitlement = "leaveProfile.entitlement"
        static let maxBonusDays = "leaveProfile.maxBonusDays"
        static let maxCarriedOver = "leaveProfile.maxCarriedOver"
        static let training = "leaveProfile.training"
    }
}
