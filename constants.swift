//
//  constants.swift
//  motified
//
//  Created by Giancarlo Anemone on 3/16/15.
//  Copyright (c) 2015 Giancarlo Anemone. All rights reserved.
//

import Foundation

let NOTIFICATION_SELECTED_EVENTS_CHANGED = "notification_selected_events_changed"
let NOTIFICATION_LOADED_EVENTS = "notification_loaded_events"
let NOTIFICATION_ERROR_EVENTS = "notification_error_events"
let NOTIFICATION_LOADED_CATEGORIES = "notification_loaded_categories"
let NOTIFICATION_ERROR_CATEGORIES = "notification_error_categories"
let NOTIFICATION_LOCATION_PICKED = "notification_location_picked"

let SEGUE_ID_GET_LOCATION = "segue_id_get_location"
let SEGUE_ID_EVENT_DETAIL = "segue_id_event_detail"
let SEGUE_ID_MAIN_TAB = "segue_id_main_tab"
let SEGUE_ID_LOGOUT = "segue_id_logout"

let PREF_ON_START_KEY: String = "pref_on_start_key"
let PREF_HOUR_PRIOR_KEY: String = "pref_30_min_key"
let PREF_DAY_PRIOR_KEY: String = "pref_day_prior_key"

let IS_OS_7_OR_LATER = UIDevice.currentDevice().systemVersion.toInt() >= 7
let IS_OS_8_OR_LATER = UIDevice.currentDevice().systemVersion.toInt() >= 8

//let BASE_URL: String = "http://localhost:5000/"
let BASE_URL: String = "http://ganemone.pythonanywhere.com/"