// Firebase Cloud Messaging Rules
// This file documents the FCM topics used in the WaterWatch app

const String allUsersTopic = 'all_users';
// Topic format for areas: 'area_Binuangan', 'area_Catanghalan', etc.

// Admin publishes to FCM topics:
// 1. Specific area: /topics/area_AreaName
// 2. All users: /topics/all_users

// Clients subscribe to:
// 1. Their specific area topic
// 2. Optionally the all_users topic for system announcements
