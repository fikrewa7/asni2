-- Disable foreign key enforcement during migration
PRAGMA foreign_keys = OFF;

-- 1. USERS & STAFF TABLE
DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    role TEXT CHECK(role IN ('admin', 'receptionist', 'guest')) NOT NULL DEFAULT 'guest',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 2. ROOMS INVENTORY TABLE
DROP TABLE IF EXISTS rooms;
CREATE TABLE IF NOT EXISTS rooms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_number TEXT UNIQUE NOT NULL,
    room_type TEXT CHECK(room_type IN ('Standard', 'Deluxe', 'Executive Suite', 'Family Suite')) NOT NULL,
    price_per_night_etb REAL NOT NULL,
    capacity INTEGER NOT NULL DEFAULT 2,
    status TEXT CHECK(status IN ('Available', 'Occupied', 'Cleaning', 'Maintenance')) NOT NULL DEFAULT 'Available',
    description TEXT
);

-- 3. BOOKINGS TABLE
DROP TABLE IF EXISTS bookings;
CREATE TABLE IF NOT EXISTS bookings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    room_id INTEGER NOT NULL,
    guest_name TEXT NOT NULL,
    guest_phone TEXT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_amount_etb REAL NOT NULL,
    status TEXT CHECK(status IN ('Pending', 'Confirmed', 'CheckedIn', 'CheckedOut', 'Cancelled')) NOT NULL DEFAULT 'Confirmed',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(room_id) REFERENCES rooms(id) ON DELETE CASCADE
);

-- 4. RESTAURANT TABLES / SEATING
DROP TABLE IF EXISTS restaurant_tables;
CREATE TABLE IF NOT EXISTS restaurant_tables (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    table_number TEXT UNIQUE NOT NULL,
    seating_capacity INTEGER NOT NULL,
    zone TEXT CHECK(zone IN ('Indoor Main', 'Garden Patio', 'Rooftop Lounge')) NOT NULL,
    status TEXT CHECK(status IN ('Available', 'Reserved', 'Occupied')) DEFAULT 'Available'
);

-- 5. MENU ITEMS TABLE
DROP TABLE IF EXISTS menu_items;
CREATE TABLE IF NOT EXISTS menu_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    category TEXT CHECK(category IN ('Traditional Ethiopian', 'Breakfast', 'Main Course', 'Beverages', 'Dessert')) NOT NULL,
    price_etb REAL NOT NULL,
    available INTEGER NOT NULL DEFAULT 1,
    description TEXT
);

-- 6. ORDERS TABLE
DROP TABLE IF EXISTS orders;
CREATE TABLE IF NOT EXISTS orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    order_type TEXT CHECK(order_type IN ('Room Service', 'Restaurant Table')) NOT NULL,
    target_identifier TEXT NOT NULL, -- e.g., "Room 101" or "Table T-02"
    items_json TEXT NOT NULL, -- JSON array of items: [{id, name, qty, price_etb}]
    total_amount_etb REAL NOT NULL,
    status TEXT CHECK(status IN ('Pending', 'Preparing', 'Served', 'Cancelled')) DEFAULT 'Pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 7. PROMOTIONAL BANNERS TABLE
DROP TABLE IF EXISTS ad_banners;
CREATE TABLE IF NOT EXISTS ad_banners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    tag TEXT NOT NULL,
    badge_color TEXT DEFAULT 'bg-amber-600',
    active INTEGER NOT NULL DEFAULT 1
);

PRAGMA foreign_keys = ON;

-- ========================================================
-- SEED DATA (ETB Currency - Jimma Ferenj Arada Context)
-- ========================================================

-- Users
INSERT INTO users (full_name, email, phone, role) VALUES
('Abebe Demissie', 'admin@asniguesthouse.com', '+251917000001', 'admin'),
('Chaltu Gemechu', 'reception@asniguesthouse.com', '+251917000002', 'receptionist'),
('Dawit Isaak', 'dawit.i@gmail.com', '+251911223344', 'guest'),
('Selamawit Kebede', 'selam.k@gmail.com', '+251922334455', 'guest');

-- Rooms
INSERT INTO rooms (room_number, room_type, price_per_night_etb, capacity, status, description) VALUES
('101', 'Standard', 1800.00, 2, 'Occupied', 'Cozy ground floor room with queen bed and balcony view.'),
('102', 'Standard', 1800.00, 2, 'Available', 'Spacious standard room featuring high-speed WiFi and work desk.'),
('201', 'Deluxe', 2500.00, 2, 'Occupied', 'Deluxe room with Jimma city vista, smart TV, and mini bar.'),
('202', 'Deluxe', 2500.00, 2, 'Cleaning', 'Deluxe suite facing garden patio with premium bedding.'),
('301', 'Executive Suite', 4500.00, 3, 'Available', 'Top-floor luxury suite with living area and private coffee bar.'),
('302', 'Family Suite', 3800.00, 4, 'Available', 'Two connected king bedrooms suitable for family vacations.');

-- Bookings
INSERT INTO bookings (room_id, guest_name, guest_phone, check_in_date, check_out_date, total_amount_etb, status) VALUES
(1, 'Dawit Isaak', '+251911223344', '2026-09-28', '2026-10-02', 7200.00, 'CheckedIn'),
(3, 'Selamawit Kebede', '+251922334455', '2026-09-30', '2026-10-03', 7500.00, 'CheckedIn');

-- Restaurant Tables
INSERT INTO restaurant_tables (table_number, seating_capacity, zone, status) VALUES
('T-01', 2, 'Indoor Main', 'Occupied'),
('T-02', 4, 'Indoor Main', 'Available'),
('G-01', 4, 'Garden Patio', 'Available'),
('R-01', 6, 'Rooftop Lounge', 'Reserved');

-- Menu Items
INSERT INTO menu_items (name, category, price_etb, available, description) VALUES
('Special Kitfo', 'Traditional Ethiopian', 450.00, 1, 'Finely minced fresh beef seasoned with mitmita and niter kibbeh.'),
('Doro Wat', 'Traditional Ethiopian', 400.00, 1, 'Slow-cooked spicy chicken stew served with hard-boiled egg and injera.'),
('Special Shiro Tegabino', 'Traditional Ethiopian', 220.00, 1, 'Simmered spiced chickpea flour served piping hot in a clay pot.'),
('Jimma Buna Ceremony', 'Beverages', 150.00, 1, 'Freshly roasted traditional coffee ceremony with popcorn.'),
('Ful Medames', 'Breakfast', 180.00, 1, 'Spiced fava beans served with fresh warm bread roll and sliced green chili.'),
('Spris Juice', 'Beverages', 120.00, 1, 'Layered avocado, mango, and papaya fresh fruit juice.');

-- Orders
INSERT INTO orders (order_type, target_identifier, items_json, total_amount_etb, status) VALUES
('Room Service', 'Room 101', '[{"name":"Special Kitfo","qty":1,"price_etb":450},{"name":"Jimma Buna Ceremony","qty":1,"price_etb":150}]', 600.00, 'Preparing'),
('Restaurant Table', 'Table T-01', '[{"name":"Doro Wat","qty":2,"price_etb":400},{"name":"Spris Juice","qty":2,"price_etb":120}]', 1040.00, 'Served');

-- Ad Banners
INSERT INTO ad_banners (title, description, tag, badge_color, active) VALUES
('Jimma Coffee Tour', 'Explore authentic coffee farms around Jimma. Book guided tours at reception.', 'Special Experience', 'bg-amber-600', 1),
('Aba Jifar Palace Excursion', 'Visit the historic King Aba Jifar II Palace located near Ferenj Arada.', 'Cultural Heritage', 'bg-blue-600', 1),
('Free Airport Shuttle', 'Complimentary shuttle service to and from Jimma Airport (JIM) for Executive guests.', 'Guest Perk', 'bg-emerald-600', 1);
