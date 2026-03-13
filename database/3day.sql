##################
# 함수 - 문자열 처리
#################
-- 한글은 문자당 길이값이 3임 (mysql) 
--> 테이블 설계시 한글 입력시 길이 계산 검토
SELECT 
    LENGTH('hi'), LENGTH('HI'),
    LENGTH('가나'), -- 한글은 문자당 길이값이 3임 (mysql) -> 테이블 설계시 한글 입력시 길이 계산 검토
    LENGTH('12'), LENGTH('!@')
;

### LENGTH
-- city 테이블에서 컬럼의 길이를 체크
-- 컬럼의 길이를 체크
SELECT
    c.`Name`, LENGTH(c.`Name`) size1,
    c.`Population`, LENGTH(c.`Population`)
from city as c
LIMIT 5
;

### CONCAT
SELECT
    CONCAT('hello', '-', 'world'), -- 일반적
    CONCAT('hello', null, 'world'), -- null 하나라도 존재하면 모두 null
    CONCAT('hello', 123, 'world') -- 수치로 문자열 취급함
    ;


SELECT
    concat(city.`Name`, '-', city.`Population`)
from city
LIMIT 2
;

### LOCATE
SELECT 
    LOCATE('W', 'WORLD'),
    LOCATE('OR', 'WORLD'),
    LOCATE('Z', 'WORLD')
    ;
-- city 테이블에서
-- se로 시작하는 도시를 모두 찾아서
-- 그 위치값을 계산후 1<=위치값<=3 인 도시만 추출하여
-- 도시명, 위치값을 출력하시오
SELECT 
    c.`Name`, LOCATE('SE',c.`Name`) as lon
from city as c
having lon BETWEEN 1 and 3
;

### LEFT(), RIGHT()
SELECT
    LEFT('helloworld', 3),
    RIGHT('helloworld', 3)
;

SELECT
    LEFT(name, 3),
    name,
    RIGHT(name, 3),

    LEFT(city.`Population`, 3),
    city.`Population`,
    RIGHT(city.`Population`, 3)
from city
limit 5
;

### UPPER(), LOWER()
SELECT
    name,
    LOWER(name),
    UPPER(name),
    lower('aA가1!')
from city
;

### REPLACE
SELECT
    city.`Population`,
    REPLACE(city.`Population`,'0','-')
from city
;

### trim
SELECT
    TRIM('  AB  '),
    TRIM('    AB'),
    TRIM('AB    '),
    TRIM(BOTH      '@' FROM '@@@ a @@@'),
    TRIM(LEADING   '@' FROM '@@@ a @@@'),
    TRIM(TRAILING  '@' FROM '@@@ a @@@')
    ;

### FORMAT
SELECT
    FORMAT(1232413.124124,3),
    FORMAT(1232413.124124,4),
    FORMAT(1232413.124124,0) -- 정수 형태로 반환 -> 타입은 문자열임 (VARCHAR)
;

SELECT
    city.`Population`,
    FORMAT(city.`Population`, 0) as f_popu
from city

### substring
SELECT
    city.`Name`,
    SUBSTRING(city.`Name`, 1, 3)
from city
;

################
# 수학/통계 함수
################

-- 올림, 내림, 반올림
SELECT
    floor(3.14195),
    ceil(3.14195),
    round(3.14195),
    floor(3.876),
    ceil(3.876),
    round(3.876)
    ;

-- 제곱근
SELECT
    sqrt(4),
    pow(2,3),
    exp(3),
    log(20.23423424),
    log(exp(3))
    ;
-- 삼각함수
SELECT
    pi(),
    sin(pi()/2),
    cos(pi()/2),
    tan(pi()/2);

-- 절댓값, 랜덤, 표준편차, 분산
-- 국가 내 도시간 인구수의 분산 표준편차
--> 대도시, 중소 도시간 인구수의 불평등한 지표 체크

SELECT
city.`CountryCode`,
STD(city.`Population`) as st,
VARIANCE(city.`Population`) as va,
COUNT(city.`CountryCode`) as cnt
from city
GROUP BY `CountryCode`
HAVING cnt >=50
ORDER BY st asc;

-- 시간 함수 (런던 기준)
SELECT NOW(), curdate(), CURTIME()
;
-- curdate()
select left(CURDATE(),7), left(curtime(),5);

SELECT now(),
    date(now()), MONTH(now()), DAY(now()),
    HOUR(now()), MINUTE(now()), SECOND(now()),
    MONTHNAME(now()), DAYNAME(now()),
    DAYOFWEEK(now()), DAYOFMONTH(now()), DAYOFYEAR(now());

-- date_format()
select DATE_FORMAT(now(), '%y %m %D, %j, %s')

-- datediff
select 
    DATEDIFF(now(),'2026-02-25'),
    DATEDIFF( '2026-02-25', now())
;

#############################
# 형변환 함수
##############################

SELECT
    cast('123'      as unsigned),
    cast(1          as char(1)),
    cast(20260313   as date),
    cast('20260313' as date)
    ;

##################
# 랭킹
#################

-- row_number, rank, dense_rank
select 
    co.mem_no,
    co.order_date,
    ROW_NUMBER()    OVER(order by order_date asc) AS RANK1,
    RANK()          OVER(order by order_date asc) AS RANK2,
    DENSE_RANK()    OVER(order by order_date asc) AS RANK3
from car_order as co;

-- partition by
-- 개인별 주문서를 그룹화
select 
    co.mem_no,
    co.order_date,
    ROW_NUMBER()    OVER(PARTITION By mem_no ORDER BY order_date asc) AS RANK1,
    RANK()          OVER(PARTITION By mem_no ORDER BY  order_date asc) AS RANK2,
    DENSE_RANK()    OVER(PARTITION By mem_no ORDER BY  order_date asc) AS RANK3
from car_order as co;

#################
# 기타 : 
################

-- 면적 기준 -> 구간화 -> 파생변수 생성 (홍콩보다 작은/홍콩~한국/한국보다 큰)
CASE 
    WHEN country.`SurfaceArea` THEN  ''
    WHEN 조건 THEN  ''
    ELSE 
END
as sa_flag;

SELECT country.`Code`
from country
WHERE country.`Code` = 'HKG';

SELECT country.`SurfaceArea`
from country
where country.`Code` = 'KOR'

SELECT
    c.`Code`, c.`Name`, c.`SurfaceArea`,
    -- `SurfaceArea`수치형 -> 구간화 -> 범주형 데이터로 -> 고유값 부여
    CASE 
        WHEN c.`SurfaceArea` < 1075 THEN '홍콩보다작은'
        WHEN c.`SurfaceArea` BETWEEN 1075 and 99434 THEN '한국~홍콩'
        ELSE  '한국보다큰'
    END
from country as c


###################################################################################################################
# DDL
##################################################################################################################

# CREATE VIEW 뷰이름 AS 결과셋(SELECT ~)


-- 요구사항
-- 뷰 이름이 total_kor_view인 뷰를 구성하시오
-- 결과셋은 city, country, countrylanguage 조인한 결과
-- 한국에 대한 정보만 대상으로 함, 한국어만 대상
-- 컬럼은 도시명, 면적, 인구수, 랭귀지(언어), 원래 컬럼명으로 출력

--create View total_kor_view as

SELECT
cl.`CountryCode`, cl.`Language`
from countrylanguage as cl
where cl.`CountryCode` = 'KOR' and cl.`Language` = 'Korean';


create View total_kor_view as
SELECT 
    B.`Name`, 
    C.`SurfaceArea`, 
    B.`Population`, 
    A.`Language`
from (SELECT
    cl.`CountryCode`, cl.`Language`
    from countrylanguage as cl
    where cl.`CountryCode` = 'KOR' and cl.`Language` = 'Korean') as A
JOIN city as B on A.`CountryCode` = B.`CountryCode`
JOIN country as C on A.`CountryCode` = C.`Code`
;
-- 가상 테이블 확인
select *
from total_kor_view;

# alter view
##########################################3
# DATA_MART 실습 - CAR_MART
############################################

-- 자동차 판매 데이터에 대한 데이터마트 -> 가상테이블
-- car_xxx 테이블(총 5개) 대상으로 조인 진행(*) -> 데이터마트 -> 이를기반으로 Extract 진행
-- 자동차 주문 데이터 관련
-- 추출 내용
-- 주문마스터정보, 제품코드, 수량, 가격, 구매액(수량*가격), 브랜드, 모델, 대리점주소, 성별, 나이, 고객주소, 가입일
-- 실습 6분
-- `car_order 중심으로 조인함`  -> 데이터수가 car_order과 동일 -> left join 진행
-- 결과셋 (4094, 11)
create View car_mart as
SELECT
    A.*,
    B.prod_cd,
    B.quantity,
    C.price,
    -- 구매액 -> ,를 제거, 정수변환 : 함수 -> 수량*가격,
    B.quantity * CAST(REPLACE(C.price, ',', '') AS UNSIGNED) as sales_cost,
    C.brand,
    C.model,
    D.store_addr,
    E.gender,
    E.age,
    E.addr,
    E.join_date
FROM car_order AS A
LEFT JOIN car_orderdetail AS B ON A.order_no=B.order_no
LEFT JOIN car_product     AS C ON B.prod_cd =C.prod_cd
LEFT JOIN car_store       AS D ON A.store_cd=D.store_cd
LEFT JOIN car_member      AS E ON A.mem_no  =E.mem_no
;

SELECT * FROM car_mart LIMIT 2;

create View user_profile_base as
select *, 
CASE 
    WHEN age < 20 THEN '20대 미만'
    WHEN age BETWEEN 20 and 29 THEN '20대'
    WHEN age BETWEEN 30 and 39 THEN '30대'
    WHEN age BETWEEN 40 and 49 THEN '40대'
    WHEN age BETWEEN 50 and 59 THEN '50대'
    ELSE  '60대 이상'
END as age_band
from car_mart as c;

-- 세대별 고객수 출력
select user_profile_base.age_band, count(DISTINCT mem_no) as mem_count
from user_profile_base
group by user_profile_base.age_band with ROLLUP
order by mem_count;

-- 회원 테이블의 총 데이터 수 단수비교

select count(*) from user_profile_base; -- 4176
-- 고객 수와 user_profile_base의 데이터수가 차이나는 이유? > 중복제거 필요
-- ex. 1명이 2번이상 주문한 경우를 제거해야함

-- 중복 제거 했더니 3977 -> 주문서 기준이니, 주문하지 않은 고객수와 원래 고객수(4094)와 차이가 난다.

-- 젠더 별 고객수, 중복 고객 제거
-- 출력 : 젠저, 고객수
select user_profile_base.gender, count(DISTINCT mem_no) as mem_count
from user_profile_base
group by user_profile_base.gender with ROLLUP
order by mem_count;

-- 리뷰 -> 비율로 계산하여 표기하기

-- 젠더 & 세대 별 구매수
select upb.gender, upb.age_band, count(DISTINCT mem_no) as mem_count
from user_profile_base as upb
group by upb.gender, upb.age_band with ROLLUP
-- order by mem_count;

-- 년도 기준 추가 2020,2021
select 
    upb.gender, 
    upb.age_band, 
    count(DISTINCT case when YEAR(upb.order_date) = 2020 then mem_no END) as mem_count_20,
    count(DISTINCT case when YEAR(upb.order_date) = 2021 then mem_no END) as mem_count_21
from user_profile_base as upb
group by upb.gender, upb.age_band with ROLLUP

--> 2021년에 구매력이 전세대, 전젠더에서 상승
-- 다만, 상승비율을 상이함, 50대는 거의 2배, 60대는 1.5배정도 상승한 것이 확인됨.

#####
/*
- car_mart → 데이터 추출 → rfm_Base 뷰 구성
- 컬럼 구성
    - mem_no
    - 고객별 총 구매액 : total_amt
    - 고객별 구매횟수(빈도) : total_fr
    - 조건
        - 2020 ≤ 기간 ≤ 2021 (2년간 데이터 기준, 월 고려x)*/

create View rfm_Base as
SELECT 
    c.mem_no,
    sum(c.sales_cost) as total_amt,
    count(c.order_no) as total_fr
from car_mart as c
where YEAR(c.order_date) BETWEEN 2020 and 2021
group by c.mem_no;

-- 총 구매액이 높은 순 -> 낮은 순
select *
from rfm_Base
ORDER BY `rfm_Base`.total_amt desc
Limit 10;

/*
- VVIP : 구매금액이 20억 이상 and 구매빈도 3회 이상
- VIP : 구매금액이 10억 이상 and 구매빈도 2회 이상
- GOLD : 구매금액이 5억 이상
- SILVER : 구매금액이 3억 이상
- BRONZE : 구매빈도 1회, 기본값(구매만하면)
- STONE : 그냥 가입한 고객
요구사항
rfm_base_level 가상테이블(뷰) 생성
컬럼
level : 등급
car_member의 모든 컬럼 -> rfm_base과 조인
rfm_base의 총구매액, 총구매빈도*/

--create View rfm_Base_Level as
select
    CASE 
        WHEN (b.total_amt >= 2000000000) AND (b.total_fr = 2) THEN 'VVIP'
        WHEN (b.total_amt BETWEEN 1000000000 AND 2000000000) AND (b.total_fr = 2) THEN 'VIP'
        WHEN b.total_amt BETWEEN 500000000 AND 1000000000 THEN 'GOLD'
        WHEN b.total_amt BETWEEN 300000000 AND 500000000 THEN 'SILVER'
        WHEN b.total_fr = 1 THEN 'BRONZE'
        ELSE 'STONE'
    END as level,
    car_member.*,
    b.total_amt,
    b.total_fr
from rfm_Base as b
LEFT JOIN car_member on b.`mem_no` = car_member.`mem_no`
ORDER BY level DESC
;
