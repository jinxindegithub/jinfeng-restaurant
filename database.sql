-- ============================================
-- 金烽音乐餐吧 - 数据库建表SQL
-- Supabase PostgreSQL
-- ============================================

-- 1. 员工/账号表
CREATE TABLE IF NOT EXISTS restaurant_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  name VARCHAR(50),
  role VARCHAR(20) DEFAULT 'staff',
  permissions JSONB DEFAULT '{}'::jsonb,
  status VARCHAR(10) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 初始管理员
INSERT INTO restaurant_users (username, password, name, role, permissions)
SELECT 'admin', '123456', '管理员', 'admin', 
       '{"cows":1,"barns":1,"feed":1,"health":1,"breeding":1,"weight":1,"settings":1,"dish":1,"order":1,"member":1,"stats":1,"table":1,"ktv":1}'::jsonb
WHERE NOT EXISTS (SELECT 1 FROM restaurant_users WHERE username = 'admin');

-- 2. 菜品表
CREATE TABLE IF NOT EXISTS restaurant_dishes (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  price NUMERIC(10,2) NOT NULL,
  unit VARCHAR(10) DEFAULT '份',
  is_hot BOOLEAN DEFAULT false,
  is_recommend BOOLEAN DEFAULT false,
  status VARCHAR(10) DEFAULT 'on',
  stock INT DEFAULT 999,
  image VARCHAR(255),
  note VARCHAR(500),
  sort INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 3. 桌台表
CREATE TABLE IF NOT EXISTS restaurant_tables (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) UNIQUE NOT NULL,
  type VARCHAR(20) DEFAULT 'hall',
  capacity INT DEFAULT 4,
  status VARCHAR(20) DEFAULT 'free',
  current_order_id INT,
  hourly_rate NUMERIC(10,2) DEFAULT 0,
  sort INT DEFAULT 0,
  note VARCHAR(200),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 4. 订单表
CREATE TABLE IF NOT EXISTS restaurant_orders (
  id SERIAL PRIMARY KEY,
  order_no VARCHAR(30) UNIQUE NOT NULL,
  table_id INT,
  table_name VARCHAR(50),
  order_type VARCHAR(20) DEFAULT 'dine_in',
  people_count INT DEFAULT 0,
  subtotal NUMERIC(10,2) DEFAULT 0,
  discount NUMERIC(10,2) DEFAULT 0,
  total NUMERIC(10,2) DEFAULT 0,
  paid_amount NUMERIC(10,2) DEFAULT 0,
  pay_method VARCHAR(20),
  member_id INT,
  member_name VARCHAR(50),
  status VARCHAR(20) DEFAULT 'open',
  server_id INT,
  server_name VARCHAR(50),
  open_time TIMESTAMP DEFAULT NOW(),
  close_time TIMESTAMP,
  note VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 5. 订单明细表
CREATE TABLE IF NOT EXISTS restaurant_order_items (
  id SERIAL PRIMARY KEY,
  order_id INT NOT NULL,
  dish_id INT,
  dish_name VARCHAR(100) NOT NULL,
  price NUMERIC(10,2) NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  amount NUMERIC(10,2) NOT NULL,
  note VARCHAR(200),
  status VARCHAR(20) DEFAULT 'normal',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 6. 会员表
CREATE TABLE IF NOT EXISTS restaurant_members (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  level VARCHAR(20) DEFAULT 'normal',
  balance NUMERIC(10,2) DEFAULT 0,
  total_consume NUMERIC(10,2) DEFAULT 0,
  points INT DEFAULT 0,
  birthday VARCHAR(20),
  note VARCHAR(500),
  status VARCHAR(10) DEFAULT 'active',
  created_at TIMESTAMP DEFAULT NOW()
);

-- 7. 会员充值记录
CREATE TABLE IF NOT EXISTS restaurant_member_recharges (
  id SERIAL PRIMARY KEY,
  member_id INT NOT NULL,
  member_name VARCHAR(50),
  amount NUMERIC(10,2) NOT NULL,
  gift_amount NUMERIC(10,2) DEFAULT 0,
  pay_method VARCHAR(20) DEFAULT 'cash',
  operator_id INT,
  operator_name VARCHAR(50),
  note VARCHAR(200),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 8. 库存/进货记录
CREATE TABLE IF NOT EXISTS restaurant_stock (
  id SERIAL PRIMARY KEY,
  item_name VARCHAR(100) NOT NULL,
  category VARCHAR(50),
  quantity NUMERIC(10,2) NOT NULL,
  unit VARCHAR(10) DEFAULT '斤',
  unit_price NUMERIC(10,2),
  total_price NUMERIC(10,2),
  supplier VARCHAR(100),
  operator_id INT,
  operator_name VARCHAR(50),
  note VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 9. 预订记录
CREATE TABLE IF NOT EXISTS restaurant_bookings (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50),
  phone VARCHAR(20),
  booking_type VARCHAR(20),
  people_count INT,
  booking_time TIMESTAMP,
  table_id INT,
  status VARCHAR(20) DEFAULT 'pending',
  note VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

-- ============================================
-- 初始示例数据
-- ============================================

-- 示例菜品
INSERT INTO restaurant_dishes (name, category, price, unit, is_hot, is_recommend, sort)
SELECT '羊肉串', '烧烤', 3.00, '串', true, true, 1
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '羊肉串');

INSERT INTO restaurant_dishes (name, category, price, unit, is_hot, sort)
SELECT '牛肉串', '烧烤', 4.00, '串', true, 2
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '牛肉串');

INSERT INTO restaurant_dishes (name, category, price, unit, is_recommend, sort)
SELECT '烤鸡翅', '烧烤', 8.00, '个', true, 3
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '烤鸡翅');

INSERT INTO restaurant_dishes (name, category, price, unit, is_recommend, sort)
SELECT '万州烤鱼', '热菜', 88.00, '份', true, 10
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '万州烤鱼');

INSERT INTO restaurant_dishes (name, category, price, unit, sort)
SELECT '辣爆小龙虾', '热菜', 88.00, '份', 11
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '辣爆小龙虾');

INSERT INTO restaurant_dishes (name, category, price, unit, sort)
SELECT '辣爆鸡', '热菜', 58.00, '份', 12
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '辣爆鸡');

INSERT INTO restaurant_dishes (name, category, price, unit, sort)
SELECT '青岛啤酒', '酒水', 8.00, '瓶', 20
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '青岛啤酒');

INSERT INTO restaurant_dishes (name, category, price, unit, sort)
SELECT '百威啤酒', '酒水', 12.00, '瓶', 21
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '百威啤酒');

INSERT INTO restaurant_dishes (name, category, price, unit, sort)
SELECT '科罗娜', '酒水', 18.00, '瓶', 22
WHERE NOT EXISTS (SELECT 1 FROM restaurant_dishes WHERE name = '科罗娜');

-- 示例桌台
INSERT INTO restaurant_tables (name, type, capacity, sort)
SELECT '1号桌', 'hall', 4, 1
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = '1号桌');

INSERT INTO restaurant_tables (name, type, capacity, sort)
SELECT '2号桌', 'hall', 4, 2
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = '2号桌');

INSERT INTO restaurant_tables (name, type, capacity, sort)
SELECT '3号桌', 'hall', 6, 3
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = '3号桌');

INSERT INTO restaurant_tables (name, type, capacity, sort)
SELECT '5号桌', 'hall', 8, 5
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = '5号桌');

INSERT INTO restaurant_tables (name, type, capacity, hourly_rate, sort)
SELECT 'KTV小包', 'ktv', 8, 58.00, 30
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = 'KTV小包');

INSERT INTO restaurant_tables (name, type, capacity, hourly_rate, sort)
SELECT 'KTV中包', 'ktv', 15, 88.00, 31
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = 'KTV中包');

INSERT INTO restaurant_tables (name, type, capacity, hourly_rate, sort)
SELECT 'KTV大包VIP', 'ktv', 25, 128.00, 32
WHERE NOT EXISTS (SELECT 1 FROM restaurant_tables WHERE name = 'KTV大包VIP');
