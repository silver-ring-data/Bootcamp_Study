-- <sub query>
-- 전제, 프랑스의 국가코드를 모르는 상황
-- 단, 파리라는 도시가 프랑스의 도시인 것은 안다. 혹은 특정 국가의 도시로 모른다. 복잡해짐
-- 파리 -> 도시 정보 획득 -> 국가코드 획득 -> 프랑스의 모든 도시 정보 획득

-- 1단계
-- 파리라는 도시명을 이용하여, city 테이블에서 country 값을 획득
SELECT city.`CountryCode`
from city
where city.`Name` = 'paris'
;

--  결과 1개 
-- 1단계 결과를 이용하여 해당 국가의 모든 도시 이름 추출

SELECT *
from city as c
where c.`CountryCode`= (SELECT city.`CountryCode`
                        from city
                        where city.`Name` = 'paris')
                        ;
-- result (40,5)

-- 서브 쿼리를 삽입할 때 -> 서브 쿼리문
-- 오류 발생 -> 결과값 1개와 비교하는 표현해서 2개 이상의 결과셋을 넣는다면?
SELECT *
from city as c
where c.`CountryCode`= (SELECT city.`CountryCode`
                        from city
                        where city.`District`='new york')
                        ;
-- 하나랑 비교해야되는데 누구랑 비교해야되는지 확인할 수 없음

-- 해결 : 후보 중 최소 한개라도 선택해서 만족하면 ok -> any/some
-- 해결 : 후보 중 조건이 모두 만족하는 것들만 -> all

-- ANY|SOME (최소 하나라도 만족하면 OK)
-- 뉴욕주에 
-- 포함된 모든 도시들의 인구수들보다 큰 인구수를 
-- 가진 모든 도시의 정보를 가져오시오

-- 뉴욕주에 가장 작은인구를 가진 도시보다 큰 인구수를 가진 전세계 도시 정보를 획득하시오
-- 비교 대상이 수치형이면 >,<
SELECT *
from city as c
where c.`Population`> ANY (SELECT c.`Population`
                        from city as c
                        where c.`District`='new york')
                        ;
-- result : (3782,5)

-- 뉴욕주가 속한 도시의 국가코드와 일치하는 것이 하나라도 있다면 -> 미국의 모든 도시
-- 범주형은 =를 주로 사용
SELECT *
from city as c
where c.`CountryCode`= SOME (SELECT c.`CountryCode`
                        from city as c
                        where c.`District`='new york')
                        ;

-- result : (274, 5)

-- ALL
-- 서브 쿼리의 모든 결과셋보다 크면 
SELECT *
from city as c
where c.`Population`> ALL (SELECT c.`Population`
                        from city as c
                        where c.`District`='new york')
                        ;
-- result : (9,5)

-- <ORDER BY>
SELECT *
from city as c
ORDER BY c.`Population` asc
;

SELECT *
from city as c
ORDER BY c.`Population`
;

SELECT *
from city as c
ORDER BY c.`Population` DESC
;

-- 인구수 내림차순, 국가코드는 오름차순
-- BUT, 2차 정렬이 거의 의미가 없음 -> 인구가 동일한 경우가 거의 없다
SELECT *
from city as c
ORDER BY c.`Population` DESC, c.`CountryCode` ASC
;

-- 범주형으로 먼저 -> 그다음 수치형 정렬
SELECT *
from city as c
ORDER BY c.`CountryCode` ASC, c.`Population` DESC
;

-- 인구는 내림차순 정렬
-- 한국 도시만 대상
-- 대상 결과셋에서 모든 컬럼 추출
SELECT *
from city as c
WHERE c.`CountryCode` = 'KOR'
ORDER BY c.`Population` DESC
;

SELECT country.`Name`, country.`SurfaceArea`
from country
ORDER BY country.`SurfaceArea` DESC
;

-- <SELECT ~ DISTINCT ~ FROM ~> 
-- city 테이블에서
-- 국가코드를 기반으로 오름차순 정렬
-- 출력은 국가코드만 중복되지않게 출력 -> 국가별로 1개씩만 출력
select DISTINCT city.`CountryCode`
from city
order by city.`CountryCode` ASC
;
-- result (232,1)

-- <LIMIT>
-- 상위 TOP 10만 출력 

select c.`Name`, c.`SurfaceArea`
from country as c
ORDER BY c.`SurfaceArea` DESC
LIMIT 10 -- 처음부터 10개까지
;

-- 페이징
-- n번위치에서 m개를 추출
select c.`Name`, c.`SurfaceArea`
from country as c
ORDER BY c.`SurfaceArea` DESC
LIMIT 10,10 -- 처음부터 10개까지
;

-- <GROUP BY>
-- city 테이블에서
-- 국가(코드)별로 그룹화하여
-- 국가 코드, 최소인구수(그룹화 후 파생 변수 생성됨 -> 1회 쿼리가 수행된 이후 2차성,단, 별칭으로 min_popu)를 출력
-- 해당 데이터는 인구순으로 정렬, 오름차순 정렬
-- 상위 탑 10개의 국가만 출력

-- bug : 집계 대상이 되는 컬럼만 선택이 가능 : c.name x
SELECT c.`CountryCode`, c.`Name`
from city as c
group by c.`CountryCode`;

SELECT c.`CountryCode`, MIN(c.`Population`) as min_popu
from city as c
group by c.`CountryCode`
ORDER BY min_popu ASC
LIMIT 10
;

-- 국가별 도시 인구 평균을 구해서, 내림차순 정렬

-- 상위 탑 5위부터 10개 국가 정보를 출력

-- 출력값 국가코드, 평균인구수(avg_popu)

SELECT c.`CountryCode`, AVG(c.`Population`) as avg_popu
from city as c
group by c.`CountryCode`
ORDER BY avg_popu ASC
LIMIT 4, 10


-- 자동차 모델 기준으로 그룹화하여 -> 평균 가격 및 모델을 출력하시오.
desc car_product;
-- car_order, car_detail 등등 조인하여 -> 모델별 특정 기간동안 평균 매출
desc car_orderdetail;

-- <having>
-- 국가 별 집계
-- 국가 내 존재하는 도시들 중 최대 인구수를 추출
-- 최대 인구수 기준 내림 차순
-- 출력 : 국가 코드, 최대 인구수 (max_popu)

-- result = (6,2)

SELECT c.`CountryCode`, MAX(c.`Population`) as max_popu 
from city as c
where c.`Population` >= 9000000
group by c.`CountryCode` 
ORDER BY max_popu desc;

-- where 사용해서 같은 결과
SELECT *
from (
    SELECT c.`CountryCode`, MAX(c.`Population`) as max_popu 
    from city as c
    group by c.`CountryCode` 
) as tmp
where tmp.max_popu >= 9000000
ORDER BY max_popu desc
;

-- 리뷰
-- 한국, 미국, 중국, 일본, 프랑스 국가들중에서
-- 국가별 도시 수가 30개 이상, 최대 인구수가 8000000 이상인 국가를 대상으로
-- 출력 : 국가코드, 최대인구수, 국가별도시수 <- 컬럼명


-- <roll up>
-- 같은 국가코드를 가진 도시들의 인구수를 합산
-- 국가별로 도시데이터를 보여주고 해당 국가 데이터의 마지막 부분에 합산 인구수를 표현
-- 출력 : 국가코드, 도시명, 인구수 합산
select city.`CountryCode`, city.`Name`, sum(city.`Population`) as sum_popu
from city
group by city.`CountryCode`, city.`Name` with ROLLUP
-- sum 없이어떻게 표현할지?

-- <join> --
-- 결합하는 테이블간 관계가 존재한다. <-> 관련없다
-- city, countrycode, countrylanguage를 이용하여 조인

select count(*) from city; -- 4079
select count(*) from country; -- 239
select count(*) from countrylanguage; -- 984

-- city(왼), country(오) 테이블 조인
-- 출력 각각 테이블의 모든컬럼 대상
-- 결합 조건(on) : 국가코드가 일치 -> inner join 하면 1개의 레코드(데이터)로 구성

SELECT *
from city as c
JOIN country as co
on c.`CountryCode` = co.`Code`
;
-- result : 4079, 5+15
-- 컬럼 내 중복 데이터가 존재 (국가코드)
-- 불필요한 컬럼도 존재 가능
--> 필요한 것만 추출해야함

--필요한 데이터 : 도시명, 국가코드, 도/주(district), 인구수, 국가면적
SELECT 
    c.`Name` as 도시명, 
    c.`Population` as 인구수,
    co.`SurfaceArea` as 국가면적, 
    co.`Code` as 국가코드, 
    c.`District` as District
from city as c
JOIN country as co
on c.`CountryCode` = co.`Code`
;

-- 한국 국가코드를 기반으로
-- 사용중인 모든 언어 정보 추출
-- countrylanguage
select *
from countrylanguage as lang
where lang.`CountryCode` = 'KOR';

select *
from countrylanguage as lang
where lang.`CountryCode` = 'JPN';

-- city, country, countrylanguage 순으로 join 하시오
SELECT * -- count(*)
from city as c
JOIN country as co          on c.`CountryCode` = co.`Code`
JOIN countrylanguage as cl  on c.`CountryCode` = cl.`CountryCode`

-- result : (30670, 5 + 15 + 4)

-- <LEFT JOIN>
-- 4079,5 결과
-- 대상 : CITY, COUNTRY
-- 컬럼 : 도시명, 
SELECT 
    c.`Name`, c.`CountryCode`, c.`District`, c.`Population`, co.`SurfaceArea`
from city as c
left join country as co 
on c.`CountryCode` = co.`Code`;
-- result : (4079, 5)

-- < right join>
SELECT 
    c.`Name`, c.`CountryCode`, c.`District`, c.`Population`, co.`SurfaceArea`
from city as c
right join country as co 
on c.`CountryCode` = co.`Code`;
-- result : (4086, 1)

-- car_xxx 테이블 대상으로 조인 진행 -> 데이터 마트 -> 이를 기반으로 extract 진행
-- 자동차 주문 데이터 관련
-- 추출 내용
-- 제품 코드, 수량, 가격, 구매액, 브랜드, 모델, 대리점주소, 성별, 나이, 고객주소, 가입일

select *
from car_product;

SELECT *
from car_order;

select *
from car_store;

select *
from car_orderdetail;

select *
from car_member;


-- create View car_mart as -- 가상 데이터 마트
select
    A.*,
    or_d.prod_cd,
    or_d.quantity,
    pd.price,
    or_d.quantity *cast(REPLACE(pd.price, ',', '') as UNSIGNED) as sales_cost,
    pd.brand,
    pd.model,
    st.store_addr,
    mem.gender,
    mem.age,
    mem.addr
from car_order as A
left join car_orderdetail as or_d on A.order_no = or_d.order_no
left join car_member as mem on A.mem_no = mem.mem_no
left join car_product as pd on or_d.prod_cd = pd.prod_cd
left join car_store as st on A.store_cd = st.store_cd;

-- result : 4176 --> order보다 더 많음 왜 그런지?

-- , 제거 하는법
SELECT cast(REPLACE(price, ',', '') as UNSIGNED) as sales_cost
from car_product
limit 2
;

-- <UNION>
-- 도시명, 인구수 출력
-- 한국만
-- 인구수 9백만 이상 -> 결과셋1
-- 인구수 8십만 이상 -> 결과셋2

SELECT c.`Name`, c.`Population`
from city as c
WHERE c.`CountryCode` = 'KOR' AND c.`Population` >= 9000000
UNION
SELECT c.`Name`, c.`Population`
from city as c
WHERE c.`CountryCode` = 'KOR' AND c.`Population` >= 800000
;
-- result (8,2) 서울은 한번 등장

SELECT c.`Name`, c.`Population`
from city as c
WHERE c.`CountryCode` = 'KOR' AND c.`Population` >= 9000000
UNION all
SELECT c.`Name`, c.`Population`
from city as c
WHERE c.`CountryCode` = 'KOR' AND c.`Population` >= 800000
;
-- result (9,2) 서울 두번 등장

-- 종합
-- [문제 1]
-- car_product 테이블 대상으로 모델별 자동차 판매액, 주문 건수 구하시오
-- 출력 : model, 자동차 판매액, 주문건수
-- 주문건수 기준 내림차순 정력

-- [문제 2]
-- car_product, car_orderdetail 등 테이블을 이용하여
-- 모델명, 주문수, 총 주문액, 평균주문액 출력

-- <문자열 특수 연산자>
-- country 테이블에서 국가명에 kor이 들어있다면 (검색) 모두 추출하시오
-- 존재 하기만 하면 다 검색됨

select *
from country
where country.`Name` LIKE '%kor%'
;

select *
from country
where country.`Name` LIKE '%ea'
;

select *
from country
where country.`Name` LIKE 'sou%'
;

-- 한국면적 기준 -> 동일 면적 비율이 1.0, 1.0 이상인 국가 -> 한국보다 땅이 큰 국가들
-- 한국 면적 기준 1.0보다 큰 국가들의 국가코드, 이름, 비율을 구하시오
SELECT c.`SurfaceArea`
from country as c
where c.`Code` = 'KOR'
;

-- 모든 국가의 면적, 국가 코드 출력
SELECT
    c.`Name`,
    c.`SurfaceArea` / (SELECT c.`SurfaceArea`
                    from country as c
                    where c.`Code` = 'KOR') as std_area
from country as c
having std_area >= 1
order by std_area desc
;
