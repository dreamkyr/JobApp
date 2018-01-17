//
//  Constant.swift
//  shot_doctor
//
//  Created by Admin on 2017/05/06.
//  Copyright © 2017 BenzCruise. All rights reserved.
//

import Foundation

public class Constant{
    private static let PROTOCOL = "http"
    open static let SERVER_ADDR = "192.81.208.232"
    
//    open static let SERVER_ADDR = "127.0.0.1"
    private static let SERVER_PORT = "8080"
    private static let SERVICIES = "job_admin/api"
    
//    public static let MQTTSERVER_ADDR = "67.205.128.231"
    public static let MQTTSERVER_ADDR = "192.81.208.232"
    public static let MQTTSERVERNOTI_PORT = 1884
    public static let MQTTSERVERCHAT_PORT = 1883
    public static let MQTTNOTI_TOPIC_PREFIX = "jobapp/notification/client/"
    public static let MQTTCHAT_TOPIC_PREFIX = "jobapp/chatting/client/"
    public static let MQTTNOTI_CONTACT = "contact"
    public static let MQTTNOTI_JOBAWARD = "job_award"
    public static let MQTTNOTI_JOBPOSTED = "job_posted"
    public static let MQTTNOTI_CHAT = "chatting"
    public static let MQTTNOTI_JOBSHARED = "job_shared"
    
    public static let FILEUPLOAD_URL = getServerURL() + "upload"
    
    
    
    public static let LOGIN_URL = getServerURL() + "user/login"
    public static let SIGNUP_URL = getServerURL() + "user/signup"
    public static let FORGOTENPASS_URL = getServerURL() + "user/forgotten"
    public static let RESETPASS_URL = getServerURL() + "user/resetpassword"
    public static let PROFILE_UPDATE_URL = getServerURL() + "user/update"
    public static let PROFILEWITHPHOTO_UPDATE_URL = getServerURL() + "user/updatewithphoto"
    
    public static let PROFILE_GET_URL = getServerURL() + "user/get"
    public static let ADD_CONTACT_URL = getServerURL() + "contact/add"
    public static let GET_CONTACTS_URL = getServerURL() + "contact/get"
    public static let ADD_CONTACTS_URL = getServerURL() + "contact/add"
    public static let AGREE_CONTACTS_URL = getServerURL() + "contact/agree"
    public static let SEARCH_CONTACTS_URL = getServerURL() + "user/search"
    public static let DISPLAY_SETTING_URL = getServerURL() + "contact/share"
    
    
    public static let SKILL_GET_URL = getServerURL() + "skill/get"
    public static let ADD_JOB_URL = getServerURL() + "job/add"
    public static let JOB_MY_POSTED = getServerURL() + "job/mypost"
    public static let JOB_REMOVE_URL = getServerURL() + "job/delete"
    public static let JOB_GETBYID_URL = getServerURL() + "job/get"
    public static let JOB_USER_URL = getServerURL() + "job/user"
    public static let JOB_SEARCH_URL = getServerURL() + "job/search"
    public static let JOB_GETBYPOSTEDDATE_URL = getServerURL() + "job/posteddate"
    public static let JOB_PROPOSED_URL = getServerURL() + "job/proposed"
    public static let JOB_USERPOSTED_URL = getServerURL() + "job/user"
    public static let JOB_CURRENT_URL = getServerURL() + "job/current"
    public static let JOB_PASSED_URL = getServerURL() + "job/passed"
    public static let JOB_APPLY_URL = getServerURL() + "job/addpropose"
    public static let JOB_REMOVEAPPLY_URL = getServerURL() + "job/removepropose"
    public static let JOB_AWARD_URL = getServerURL() + "job/addaward"
    public static let JOB_RECENT_URL = getServerURL() + "job/recent"
    public static let JOB_ADDSHARE_URL = getServerURL() + "job/addshare"
    public static let JOB_SHARED_URL = getServerURL() + "job/shared"
    public static let JOB_REMOVESHARE_URL = getServerURL() + "job/removeshare"
    public static let JOB_ADDFAVORITE_URL = getServerURL() + "job/addfavorite"
    public static let JOB_GETFAVORITE_URL = getServerURL() + "job/getfavorite"
    public static let JOB_REMOVEFAVORITE_URL = getServerURL() + "job/removefavorite"
    public static let VERIFICATION_CONFIRM_URL = getServerURL() + "user/verifyconfirm"
    public static let VERIFICATION_SEND_URL = getServerURL() + "verification"
    public static let GETCHATLIST_URL = getServerURL() + "chatlist/get"
    public static let ADDCHATLIST_URL = getServerURL() + "chatlist/add"
    public static let REMOVECHATLIST_URL = getServerURL() + "chatlist/remove"
    public static let GETCHATHISTORY_URL = getServerURL() + "chatting/get"
    public static let CHATREAD_URL = getServerURL() + "chatting/read"
    
    public static let NOTIGET_URL = getServerURL() + "notification/get"
    public static let NOTIREAD_URL = getServerURL() + "notification/read"
    
    
    public static let LOGIN_VC = "LoginViewController"
    public static let SIGNUP_VC = "SignUpViewController"
    public static let SIGNIN_VC = "SignInViewController"
    public static let SETTING_VC = "SettingViewController";
    public static let CONTACTS_VC = "ContactsViewController";
    public static let FINDJOB_VC = "FindJobViewController"
    public static let REFEREDJOB_VC = "ReferedJobsViewController"
    public static let PROFILESETTING_VC = "ProfileSettingViewController"
    public static let PROFILE_VC = "ProfileViewController"
    public static let NOTISETTING_VC = "NotificationSettingViewController"
    public static let CHATS_VC = "ChatsViewController"
    public static let HELP_VC = "HelpViewController"
    public static let CHATLIST_VC = "ChatListViewController"
    public static let CONTACTSPOSTEDJOB_VC = "ContactsPostedJobViewController"
    public static let CORORGSETTING_VC = "CourseOrgSettingViewController"
    public static let COROUGVIEW_VC = "CourseOrgViewController"
    public static let CORORGDETAIL_VC = "CourseOrgDetailViewController"
    public static let PROPOSEUSERS_VC = "ProposedUserController"
    public static let VERIFICATION_VC = "VerificationViewController"
    public static let FORGOTPASSWORD_VC = "ForgotPasswordViewController"
    public static let ROOT_VC = "RootViewController"
    public static let ROOT_TAB_VC = "RootTabViewController"
    public static let MYJOBROOT_VC = "MyJobRootViewController"
    public static let ADDJOB_VC = "AddJobViewController"
    public static let SKILL_VC = "SkillViewController"
    public static let COUNTRY_VC = "CountryViewController"
    public static let SELECTCONTACTS_VC = "SelecteContactsViewController"
    public static let LANGUAGE_VC = "LanguageViewController"
    public static let NOCONTACTS_VC = "NoContactsViewController"
    public static let ROOTCONTACTS_VC = "ContactRootViewController"
    public static let USERPOSTED_VC = "UserPostedJobsViewController"
    public static let JOBDETAILS_VC = "JobDetailsViewController"
    public static let INVITEUSER_VC = "InviteUserViewController"
    public static let FAVORITEJOBS_VC = "FavoriteJobsViewController"
    public static let GET_STARTED_VC = "GetStartedViewController"
    
    private static func getServerURL()->String{
        return PROTOCOL + "://" + SERVER_ADDR + ":" + SERVER_PORT + "/" + SERVICIES + "/"
    }
//    
//    public static func getFullURL(_ api: String)->String{
//        return getServerURL() + "/" + api
//    }
//    

    
    
    
}
