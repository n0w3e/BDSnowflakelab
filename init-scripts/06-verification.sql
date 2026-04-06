DO $$
BEGIN
    RAISE NOTICE 'проверка кол-ва записей';
END $$;

SELECT 
    'mock_data (staging)' as table_name, 
    COUNT(*) as row_count 
FROM mock_data
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM fact_sales
ORDER BY table_name;

DO $$
DECLARE
    orphaned_count INTEGER;
BEGIN
    RAISE NOTICE 'проверка целостности данных';
    
    SELECT COUNT(*) INTO orphaned_count
    FROM fact_sales f
    WHERE NOT EXISTS (SELECT 1 FROM dim_customer WHERE customer_id = f.customer_id)
       OR NOT EXISTS (SELECT 1 FROM dim_seller WHERE seller_id = f.seller_id)
       OR NOT EXISTS (SELECT 1 FROM dim_product WHERE product_id = f.product_id)
       OR NOT EXISTS (SELECT 1 FROM dim_store WHERE store_id = f.store_id)
       OR NOT EXISTS (SELECT 1 FROM dim_date WHERE date_id = f.date_id);
    
    IF orphaned_count = 0 THEN
        RAISE NOTICE 'SUCCESS: все внешние ключи в fact_sales валидны';
    ELSE
        RAISE WARNING 'WARN: найдено % записей с невалидными внешними ключами', orphaned_count;
    END IF;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'пример аналитического запроса';
END $$;

SELECT 
    d.year,
    p.category,
    COUNT(DISTINCT f.customer_id) as unique_customers,
    SUM(f.quantity) as total_quantity,
    ROUND(SUM(f.total_price), 2) as total_revenue,
    ROUND(AVG(f.total_price), 2) as avg_sale_price
FROM fact_sales f
INNER JOIN dim_date d ON f.date_id = d.date_id
INNER JOIN dim_product p ON f.product_id = p.product_id
GROUP BY d.year, p.category
ORDER BY d.year, total_revenue DESC
LIMIT 10;

DO $$
BEGIN
    RAISE NOTICE 'топ 5 покупателей';
END $$;

SELECT 
    c.first_name || ' ' || c.last_name as customer_name,
    c.country,
    COUNT(*) as purchase_count,
    ROUND(SUM(f.total_price), 2) as total_spent
FROM fact_sales f
INNER JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
ORDER BY total_spent DESC
LIMIT 5;

DO $$
BEGIN
    RAISE NOTICE 'продажи по магазинам';
END $$;

SELECT 
    st.name as store_name,
    st.city,
    st.country,
    COUNT(*) as sales_count,
    ROUND(SUM(f.total_price), 2) as total_revenue
FROM fact_sales f
INNER JOIN dim_store st ON f.store_id = st.store_id
GROUP BY st.store_id, st.name, st.city, st.country
ORDER BY total_revenue DESC
LIMIT 10;

DO $$
BEGIN
    RAISE NOTICE 'инициализиация успешна';
END $$;
