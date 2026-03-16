create View rfm_base as
SELECT 
    c.mem_no,
    sum(c.sales_cost) as total_amt,
    count(c.order_no) as total_fr
from car_mart as c
where YEAR(c.order_date) BETWEEN 2020 and 2021
group by c.mem_no;

CREATE view rfm_base_level as
SELECT
    A.*,
    B.total_amt,
    B.total_fr,
    CASE
        WHEN B.total_amt >= 2000000000 AND B.total_fr >=3  THEN 'VVIP'
        WHEN B.total_amt >= 1000000000 AND B.total_fr >=2 THEN 'VIP'
        WHEN B.total_amt >=  500000000 THEN 'GOLD'
        WHEN B.total_amt >= 300000000 THEN 'SILVER'
        WHEN B.total_fr >=1 THEN 'BRONZE'
        ELSE 'STONE'
    END as level
from car_member as A
join rfm_base as B
    ON A.mem_no=B.mem_no
;
-- 등급별 `총인원수`, `총구매액합산`, `평균총구매액`, `평균구매빈도` 집계
-- 출력 : 등급, 위의 항목
select 
    r.level, 
    count(r.mem_no) as '총인원수', 
    sum(r.total_amt) as '총구매액합산', 
    avg(r.total_amt) as '평균총구매액', 
    avg(r.total_fr) as '평균구매빈도'
from rfm_base_level as r
GROUP BY r.level
order by 평균총구매액 DESC
;

--create View buy_record_base as
SELECT DISTINCT A.mem_no
from car_mart as A
WHERE YEAR(A.order_date) = 2020;

SELECT DISTINCT A.mem_no
from car_mart as A
WHERE YEAR(A.order_date) = 2021;

SELECT
    A.mem_no as ori_2020_mem_no,
    B.mem_no as ori_2021_mem_no
    -- CASE 
    --     WHEN  THEN 'Y' 
    --     ELSE  
    -- END
FROM
    (SELECT DISTINCT A.mem_no
    from car_mart as A
    WHERE YEAR(A.order_date) = 2020) as A
LEFT JOIN 
    (SELECT DISTINCT A.mem_no
    from car_mart as A
    WHERE YEAR(A.order_date) = 2021) as B
    ON A.mem_no = B.mem_no

-- 2020 구매자 데이터는 그대로 두고, 2021 구매자 데이터와 left join 진행
-- 2020 구매자 데이터 유지 + 2021 구매자는 일치하면 세팅, 없으면 NULL (2021년도 구매 X)이 됨

ALTER View buy_record_base as
SELECT
    A.mem_no as ori_2020_mem_no,
    B.mem_no as ori_2021_mem_no,
    CASE 
        WHEN B.mem_no is NOT NULL THEN 'Y' 
        ELSE 'N'
    END as yn
FROM
    (SELECT DISTINCT A.mem_no
    from car_mart as A
    WHERE YEAR(A.order_date) = 2020) as A
LEFT JOIN 
    (SELECT DISTINCT A.mem_no
    from car_mart as A
    WHERE YEAR(A.order_date) = 2021) as B
    ON A.mem_no = B.mem_no

-- 2020 구매자 중, 2021에도 구매한 사람 몇명
SELECT yn, count(*)
FROM buy_record_base as b
group by yn;

-- 리뷰 때 비율도 출력 --> 컬럼명 rate
-- 구매 전환율

##### 구매주기
--구매주기 : (최근 구매일 - 최초 구매일)/(구매총횟수-1)

create view buy_cycle_base AS
select
    A.store_cd,
    min(A.order_date) as mix_order_date,
    MAX(A.order_date) as max_order_date,
    count(DISTINCT A.order_no) -1 as total_order_fr_cnt
from car_mart as A
group by A.store_cd
having total_order_fr_cnt >= 2 -- 2건 이상
;

-- 구매 주기율 추출
-- (최근 - 최초)/(건수 -1) 계산
-- buy_cycle_base 이용 추출
-- 컬럼
select 
    A.*,
    DATEDIFF(A.max_order_date,A.mix_order_date)/A.total_order_fr_cnt as buy_cycle
from buy_cycle_base as A

-- 구매 주기율 값이 낮은 것이 좋은 것


################
# 제품 성장률
-- -- CREATE VIEW product_growth_base AS
-- 모델, 브랜드
-- 년도별(2020, 2021) 판매액(총액)
-- total_sales_2020, total_sales_2021
create VIEW product_growth_base as
SELECT 
    C.model,
    C.brand,
    sum(CASE 
        WHEN YEAR(C.order_date) = 2020 THEN C.sales_cost
    END) as total_sales_2020,
    sum(CASE 
        WHEN YEAR(C.order_date) = 2021 THEN C.sales_cost
    END) as total_sales_2021
from car_mart as C
GROUP BY C.model, C.brand

-- 2020 매출 대비 2021년도 매출 -> (2021 매출)/(2020 매출) -> x.x배 상승 -> growth
-- 2020 매출 대비 2021년도 매출 -> (2021 매출)/(2020 매출)-1 -> y% 성장 -> growth_per
-- 컬럼 브랜드별, growth

SELECT 
    p.brand,
    sum(total_sales_2021)/sum(total_sales_2020) as growth,
    sum(total_sales_2021)/sum(total_sales_2020) -1 as growth_per,
FROM product_growth_base as p
GROUP BY p.brand;

-- product_growth_base 기반으로
-- 성적 -> 랭킹
-- 컬럼 : 브랜드, 모델, 성장률, 랭킹

