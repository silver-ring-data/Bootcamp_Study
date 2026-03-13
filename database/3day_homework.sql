-- 리뷰
-- 1. 비교값의 수치값을 서브 쿼리로 구성
-- 2. sa_flag로 그룹화 하여 그룹의 대표값으로 sa_flag와 인구평균값, 면적평균 출력
select
    c.`Code`, c.`Name`, c.`SurfaceArea`,
    -- SurfaceArea(수치형) -> 구간화 -> 범주형데이터로 -> 고유값 부여
    case
    when c.`SurfaceArea` < 1075 then '홍콩보다작은'
    when c.`SurfaceArea` BETWEEN 1075 and 99434 then '홍콩과한국사이'
    else '한국보다큰' end
    as sa_flag
from country as c
;

-- 위 결과셋을 기반으로 그룹화 가능 -> 그룹별 분석, 등등 데이터 구성 가능
-- sa_flag와 인구평균값, 면적평균 출력
SELECT
    sub.sa_flag, AVG(sub.`Population`), AVG(sub.`SurfaceArea`)
FROM (select
    c.`Code`, c.`Name`, c.`SurfaceArea`, c.`Population`,
    case
    when c.`SurfaceArea` < 1075 then '홍콩보다작은'
    when c.`SurfaceArea` BETWEEN 1075 and 99434 then '홍콩과한국사이'
    else '한국보다큰' end
    AS sa_flag
from country as c) as sub
group by sub.sa_flag
;



#################################
create VIEW total_kor_view
AS
SELECT
    B.`Name`, C.`SurfaceArea`, B.`Population`, A.Language
from (select
            cl.`CountryCode`, cl.`Language`
      from countrylanguage as cl
      where cl.`CountryCode`='KOR' and cl.`Language`='Korean'
     ) AS A
join city as B    on A.CountryCode=B.`CountryCode`
JOIN country as C on A.CountryCode=C.`Code`
;
-- (70, 4)
-- 리뷰 -> 서브쿼리를 제외하고 countrylanguage 사용, where 이용 테스트
--      -> city countrylanguage를 조인한후 where 사용하는 테스트 -> country 조인


-- 특정(수) 목적으로 구성된 데이터셋(가상`테이블`) total_kor_view를 이용하여 분석 진행
select *
from total_kor_view
;

###################################################################
-- 리뷰 -> 비율로 계산하여 표기하기
select user_profile_base.gender, count(DISTINCT mem_no)/(select count(DISTINCT mem_no)from user_profile_base)*100 as mem_per
from user_profile_base
group by user_profile_base.gender with ROLLUP
order by mem_per;
