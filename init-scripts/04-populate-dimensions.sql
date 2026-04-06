INSERT INTO dim_supplier (name, contact, email, phone, address, city, country)
SELECT DISTINCT ON (supplier_name, supplier_email)
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data
WHERE supplier_name IS NOT NULL
ORDER BY supplier_name, supplier_email
ON CONFLICT (name, email) DO NOTHING;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_supplier;
    RAISE NOTICE 'заполнено записей в dim_supplier: %', row_count;
END $$;

INSERT INTO dim_customer (first_name, last_name, age, email, country, postal_code)
SELECT DISTINCT 
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM mock_data
WHERE customer_email IS NOT NULL
ON CONFLICT (email) DO NOTHING;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_customer;
    RAISE NOTICE 'заполнено записей в dim_customer: %', row_count;
END $$;

INSERT INTO dim_pet (customer_id, pet_type, pet_name, pet_breed, pet_category)
SELECT DISTINCT 
    c.customer_id,
    m.customer_pet_type,
    m.customer_pet_name,
    m.customer_pet_breed,
    m.pet_category
FROM mock_data m
INNER JOIN dim_customer c ON c.email = m.customer_email
WHERE m.customer_pet_name IS NOT NULL;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_pet;
    RAISE NOTICE 'заполнено записей в dim_pet: %', row_count;
END $$;

INSERT INTO dim_seller (first_name, last_name, email, country, postal_code)
SELECT DISTINCT 
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM mock_data
WHERE seller_email IS NOT NULL
ON CONFLICT (email) DO NOTHING;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_seller;
    RAISE NOTICE 'заполнено записей в dim_seller: %', row_count;
END $$;

INSERT INTO dim_product (supplier_id, name, category, price, weight, color, size, brand, 
                         material, description, rating, reviews, release_date, expiry_date)
SELECT DISTINCT ON (m.product_name, m.product_category)
    s.supplier_id,
    m.product_name,
    m.product_category,
    m.product_price,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    CASE 
        WHEN m.product_release_date IS NOT NULL AND m.product_release_date != '' 
        THEN TO_DATE(m.product_release_date, 'MM/DD/YYYY')
        ELSE NULL
    END,
    CASE 
        WHEN m.product_expiry_date IS NOT NULL AND m.product_expiry_date != '' 
        THEN TO_DATE(m.product_expiry_date, 'MM/DD/YYYY')
        ELSE NULL
    END
FROM mock_data m
INNER JOIN dim_supplier s ON s.name = m.supplier_name AND s.email = m.supplier_email
WHERE m.product_name IS NOT NULL
ORDER BY m.product_name, m.product_category;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_product;
    RAISE NOTICE 'заполнено записей в dim_product: %', row_count;
END $$;

INSERT INTO dim_store (name, location, city, state, country, phone, email)
SELECT DISTINCT ON (store_name, store_email)
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data
WHERE store_name IS NOT NULL
ORDER BY store_name, store_email
ON CONFLICT (name, email) DO NOTHING;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_store;
    RAISE NOTICE 'заполнено записей в dim_store: %', row_count;
END $$;

INSERT INTO dim_date (full_date, year, month, day, quarter, day_of_week, day_name, month_name)
SELECT DISTINCT 
    TO_DATE(sale_date, 'MM/DD/YYYY') as full_date,
    EXTRACT(YEAR FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(MONTH FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(DAY FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(QUARTER FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    EXTRACT(DOW FROM TO_DATE(sale_date, 'MM/DD/YYYY'))::INTEGER,
    TRIM(TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Day')),
    TRIM(TO_CHAR(TO_DATE(sale_date, 'MM/DD/YYYY'), 'Month'))
FROM mock_data
WHERE sale_date IS NOT NULL AND sale_date != ''
ON CONFLICT (full_date) DO NOTHING;

DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM dim_date;
    RAISE NOTICE 'заполнено записей в dim_date: %', row_count;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'все таблицы измерений заполнены';
END $$;
