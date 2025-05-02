-- POS SaaAS Database Schema (Revised)

-- 1. Multi-Tenancy & User Management

-- i. Users (must be created before companies)
CREATE TABLE users (
    user_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_users_company (company_id)
);

-- ii. Companies
CREATE TABLE companies (
    company_id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    subdomain VARCHAR(255) UNIQUE NOT NULL, -- tenant-specific URL prefix (e.g. "acme" makes acme.yourpos.com), isolates tenant data and branding
    -- Subdomain allows each company to have its own dedicated URL within the SaaS platform
    logo_url TEXT,
    website TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    license_expiry_date DATE,
    payment_status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    owner_user_id UUID,
    FOREIGN KEY (owner_user_id) REFERENCES users(user_id)
);

-- iii. Company Contacts (normalize multiple contacts)
CREATE TABLE company_contacts (
    contact_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    type VARCHAR(50) CHECK(type IN('phone','email','fax','other')),
    value VARCHAR(255) NOT NULL
);

-- iv. Businesses per company
CREATE TABLE businesses (
    business_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- v. Roles and Permissions
CREATE TABLE roles (
    role_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE permissions (
    permission_id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(role_id),
    permission_id UUID NOT NULL REFERENCES permissions(permission_id),
    PRIMARY KEY (role_id, permission_id)
);
CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(user_id),
    role_id UUID NOT NULL REFERENCES roles(role_id),
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, role_id)
);

-- vi. User assignments
CREATE TABLE user_business_assignments (
    user_id UUID NOT NULL REFERENCES users(user_id),
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    PRIMARY KEY (user_id, business_id)
);
CREATE TABLE user_store_assignments (
    user_id UUID NOT NULL REFERENCES users(user_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    PRIMARY KEY (user_id, store_id)
);

-- vii. Store Types Lookup
CREATE TABLE store_types (
    type VARCHAR(50) PRIMARY KEY,
    description TEXT
);
INSERT INTO store_types(type) VALUES('main'),('warehouse'),('outlet'),('shop');

-- viii. Stores, Shops, Warehouses
CREATE TABLE stores (
    store_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL REFERENCES store_types(type),
    parent_store_id UUID REFERENCES stores(store_id),
    level INT AS (CASE WHEN parent_store_id IS NULL THEN 0 ELSE 1 END) STORED,
    location TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ix. System Settings, Account & Tax Configs
CREATE TABLE system_settings (
    setting_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT
);
CREATE TABLE payment_accounts (
    account_id UUID PRIMARY KEY,
    company_id UUID NOT NULL REFERENCES companies(company_id),
    name VARCHAR(255),
    type VARCHAR(50) CHECK(type IN('bank','mobile','cash')),
    provider_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE account_groups (
    group_id UUID PRIMARY KEY,
    name VARCHAR(100)
);
CREATE TABLE taxes (
    tax_id UUID PRIMARY KEY,
    name VARCHAR(100),
    rate DECIMAL(5,2),
    is_inclusive BOOLEAN
);

-- 2. Products & Stock Management

CREATE TABLE product_categories (
    category_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL
);
CREATE TABLE product_groups (
    group_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL
);
CREATE TABLE units (
    unit_id UUID PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    is_smallest BOOLEAN DEFAULT FALSE
);
CREATE TABLE products (
    product_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) CHECK(type IN('stock','service')),
    barcode VARCHAR(100),
    category_id UUID REFERENCES product_categories(category_id),
    group_id UUID REFERENCES product_groups(group_id),
    smallest_unit_id UUID REFERENCES units(unit_id),
    reorder_point DECIMAL(10,2),
    is_expirable BOOLEAN DEFAULT FALSE,
    is_manufactured BOOLEAN DEFAULT FALSE,
    selling_price DECIMAL(10,2),
    cost_price DECIMAL(10,2),
    is_tax_inclusive BOOLEAN,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_products_barcode (barcode)
);
CREATE TABLE product_stock (
    stock_id UUID PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(product_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    quantity DECIMAL(10,2) DEFAULT 0,
    initial_stock DECIMAL(10,2),
    expiry_date DATE,
    as_of_date DATE,
    reference_code VARCHAR(100),
    UNIQUE(product_id, store_id)
);

-- 3. Bill of Materials (BOM) / Manufacturing

CREATE TABLE assemblies (
    assembly_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    total_cost DECIMAL(10,2),
    selling_price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE assembly_components (
    component_id UUID PRIMARY KEY,
    assembly_id UUID NOT NULL REFERENCES assemblies(assembly_id),
    component_product_id UUID NOT NULL REFERENCES products(product_id),
    quantity DECIMAL(10,2)
);
CREATE TABLE manufacturing_logs (
    log_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    quantity DECIMAL(10,2),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    manufacture_date DATE,
    expiry_date DATE,
    reference_code VARCHAR(100)
);

-- 4. Sales & Returns

CREATE TABLE sales (
    sale_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    customer_id UUID REFERENCES customers(customer_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    sale_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) CHECK(status IN('completed','pending','cancelled')),
    payment_status VARCHAR(50) CHECK(payment_status IN('paid','partial','unpaid')),
    total DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    grand_total DECIMAL(10,2),
    reference_code VARCHAR(100),
    created_by UUID REFERENCES users(user_id),
    updated_at TIMESTAMP,
    updated_by UUID REFERENCES users(user_id)
);
CREATE TABLE sale_items (
    sale_item_id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(sale_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    unit_id UUID REFERENCES units(unit_id),
    quantity DECIMAL(10,2),
    price DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    total DECIMAL(10,2)
);
CREATE TABLE deliveries (
    delivery_id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(sale_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    delivery_status VARCHAR(50) CHECK(delivery_status IN('pending','shipped','delivered','cancelled')),
    delivery_date TIMESTAMP,
    driver_name VARCHAR(255),
    vehicle_info TEXT,
    reference_code VARCHAR(100)
);
CREATE TABLE returns (
    return_id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(sale_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    return_type VARCHAR(50) CHECK(return_type IN('customer','supplier')),
    return_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total DECIMAL(10,2),
    reason TEXT,
    reference_code VARCHAR(100)
);
CREATE TABLE return_items (
    return_item_id UUID PRIMARY KEY,
    return_id UUID NOT NULL REFERENCES returns(return_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    unit_id UUID REFERENCES units(unit_id),
    quantity DECIMAL(10,2),
    price DECIMAL(10,2),
    tax DECIMAL(10,2),
    total DECIMAL(10,2)
);

-- 5. Purchases & Supplier Credits

CREATE TABLE purchases (
    purchase_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    store_id UUID NOT NULL REFERENCES stores(store_id),
    supplier_id UUID REFERENCES suppliers(supplier_id),
    user_id UUID NOT NULL REFERENCES users(user_id),
    purchase_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) CHECK(status IN('received','pending','cancelled')),
    total DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    grand_total DECIMAL(10,2),
    reference_code VARCHAR(100)
);
CREATE TABLE purchase_items (
    purchase_item_id UUID PRIMARY KEY,
    purchase_id UUID NOT NULL REFERENCES purchases(purchase_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    unit_id UUID REFERENCES units(unit_id),
    quantity DECIMAL(10,2),
    price DECIMAL(10,2),
    discount DECIMAL(10,2),
    tax DECIMAL(10,2),
    total DECIMAL(10,2)
);
CREATE TABLE supplier_credits (
    credit_id UUID PRIMARY KEY,
    supplier_id UUID NOT NULL REFERENCES suppliers(supplier_id),
    amount DECIMAL(10,2) NOT NULL,
    credit_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reason TEXT
);
CREATE TABLE recurring_bills (
    recur_id UUID PRIMARY KEY,
    supplier_id UUID NOT NULL REFERENCES suppliers(supplier_id),
    interval VARCHAR(50),
    next_date DATE,
    amount DECIMAL(10,2)
);

-- 6. Expenses & Categories

CREATE TABLE expense_categories (
    category_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(100) NOT NULL,
    description TEXT
);
CREATE TABLE expenses (
    expense_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    user_id UUID REFERENCES users(user_id),
    category_id UUID REFERENCES expense_categories(category_id),
    amount DECIMAL(10,2),
    expense_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_code VARCHAR(100),
    notes TEXT
);
CREATE TABLE recurring_expenses (
    recur_expense_id UUID PRIMARY KEY,
    category_id UUID NOT NULL REFERENCES expense_categories(category_id),
    interval VARCHAR(50),
    next_date DATE,
    amount DECIMAL(10,2)
);

-- 7. Inventory Movement & Adjustments

CREATE TABLE stock_movements (
    movement_id UUID PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(product_id),
    from_store_id UUID REFERENCES stores(store_id),
    to_store_id UUID REFERENCES stores(store_id),
    quantity DECIMAL(10,2),
    status VARCHAR(50) CHECK(status IN('pending','approved','rejected','completed')),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_code VARCHAR(100),
    initiated_by UUID REFERENCES users(user_id),
    approved_by UUID REFERENCES users(user_id)
);
CREATE TABLE stock_adjustments (
    adjustment_id UUID PRIMARY KEY,
    store_id UUID NOT NULL REFERENCES stores(store_id),
    product_id UUID NOT NULL REFERENCES products(product_id),
    quantity DECIMAL(10,2),
    reason TEXT,
    adjustment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_code VARCHAR(100),
    adjusted_by UUID REFERENCES users(user_id)
);

-- 8. Customer & Supplier Master Data

CREATE TABLE customers (
    customer_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(business_id,email)
);
CREATE TABLE suppliers (
    supplier_id UUID PRIMARY KEY,
    business_id UUID NOT NULL REFERENCES businesses(business_id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(business_id,name)
);

-- 9. Written-off Invoices

CREATE TABLE written_off_invoices (
    written_off_id UUID PRIMARY KEY,
    sale_id UUID NOT NULL REFERENCES sales(sale_id),
    amount DECIMAL(10,2),
    reason TEXT,
    written_off_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    written_off_by UUID REFERENCES users(user_id)
);

-- End of schema enhancements
