WITH unique_condition_counts_per_person AS 
  (
	SELECT
		t1.PERSON_ID,
		t1.CONDITION_CONCEPT_ID
	FROM
		WINSHIPCARS.CONDITION_OCCURRENCE t1 
	WHERE 
		t1.CONDITION_CONCEPT_ID <> -1
	GROUP BY 
		t1.PERSON_ID,	
		t1.CONDITION_CONCEPT_ID	
	  )
, unique_people_per_condition as
(	SELECT
		t2.CONDITION_CONCEPT_ID,
		COUNT(t2.condition_concept_id) freq
	FROM
		unique_condition_counts_per_person t2
	GROUP BY 	
		t2.CONDITION_CONCEPT_ID	
	ORDER BY 
		count(t2.condition_concept_id) DESC
)			
, add_concept_name AS 
 (
 	SELECT 
 		t3.condition_concept_id, 
 		c.concept_name AS condition_concept_name, 
 		t3.freq
 	FROM 
 		unique_people_per_condition t3
 	INNER JOIN WINSHIPCARS.concept c ON	
 	t3.CONDITION_concept_id = c.CONCEPT_ID 
 )
SELECT
	*
FROM
	add_concept_name
ORDER BY freq DESC 
