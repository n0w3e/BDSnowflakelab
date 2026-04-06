INSERT INTO fact_sales (customer_id, seller_id, product_id, store_id, date_id, quantity, total_price)
SELECT 
    c.customer_id,
    sel.seller_id,
    p.product_id,
    st.store_id,
    d.date_id,
    m.sale_quantity,
    m.sale_total_price
FROM mock_data m
INNER JOIN dim_customer c ON c.email = m.customer_email
INNER JOIN dim_seller sel ON sel.email = m.seller_email
INNER JOIN dim_supplier sup ON sup.name = m.supplier_name AND sup.email = m.supplier_email
INNER JOIN dim_product p ON p.name = m.product_name AND p.category = m.product_category
INNER JOIN dim_store st ON st.name = m.store_name AND st.email = m.store_email
INNER JOIN dim_date d ON d.full_date = TO_DATE(m.sale_date, 'MM/DD/YYYY')
WHERE m.sale_quantity IS NOT NULL 
  AND m.sale_total_price IS NOT NULL;

DO $$
DECLARE
    row_count INTEGER;
    staging_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM fact_sales;
    SELECT COUNT(*) INTO staging_count FROM mock_data;
    RAISE NOTICE 'заполнено записей в fact_sales: %', row_count;
    RAISE NOTICE 'исходных записей в staging: %', staging_count;
    
    IF row_count = staging_count THEN
        RAISE NOTICE 'SUCCESS: все записи успешно трансформированы!';
    ELSE
        RAISE WARNING 'WARN: кол-во записей не совпадает';
    END IF;
END $$;

DO $$
BEGIN
    RAISE NOTICE 'таблица фактов заполнена';
END $$;
