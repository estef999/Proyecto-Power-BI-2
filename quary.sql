WITH AllSales AS(
    SELECT * FROM SALES_2023
    UNION ALL
    SELECT * FROM SALES_2024
    UNION ALL
    SELECT * FROM SALES_2025
),
VentasPorVendedor AS (
    SELECT 
        s.[SalesPerson ID],
        c.[Region],
        SUM(s.[Qty Itens] * s.[Unit Price]) AS ventas_totales,
        DATE_TRUNC('quarter', s.[Issue Date]) AS trimestre
    FROM 
        AllSales  s
    JOIN 
        Customer c ON s.[Customer ID] = c.[Customer ID]    
    WHERE
        s.[Issue Date] >= DATE_TRUNC('quarter', CURRENT_DATE) - INTERVAL '3 months'
    GROUP BY 
        s.[SalesPerson ID], 
        c.[Region], 
        DATE_TRUNC('quarter', s.[Issue Date])
),

PromedioRegion AS (
    SELECT
        [Region],
        trimestre,
        AVG(ventas_totales) AS promedio_region
    FROM
        VentasPorVendedor
    GROUP BY
        [Region],
        trimestre
)

SELECT 
    v.[SalesPerson ID],
    v.[Region],
    v.ventas_totales,
    v.trimestre,
    p.promedio_region
FROM 
    VentasPorVendedor v
JOIN 
    PromedioRegion p 
    ON v.[Region] = p.[Region]
    AND v.trimestre = p.trimestre
WHERE
    v.ventas_totales > p.promedio_region
ORDER BY
    v.region,
    v.ventas_totales DESC