//
//  ReportEventType.swift
//  TrackSDK
//
//  Created by jonzzhao on 2021/9/15.
//

import Foundation

public enum TrackEventType: String{
    case APP_LAUNCH = "app_launch"
    case APP_SHOW = "app_show"
    case EXIT_WXAPP = "exit_app"
    case BROWSE_WXAPP_PAGE = "browse_page"
    case LEAVE_WXAPP_PAGE = "leave_page"
    case PAGE_SHARE_APP_MESSAGE = "page_share_app_message"
    case PAGE_PULL_DOWN_REFRESH = "page_pull_down_refresh"
    case PAGE_REACH_BOTTOM = "page_reach_bottom"
    case ELEMENT = "element"
}
