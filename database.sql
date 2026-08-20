-- ============================================
-- 金烽音乐餐厅 - 数据库建表SQL
-- 业务：烧烤 + KTV + 酒水 + 会员 + 收银
-- ============================================

-- 1. 管理员/员工表
CREATE TABLE IF NOT EXISTS restaurant_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(50) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  real_name VARCHAR(50),
  role VARCHAR(20) DEFAULT 'staff',
  phone VARCHAR(20),
  enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 初始管理员账号
INSERT INTO restaurant_users (username, password, real_name, role)
SELECT 'admin', '123456', '超级管理员', 'admin'
WHERE NOT EXISTS (SELECT 1 FROM restaurant_users WHERE username = 'admin');

-- 2. 餐桌/包厢表
CREATE TABLE IF NOT EXISTS tables_rooms (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL, -- 如：大厅A1、KTV小包1号
  type VARCHAR(20) NOT NULL,   -- hall堂食/dating大厅/ktv包厢/bbq烧烤区
  min_people INTEGER DEFAULT 2,
  max_people INTEGER DEFAULT 6,
  has_ktv BOOLEAN DEFAULT FALSE,
  has_ktv_fee BOOLEAN DEFAULT FALSE, -- 是否收取KTV费
  ktv_hourly_fee DECIMAL(10,2) DEFAULT 0, -- KTV每小时费用
  status VARCHAR(20) DEFAULT 'idle', -- idle空闲/using使用中/reserved已预订/cleaning清扫中
  note VARCHAR(500)
);

-- 初始餐桌/包厢
INSERT INTO tables_rooms (name, type, max_people, status) VALUES
('大厅A1', 'hall', 6, 'idle'),
('大厅A2', 'staffstaffstaff', 6, 'staffstaffstaff'),
('大厅A3', 'staffstaffstaff', 6, 'staffstaffstaff'),
('staffstaffstaffB1', 'staffstaffstaff', 8, 'staffstaffstaff'),
('小包1号', 'ktv', 6, 'staffstaff'),
('小包2号', 'ktv', 6, 'staffstaff'),
('中包1号', 'ktv', 12, 'idle'),
('中包2号', 'ktv', 12, 'idle'),
('大包VIP1号', 'ktv', 20, 'idle')
WHERE NOT EXISTS (SELECT 1 FROM tables_rooms WHERE name = '大厅A1');

-- 3. 菜品/酒水分类
CREATE TABLE IF NOT EXISTS categories (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  type VARCHAR(20) DEFAULT 'food', -- food食品/drink酒水/ktvKTV套餐
  sort_order INTEGER DEFAULT 0,
  icon VARCHAR(20)
);

-- 初始分类
INSERT INTO categories (name, type, sort_order, icon)
SELECT unnest(ARRAY['烧烤类', '热菜类', '凉菜类', '主食类', '啤酒', '白酒', '红酒', '饮料', 'KTV套餐'])::VARCHAR,
       unnest(ARRAY['food', 'food', 'food', 'food', 'drink', 'drink', 'drink', 'drink', 'ktv'])::VARCHAR,
       unnest(ARRAY[1,2,3,4,5,6,7,8,9])::INTEGER,
       unnest(ARRAY['🍢', '🍲', '🥗', '🍚', '🍺', '🍶', '🍷', '🥤', '🎤'])::VARCHAR
WHERE NOT EXISTS (SELECT 1 FROM categories WHERE name = '烧烤类');

-- 4. 菜品/酒水表
CREATE TABLE IF NOT EXISTS menu_items (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  category_id INTEGER REFERENCES categories(id),
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  unit VARCHAR(10) DEFAULT '份',
  stock INTEGER DEFAULT 9999,
  is_hot BOOLEAN DEFAULT FALSE,
  is_recommend BOOLEAN DEFAULT FALSE,
  description VARCHAR(500),
  image VARCHAR(500),
  available BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0
);

-- 初始菜品
INSERT INTO menu_items (name, category_id, price, unit, is_hot, is_recommend) VALUES
('羊肉串', 1, 3.00, '串', true, true),
('牛肉串', 1, 4.00, '串', true, true),
('烤鸡翅', 1, 8.00, '个', true, false),
('烤生蚝', 1, 10.00, '个', true, true),
('烤茄子', 1, 12.00, '份', false, false),
('烤韭菜', 1, 8.00, '份', false, false),
('烤馒头片', 1, 3.00, '串', false, false),
('烤鱼', 1, 68.00, '条', true, true),
('麻辣小龙虾', 2, 88.00, '份', true, true),
('爆炒花蛤', 2, 28.00, '份', false, false),
('凉拌黄瓜', 3, 12.00, '份', false, false),
('凉拌木耳', 3, 15.00, '份', false, false),
('皮蛋豆腐', 3, 12.00, '份', false, false),
('炒面', 4, 18.00, '份', false, false),
('蛋炒饭', 4, 15.00, '份', false, false),
('青岛啤酒', 5, 8.00, '瓶', true, false),
('百威啤酒', 5, 12.00, '瓶', true, true),
('科罗娜', 5, 18.00, '瓶', false, false),
('1664白啤', 5, 20.00, '瓶', false, false),
('勇闯天涯', 5, 10.00, '瓶', false, false),
('牛栏山二锅头', 6, 25.00, '瓶', false, false),
('劲酒', 6, 35.00, '瓶', false, false),
('长城干红', 7, 88.00, '瓶', false, false),
('张裕解百纳', 7, 128.00, '瓶', false, false),
('可乐', 8, 6.00, '瓶', false, false),
('雪碧', 8, 6.00, '瓶', false, false),
('果粒橙', 8, 8.00, '瓶', false, false),
('椰汁', 8, 10.00, '瓶', false, false),
('矿泉水', 8, 3.00, '瓶', false, false)
WHERE NOT EXISTS (SELECT 1 FROM menu_items WHERE name = '羊肉串');

-- 5. 订单表
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  order_no VARCHAR(50) UNIQUE NOT NULL,
  table_id INTEGER,
  table_name VARCHAR(100),
  customer_count INTEGER DEFAULT 1,
  total_amount DECIMAL(10,2) DEFAULT 0,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  actual_amount DECIMAL(10,2) DEFAULT 0,
  paid_amount DECIMAL(10,2) DEFAULT 0,
  payment_method VARCHAR(20) DEFAULT 'cash', -- cash现金/wechat微信/alipay支付宝/card刷卡/sign挂账
  status VARCHAR(20) DEFAULT 'dining', -- dining用餐中/settled已结账/canceled已取消
  member_id INTEGER DEFAULT NULL,
  member_name VARCHAR(100),
  staff_id INTEGER,
  staff_name VARCHAR(100),
  ktv_start_time TIMESTAMP,
  ktv_end_time TIMESTAMP,
  ktv_fee DECIMAL(10,2) DEFAULT 0,
  remark VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW(),
  settled_at TIMESTAMP
);

-- 6. 订单明细表
CREATE TABLE IF NOT EXISTS order_items (
  id SERIAL PRIMARY KEY,
  order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
  item_id INTEGER,
  item_name VARCHAR(100) NOT NULL,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  quantity INTEGER NOT NULL DEFAULT 1,
  amount DECIMAL(10,2) DEFAULT 0,
  status VARCHAR(20) DEFAULT 'normal', -- normal正常/returned已退菜
  note VARCHAR(200),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 7. 会员表
CREATE TABLE IF NOT EXISTS members (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  level VARCHAR(20) DEFAULT 'staffstaff', -- normal普通/silver金卡/gold钻卡
  balance DECIMAL(10,2) DEFAULT 0,
  total_consume DECIMAL(10,2) DEFAULT 0,
  total_visits INTEGER DEFAULT 0,
  birthday VARCHAR(20),
  note VARCHAR(500),
  created_at TIMESTAMP DEFAULT NOW()
);

-- 初始会员
INSERT INTO members (name, phone, level, balance) VALUES
('测试会员', '13800138000', 'staffstaff', 500.00)
WHERE NOT EXISTS (SELECT 1 FROM members WHERE phone = '13800138000');

-- 8. 系统设置表
CREATE TABLE IF NOT EXISTS restaurant_settings (
  id INTEGER PRIMARY KEY DEFAULT 1,
  shop_name VARCHAR(200) DEFAULT '金烽音乐餐厅',
  shop_phone VARCHAR(50),
  shop_address VARCHAR(500),
  ktv_hourly_fee DECIMAL(10,2) DEFAULT 50.00,
  staff_discount DECIMAL(10,2) DEFAULT 0.85,
  updated_at TIMESTAMP DEFAULT NOW()
);

INSERT INTO restaurant_settings (id, shop_name, shop_phone)
SELECT 1, '金烽音乐餐厅', '138xxxxxxx'
WHERE NOT EXISTS (SELECT 1 FROM restaurant_settings WHERE id = 1);
