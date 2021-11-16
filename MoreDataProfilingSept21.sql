
*****************************************************************************
********--Base query for getting all descendants of a cancer GROUP **********
*****************************************************************************
SELECT
	ca.*,
	c.CONCEPT_NAME
FROM
	WINSHIPCARS.CONCEPT_ANCESTOR ca
INNER JOIN WINSHIPCARS.CONCEPT c ON
	ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
WHERE
	ca.ANCESTOR_CONCEPT_ID = 4112853
	----- Malignant tumor OF breast 
--AND  ca.MIN_LEVELS_OF_SEPARATION  =1
--AND ca.MAX_LEVELS_OF_SEPARATION =1 --ALL subsumes; explanation OF levels OF separation

/***************************************************************************/ 
	
SELECT
	max (relative_concepts.MIN_LEVELS_OF_SEPARATION),
	max (relative_concepts.MAX_LEVELS_OF_SEPARATION)
FROM
	(
	SELECT
		ca.*,
		c.CONCEPT_NAME
	FROM
		WINSHIPCARS.CONCEPT_ANCESTOR ca
	INNER JOIN WINSHIPCARS.CONCEPT c ON
		ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
	WHERE
		ca.ANCESTOR_CONCEPT_ID = 4112853 
	) relative_concepts
		
		--SQL ERROR. reach out to Daniel? SQL Error [933] [42000]: ORA-00933: SQL command not properly ended--
	
	
	*****************************************************************************
********--Base query for getting all descendants of a cancer GROUP **********
*****************************************************************************
SELECT
	ca.*,
	c.CONCEPT_NAME
FROM
	WINSHIPCARS.CONCEPT_ANCESTOR ca
INNER JOIN WINSHIPCARS.CONCEPT c ON
	ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
WHERE
	ca.ANCESTOR_CONCEPT_ID = 4112853 ---Malignant Tumor OF Breast 
	
	
/*****************************************************************************/
/*************************--Exploring descendants--***************************/
/*****************************************************************************/
SELECT
	c.DOMAIN_ID ,
	COUNT(c.DOMAIN_ID),
	c.CONCEPT_CLASS_ID ,
	COUNT(c.CONCEPT_CLASS_ID)
FROM
	WINSHIPCARS.CONCEPT_ANCESTOR ca
INNER JOIN WINSHIPCARS.CONCEPT c ON
	ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
WHERE
	ca.ANCESTOR_CONCEPT_ID = 4112853
GROUP BY 
c.DOMAIN_ID,
c.CONCEPT_CLASS_ID 
ORDER BY
	count(c.DOMAIN_ID)DESC
--Only returns Clinical Finding and no ICDO condition as modeled in SQL sessiOn---
	
/**********************************************************************/
	

	
SELECT
	ca.*, 
	c.CONCEPT_NAME 
FROM
	WINSHIPCARS.CONCEPT_ANCESTOR ca
INNER JOIN WINSHIPCARS.CONCEPT c ON
	ca.ANCESTOR_CONCEPT_ID = c.CONCEPT_ID
WHERE
	ca.ANCESTOR_CONCEPT_ID = 4112853 AND
	c.DOMAIN_ID = 'Condition'
	
	
	--AND c.CONCEPT_CLASS_ID -'Clinical Finding'
/*******************************************************************/
	
WITH base_query_ICDO AS 
	(
		SELECT
			ca.*,
			c.CONCEPT_NAME
		FROM
			WINSHIPCARS.CONCEPT_ANCESTOR ca
		INNER JOIN WINSHIPCARS.CONCEPT c ON
			ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
		WHERE
			ca.ANCESTOR_CONCEPT_ID = 4112853
	AND
	c.DOMAIN_ID = 'Condition'
   )
		SELECT
			co.CONDITION_CONCEPT_ID,
			COUNT(co.CONDITION_CONCEPT_ID) 
		FROM
			 WINSHIPCARS.CONDITION_OCCURRENCE co
		INNER JOIN base_query_ICDO bq_icdo ON
			co.CONDITION_CONCEPT_ID = BQ_ICDO.descendant_concept_id
		GROUP BY 
		co.CONDITION_CONCEPT_ID
		ORDER BY COUNT(co.CONDITION_CONCEPT_ID) DESC 
		
	/***************************************************************/
		--Which cancers are the most prevalent?
	/***************************************************************/
		
		
		WITH malignant_concepts AS 
	(
		SELECT
			ca.*,
			c.CONCEPT_NAME
		FROM
			WINSHIPCARS.CONCEPT_ANCESTOR ca
		INNER JOIN WINSHIPCARS.CONCEPT c ON
			ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
		WHERE
			ca.ANCESTOR_CONCEPT_ID = 443392 --Malignant neoplastic disease
			AND c.DOMAIN_ID = 'Condition'
			AND c.CONCEPT_CLASS_ID  = 'Clinical Finding'
   ), 
   unique_malignancy_per_person AS
   (
   		SELECT
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID, 
			COUNT(co.PERSON_ID) AS freq	
		FROM
			WINSHIPCARS.CONDITION_OCCURRENCE co 
			INNER JOIN malignant_concepts mc ON	
			co.CONDITION_CONCEPT_ID = mc.descendant_concept_id	
		GROUP BY 
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID	
		---515,687
   ),
  unique_malignancy_counts AS 
  (
	SELECT
		UMPP.CONDITION_CONCEPT_ID,  
		COUNT(UMPP.condition_concept_id) freq	
	FROM
		unique_malignancy_per_person umpp	 
	GROUP BY 
		UMPP.CONDITION_CONCEPT_ID	
	ORDER BY 
		count(UMPP.condition_concept_id) DESC 
  ), 
 add_concept_name AS 
 (
 	SELECT 
 		umc.condition_concept_id, 
 		c.concept_name AS condition_concept_name, 
 		umc.freq
 	FROM 
 		unique_malignancy_counts umc
 	INNER JOIN WINSHIPCARS.concept c ON	
 		umc.CONDITION_concept_id = c.CONCEPT_ID 
 )
 SELECT * FROM add_concept_name
  -- 745 --  
   
   
 
 
 WITH malignant_concepts AS 
	(
		SELECT
			ca.*,
			c.CONCEPT_NAME
		FROM
			WINSHIPCARS.CONCEPT_ANCESTOR ca
		INNER JOIN WINSHIPCARS.CONCEPT c ON
			ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
		WHERE
			ca.ANCESTOR_CONCEPT_ID = 443392 --Malignant neoplastic disease
			AND c.DOMAIN_ID = 'Condition'
			AND c.CONCEPT_CLASS_ID  = 'Clinical Finding'
   ), 
   unique_malignancy_per_person AS
   (
   		SELECT
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID, 
			COUNT(co.PERSON_ID) AS freq	
		FROM
			WINSHIPCARS.CONDITION_OCCURRENCE co 
			INNER JOIN malignant_concepts mc ON	
			co.CONDITION_CONCEPT_ID = mc.descendant_concept_id	
		GROUP BY 
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID	
		---515,687
   ),
  unique_malignancy_counts AS 
  (
	SELECT
		UMPP.CONDITION_CONCEPT_ID,  
		COUNT(UMPP.condition_concept_id) freq	
	FROM
		unique_malignancy_per_person umpp	 
	GROUP BY 
		UMPP.CONDITION_CONCEPT_ID	
	ORDER BY 
		count(UMPP.condition_concept_id) DESC 
  ), 
 add_concept_name AS 
 (
	 SELECT 
	 	umc.condition_concept_id, 
 		c.concept_name AS condition_concept_name, 
 		umc.freq
	FROM
		winshipcars.CONDITION_OCCURRENCE co 
	JOIN WINSHIPCARS.CONCEPT c ON
		co.CONDITION_CONCEPT_ID = c.CONCEPT_ID
	GROUP BY
	co.CONDITION_CONCEPT_ID ,
	C.CONCEPT_NAME 
	ORDER BY 
	COUNT(C.CONCEPT_NAME) DESC
)
 	SELECT 
 		umc.condition_concept_id, 
 		c.concept_name AS condition_concept_name, 
 		umc.freq
 	FROM 
 		unique_malignancy_counts umc
 	INNER JOIN WINSHIPCARS.concept c ON	
 		umc.CONDITION_concept_id = c.CONCEPT_ID 
 
 SELECT * FROM add_concept_name
  -- 745 --  
 
 
 
   				
		
/*****************************************************************************/
/*************************--Exploring Drop, Create, and Insert temp table--***************************/
/*****************************************************************************/
DROP TABLE SHEARN2.t_malginancy_counts;	

	
 CREATE TABLE	SHEARN2.t_malignancy_counts
 (
 condition_concept_id NUMBER (38), 
 CONDITION_concept_name varchar (255), 
 freq NUMBER (38)
 ); 

--Insufficient Privileges

INSERT INTO SHEARN2 t_malignancy_counts
WITH malignant_concepts AS 
	(
		SELECT
			ca.*,
			c.CONCEPT_NAME
		FROM
			WINSHIPCARS.CONCEPT_ANCESTOR ca
		INNER JOIN WINSHIPCARS.CONCEPT c ON
			ca.DESCENDANT_CONCEPT_ID = c.CONCEPT_ID
		WHERE
			ca.ANCESTOR_CONCEPT_ID = 443392 --Malignant neoplastic disease
			AND c.DOMAIN_ID = 'Condition'
			AND c.CONCEPT_CLASS_ID  = 'Clinical Finding'
   ), 
   unique_malignancy_per_person AS
   (
   		SELECT
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID, 
			COUNT(co.PERSON_ID) AS freq	
		FROM
			WINSHIPCARS.CONDITION_OCCURRENCE co 
			INNER JOIN malignant_concepts mc ON	
			co.CONDITION_CONCEPT_ID = mc.descendant_concept_id	
		GROUP BY 
			co.PERSON_ID, 
			co.CONDITION_CONCEPT_ID	
		---515,687
   ),
  unique_malignancy_counts AS 
  (
	SELECT
		UMPP.CONDITION_CONCEPT_ID,  
		COUNT(UMPP.condition_concept_id) freq	
	FROM
		unique_malignancy_per_person umpp	 
	GROUP BY 
		UMPP.CONDITION_CONCEPT_ID	
	ORDER BY 
		count(UMPP.condition_concept_id) DESC 
  ), 
 add_concept_name AS 
 (
 	SELECT 
 		umc.condition_concept_id, 
 		c.concept_name AS condition_concept_name, 
 		umc.freq
 	FROM 
 		unique_malignancy_counts umc
 	INNER JOIN WINSHIPCARS.concept c ON	
 		umc.CONDITION_concept_id = c.CONCEPT_ID 
 )
SELECT
	*
FROM
	add_concept_name
ORDER BY	
freq; 



	
	
	
	
	
