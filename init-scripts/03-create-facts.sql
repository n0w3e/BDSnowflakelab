CREATE TABLE fact_sales (
    sale_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES dim_customer(customer_id),
    seller_id INTEGER NOT NULL REFERENCES dim_seller(seller_id),
    product_id INTEGER NOT NULL REFERENCES dim_product(product_id),
    store_id INTEGER NOT NULL REFERENCES dim_store(store_id),
    date_id INTEGER NOT NULL REFERENCES dim_date(date_id),
    quantity INTEGER NOT NULL,
    total_price DECIMAL(10,2) NOT NULL
);

CREATE INDEX idx_fact_sales_customer ON fact_sales(customer_id);
CREATE INDEX idx_fact_sales_seller ON fact_sales(seller_id);
CREATE INDEX idx_fact_sales_product ON fact_sales(product_id);
CREATE INDEX idx_fact_sales_store ON fact_sales(store_id);
CREATE INDEX idx_fact_sales_date ON fact_sales(date_id);

DO $$
BEGIN
    RAISE NOTICE 'таблица фактов создана';
END $$;
