// Constants for the app
const String appName = 'WaterWatch';

// Firestore collections
const String usersCollection = 'users';
const String announcementsCollection = 'announcements';
const String readStatusCollection = 'read_status';

// Areas (can be expanded based on your needs)
const List<String> areas = [
  'Binuangan',
  'Catanghalan',
  'Hulo',
  'Lawa',
  'Paco',
  'Pag-asa',
  'Paliwas',
  'Panghulo',
  'Salambao',
  'San Pascual',
  'Tawiran',
];

const List<String> announcementCategories = [
  'Billing & Rates',
  'Maintenance',
  'Resolved',
];

// Firebase topic prefixes
const String areaTopicPrefix = 'area_';
const String allUsersTopicName = 'all_users';
