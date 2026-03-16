SELECT yn, count(*)
FROM buy_record_base as b
group by yn;

-- 리뷰 때 비율도 출력 --> 컬럼명 rate
-- 구매 전환율

select count(*)
from buy_record_base

SELECT 
    yn, 
    count(*),
    count(*)/(select count(*)from buy_record_base)*100 as rate
FROM buy_record_base as b
group by yn;

###########################################################
-- product_growth_base 기반으로
-- 성적 -> 랭킹
-- 브랜드별 모델별 성장률을 기반으로 랭킹 처리
-- 컬럼 : 브랜드, 모델, 성장률, 랭킹 (row_number()~over())
SELECT
    pgb.brand,
    pgb.model,
    sum(total_sales_2021)/sum(total_sales_2020) as growth,
    ROW_NUMBER()    OVER(PARTITION By brand order by (sum(total_sales_2021)/sum(total_sales_2020))DESC)AS RANKING
from product_growth_base as pgb
GROUP BY pgb.brand, pgb.model;

SELECT
    A.*,
    ROW_NUMBER() over(PARTITION BY A.brand ORDER BY A.growth desc) as `rank`
from 
(
    SELECT
        pgb.brand,
        pgb.model,
        sum(total_sales_2021)/sum(total_sales_2020) as growth
    from product_growth_base as pgb
    GROUP BY pgb.brand, pgb.model
) as A
;
