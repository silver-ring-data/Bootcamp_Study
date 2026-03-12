-- 데이터 베이스 목록 출력

show databases;

-- 특정 데이터베이스 사용
-- use 디비명

use t1;
-- 간혹 값이 키워드인 경우도 있다 -> 구분용 -> 값으로 인지함 -> '값'
use 't1';

-- 해당 데이터베이스에 소속한 모든 테이블을 보여줘라
show TABLEs; 

desc city;

----------------------------------------------------------------------------------------------------------
-- 1. SELECT ~ FROM
-- t1 디비에 city 테이블에서 
-- 모든 데이터를 가져오시오.
SELECT *
FROM city
;
-- result : (4079,5) : (1차원 개수 = 데이터수), 2차원 개수 = 컬럼수 | 피처수

-- 특정 컬럼 1개만 추출하시오 : city 테이블에서 name 컬럼값만 모두 추출하시오
SELECT `Name`
FROM city
;
-- result :(4079, )

-- 컬럼명의 출처 기재 -> n개 테이블을 조인할 때 같은 이름의 컬럼이 다수 존재하면 유용하게 활용
SELECT city.`Name`
FROM t1.city;

-- 컬럼 2개 추출 -> 컬럼 n개 가능
-- 컬럼, 컬럼 -> 나열한다. 
-- population, name
SELECT city.`Population`, city.`Name`
FROM t1.city;
-- result : (4079,2)

-- 별칭 : as
SELECT city.`Population` as popu, city.`Name`
FROM t1.city;

-------------------------------------------------------------------------------------------------------------
-- 2. SELECT ~ FROM ~ WHERE ~
-- 인구수가 5,000,000이상 되는 도시 데이터를 모두 추출
-- 모든 컬럼을 출력하시오
SELECT * 
FROM t1.city 
WHERE t1.city.`Population` >= 5000000
;

-- 인구수 5백만이상이고, 6백만 이하인
-- 모든 도시의 정보를 추출
SELECT * 
FROM t1.city 
WHERE t1.city.`Population` >= 5000000 AND t1.city.`Population` <= 6000000
;
-- result : (4,5)

-- 위의 동일 쿼리에서, 이 조건을 만족하는 도시수를 구하시오
-- 컬럼 x, 결과셋의 개수를 구하라 -> 특수 기능 -> 함수 (count() )
-- 개수는 cnt라는 이름으로 추출하시오 -> 별칭 as cnt
SELECT COUNT(*) as cnt
FROM t1.city 
WHERE t1.city.`Population` >= 5000000 AND t1.city.`Population` <= 6000000
;
-- result : (1,2)

-- 도시의 인구수가 1780000이 아닌 도시의 총수를 구하시오
-- 결과셋의 총 도시수는 값으로 4078로 나오면 됨
-- 카운트는 동일하게 cnt로 표기함
SELECT COUNT(*) as cnt
FROM t1.city 
-- WHERE t1.city.`Population` <> 1780000
WHERE t1.city.`Population` != 1780000
;

-- city 테이블에서
-- 국가코드가 한국(KOR)이거나, 미국(USA)인
-- 모든 도시 정보를
-- 추출하시오
SELECT *
FROM t1.city 
-- WHERE t1.city.`Population` <> 1780000
WHERE t1.city.`CountryCode` = 'KOR' OR t1.city.`CountryCode` = 'USA'
;
-- result : (344, 5)

-- city 테이블에서
-- 한국도시들 중, 인구수가 백만이상인 : 범주형, 수치형 데이터를 동시 비교
-- 모든 도시 정보를
-- 추출하시오
SELECT *
FROM t1.city AS C
-- WHERE t1.city.`Population` <> 1780000
WHERE C.`CountryCode` = 'KOR' AND C.`Population` >= 1000000
;
-- result : (7,5)
SELECT *
FROM t1.city AS C
-- WHERE t1.city.`Population` <> 1780000
WHERE C.`Population` >= 1000000 AND C.`CountryCode` = 'KOR'
;
-- 조건의 배치에 따라 수행 시간이 상이함


-------------------------------------------------------------------------------------------------\
-- 3. SELECT ~ FROM ~ WHERE ~ BETWEEN ~
-- 인구수 5백만이상이고, 6백만 이하인
-- 모든 도시의 정보를 추출 (BETWEEN 사용)
SELECT * 
FROM t1.city 
WHERE t1.city.`Population` 
BETWEEN 5000000 AND 6000000
-- result = (4,5)

-- 4. SELECT ~ FROM ~ WHERE ~ IN ~
-- CITY 테이블에서
-- 도시명이 서울, 부산, 인천 중에 하나라도 일치하면
-- 해당 도시의 모든 정보를 추출하시오
SELECT * 
FROM t1.city 
WHERE t1.city.`Name` in ('Seoul', 'Pusan', 'inchon')
;

-- city 테이블에서
-- 한국 미국, 일본, 프랑스에 속한
-- 모든 도시 정보를 구하시오.
SELECT COUNT(*) AS city_count
FROM t1.city 
WHERE t1.city.`CountryCode` in ('KOR', 'USA', 'JPN', 'FRA')
;
-- result = 632

-- 위 쿼리를 참고해서
-- 도시명, 인구수를 출력
SELECT t1.city.`Name` as '도시명', t1.city.`Population` as '인구수'
FROM t1.city
WHERE t1.city.`Population` >= 6000000 and t1.city.`CountryCode` in ('KOR', 'USA', 'JPN', 'FRA');
-- result = (3,2)
